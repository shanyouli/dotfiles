#!/usr/bin/env nu

use std/assert

const db = ("~" | path join ".cc-switch" "cc-switch.db" | path expand)

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

# Fetch supported application types from the providers table.
#
# Parameters:
# - None.
#
# Returns:
# - A list of distinct application type names.
def get-support-apps [] {
  let db_read = (open-db)
  $db_read | query db "select app_type from providers group by app_type" | get -o app_type
}

# List configured providers for all apps or a single app.
#
# Parameters:
# - app: Optional application type to filter by.
# - --default/-d: Show only the current provider for each app.
# - --raw/-r: Render plain text output.
# - --json/-j: Render JSON output.
#
# Returns:
# - A Nushell table, plain text, or JSON depending on flags.
export def main [
  app?: string,
  --default(-d),
  --raw(-r) = false,
  --json(-j)
] {
  let app_types = get-support-apps
  assert (($app | is-empty) or ($app in $app_types)) $"($app) is not supported. Supported apps: ($app_types | str join ', ')."

  let db_read = (open-db)
  mut sql_info = ($db_read | query db "SELECT app_type, name, is_current from providers" | update is_current {|row| $row.is_current == 1 })

  if $default {
    $sql_info = ($sql_info | where is_current | select app_type name | rename app name)
    if ($app | is-not-empty) {
      $sql_info = ($sql_info | where app_type == $app | first)
    }
  } else if ($app | is-not-empty) {
    $sql_info = ($sql_info | where app_type == $app)
  }

  if $raw {
    $sql_info | to text
  } else if $json {
    $sql_info | to json
  } else {
    $sql_info
  }
}
