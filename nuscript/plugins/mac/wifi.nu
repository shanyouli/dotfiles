use std/log
use utils.nu [assert-macos]

# Toggle Wi-Fi between DHCP and Static IP.
#
# If current configuration is DHCP, it switches to Static IP.
# If current configuration is Static, it switches to DHCP.
export def main [
  ip: string = "192.168.43.212", # Static IP address
  router: string = "192.168.43.1", # Router/Gateway address
  mask: string = "255.255.255.0" # Subnet mask
] {
  assert-macos

  let interface = "Wi-Fi"
  let wifi_info = (^networksetup -getinfo $interface | lines)

  if ($wifi_info | is-empty) {
    log error $"Could not get info for ($interface). Please check if the interface name is correct."
    exit 1
  }

  if ($wifi_info | get 0 | str contains "DHCP") {
    log info $"Switching ($interface) to Static IP: ($ip), Router: ($router)"

    # Set manual IP
    ^networksetup -setmanual $interface $ip $mask $router
    # Set DNS (matching router by default as in original script)
    ^networksetup -setdnsservers $interface $router

  } else {
    log info $"Switching ($interface) to DHCP"

    ^networksetup -setdhcp $interface
    ^networksetup -setdnsservers $interface Empty
  }

  log info "Flushing DNS cache (requires sudo)..."
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder

  log info "Done."
}
