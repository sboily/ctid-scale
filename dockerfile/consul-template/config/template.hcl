consul = "192.168.1.124:8500"
token = "9b5077e7aebe5924e6ad2d7a75c614e9f705cac73eb5c0a6fa9be8c428b6f1f9"

ssl {
  enabled = true
  verify = false
}

template {
  source = "/config/ha-proxy.ctmpl"
  destination  = "/usr/local/etc/haproxy/haproxy.cfg"
  command = "echo $(pidof haproxy) && haproxy -D -p /var/run/haproxy/haproxy.pid -f /usr/local/etc/haproxy/haproxy.cfg -sf $(pidof haproxy) || true"
}
