#!/usr/bin/env nu

use std/assert
use std/clip

const db = ("~" | path join ".cc-switch" "cc-switch.db" | path expand)
const detail_cols = [base_url, api_key, api_type]

# Open the cc-switch SQLite database and fail fast when it is missing.
#
# Parameters:
# - None.
#
# Returns:
# - An opened SQLite database value.
#
# Exceptions:
# - Raises an assertion error when the database file does not exist.
def open-db [] {
  assert ($db | path exists) $"($db) does not exist. Please install and configure cc-switch first."
  open $db
}

# Fetch all supported application types from the database.
#
# Parameters:
# - None.
#
# Returns:
# - A list of application type names.
def get-support-apps [] {
  let db_read = (open-db)
  $db_read | query db "select app_type from providers group by app_type" | get -o app_type
}

# Fetch provider rows and decode their JSON settings.
#
# Parameters:
# - app: Application type name.
# - is_current: Whether to return only the current provider.
#
# Returns:
# - A list of provider rows, or a single row when is_current is true.
def get-infos [app: string, is_current?: bool = false] {
  let db_read = (open-db)
  let infos = ($db_read
    | query db $'select name, settings_config, is_current from providers where app_type == "($app)"'
    | update settings_config { from json })

  if $is_current {
    $infos | where is_current == 1 | select name settings_config | rename name info | first
  } else {
    $infos
    | update is_current {|row| $row.is_current == 1 }
    | select name settings_config is_current
    | rename name info is_current
  }
}

# Convert a codex provider row into a normalized display shape.
#
# Parameters:
# - info: Provider row returned by get-infos.
#
# Returns:
# - A record containing name, state, base_url, api_type, api_key, and model.
def get-codex-help [info] {
  let cfg = ($info.info.config | from toml)
  let base_url = ($cfg
    | get -o model_providers
    | default {}
    | transpose provider value
    | where {|row| 'base_url' in ($row.value | columns)}
    | get -o 0.value.base_url
    | default "")

  {
    name: $info.name
    is_current: ($info | get -o is_current | default true)
    base_url: $base_url
    api_type: "openai-responses"
    api_key: ($info | get -o info.auth.OPENAI_API_KEY | default "")
    model: ($cfg | get -o model | default "gpt-5.4")
  }
}

# Convert a gemini provider row into a normalized display shape.
#
# Parameters:
# - info: Provider row returned by get-infos.
#
# Returns:
# - A normalized provider record.
def get-gemini-help [info] {
  let envs = ($info.info | get -o env | default {})
  {
    name: $info.name
    is_current: ($info | get -o is_current | default true)
    base_url: ($envs | get -o GOOGLE_GEMINI_BASE_URL | default "")
    api_type: "google-generative-ai"
    api_key: ($envs | get -o GEMINI_API_KEY | default "")
    model: ($envs | get -o GEMINI_MODEL | default "gemini-3-flash-preview")
  }
}

# Convert a claude provider row into a normalized display shape.
#
# Parameters:
# - info: Provider row returned by get-infos.
#
# Returns:
# - A normalized provider record.
def get-claude-help [info] {
  let envs = ($info.info | get -o env | default {})
  let model = ([
    ($envs | get -o ANTHROPIC_MODEL)
    ($envs | get -o ANTHROPIC_DEFAULT_OPUS_MODEL)
    ($envs | get -o ANTHROPIC_DEFAULT_HAIKU_MODEL)
    ($envs | get -o ANTHROPIC_DEFAULT_SONNET_MODEL)
    ($envs | get -o ANTHROPI_REASONING_MODEL)
  ] | uniq | where ($it | is-not-empty))

  {
    name: $info.name
    is_current: ($info | get -o is_current | default true)
    base_url: ($envs | get -o ANTHROPIC_BASE_URL | default "")
    api_type: "anthropic-messages"
    api_key: ($envs | get -o ANTHROPIC_AUTH_TOKEN | default "")
    model: $model
  }
}

# Convert an opencode provider row into a normalized display shape.
#
# Parameters:
# - info: Provider row returned by get-infos.
#
# Returns:
# - A normalized provider record.
def get-opencode-help [info] {
  let infos = $info.info
  let model = ($infos
    | get -o models
    | default {}
    | transpose model value
    | each {|row| $row.model})
  let api_type = (match $infos.npm {
    $x if ($x | str contains "openai-compatible") => "openai-completions"
    $x if ($x | str contains "openai") => "openai-responses"
    $x if ($x | str contains "anthropic") => "anthropic-messages"
    $x if ($x | str contains "google") => "google-generative-ai"
    _ => "openai-completions"
  })

  {
    name: $info.name
    is_current: ($info | get -o is_current | default true)
    base_url: ($infos | get -o options | default {} | get -o baseURL | default "")
    api_type: $api_type
    api_key: ($infos | get -o options | default {} | get -o apiKey | default "")
    model: $model
  }
}

# Normalize a provider record according to the target application type.
#
# Parameters:
# - app: Application type name.
# - info: Provider row returned by get-infos.
#
# Returns:
# - A normalized provider record.
def get-app-help [app: string, info: any] {
  match $app {
    codex => { get-codex-help $info }
    gemini => { get-gemini-help $info }
    claude => { get-claude-help $info }
    opencode => { get-opencode-help $info }
    _ => {
      error make { msg: $"Unsupported app: ($app)" }
    }
  }
}

# Resolve one provider or a list of providers for display.
#
# Parameters:
# - app: Application type name.
# - name: Optional provider name.
# - current: Whether to resolve only the current provider.
# - col: Optional detail column to return directly.
#
# Returns:
# - A normalized provider record, a list of records, or a scalar detail value.
def get-app-info [app: string, name?: string, current?: bool = false, col?: string = ""] {
  mut result = (get-infos $app $current)
  let names = ($result | get name)
  let name_is_empty = ($name | is-empty)

  assert ($name_is_empty or ($name in $names)) $"provider ($name) does not exist. Existing providers: ($names | str join ', ')."
  assert (($col | is-empty) or ($col in $detail_cols)) $"Only the following details are supported: ($detail_cols | str join ', ')"

  if $current {
    $result = (get-app-help $app $result)
  } else {
    $result = ($result | each {|item| get-app-help $app $item })
    if (not $name_is_empty) {
      $result = ($result | where name == $name | first)
    }
  }

  if (($col != "") and ($current or (not $name_is_empty))) {
    $result | get -o $col
  } else {
    $result
  }
}

# Show provider details for one app, one provider, or the current default.
#
# Parameters:
# - app: Optional application type. When omitted, uses "all".
# - provider: Optional provider name.
# - --default/-d: Show the current provider only.
# - --raw/-r: Reserved plain-text output flag.
# - --json/-j: Reserved JSON output flag.
# - --all/-a: Include API keys in the output.
# - --copy/-c: Copy a selected scalar value to clipboard.
# - --url/-u: Return only the base URL.
# - --key/-k: Return only the API key.
# - --type/-t: Return only the API type.
# - --models/-m: Reserved compatibility flag.
#
# Returns:
# - Provider records or selected scalar values depending on flags.
#
# Side effects:
# - May copy a scalar value to the system clipboard.
export def main [
  app?: string,
  provider?: string,
  --default(-d),
  --raw(-r) = false,
  --json(-j),
  --all(-a),
  --copy(-c),
  --url(-u),
  --key(-k),
  --type(-t),
  --models(-m)
] {
  mut result: any = null
  let target_app = (if ($app | is-empty) { "all" } else { $app })

  if ($target_app != "all") {
    let app_types = get-support-apps
    assert ($target_app in $app_types) $"($target_app) is not supported. Supported apps: ($app_types | str join ', ')."

    let col = (if $url { "base_url" } else if $key { "api_key" } else if $type { "api_type" } else "")

    if ($col != "") {
      $result = (get-app-info $target_app $provider $default $col)
      if ($result != null) {
        if $copy {
          $result | clip copy
          return
        } else {
          return $result
        }
      }
    } else {
      let show_alias = (match $target_app {
        codex => { {key: OPENAI_API_KEY, url: OPENAI_BASE_URL, model: model} }
        gemini => { {key: GEMINI_API_KEY, url: GOOGLE_GEMINI_BASE_URL, model: GEMINI_MODEL} }
        claude => { {key: ANTHROPIC_AUTH_TOKEN, url: ANTHROPIC_BASE_URL, model: ANTHROPIC_MODEL} }
        _ => { {key: api_key, url: base_url, model: model} }
      })

      $result = (if $all {
        get-app-info $target_app $provider $default $col | rename --column { api_key: $show_alias.key }
      } else {
        get-app-info $target_app $provider $default $col | reject api_key
      } | rename --column {
        base_url: $show_alias.url
        model: $show_alias.model
      })
    }
  }

  if $json {
    $result | to json
  } else if $raw {
    $result | to text
  } else {
    $result
  }
}
