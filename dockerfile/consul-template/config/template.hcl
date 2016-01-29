ssl {
  enabled = true
  verify = false
}

template {
  source = "/config/ha-proxy.ctmpl"
  destination  = "/usr/local/etc/haproxy/haproxy.cfg"
  command = "haproxy -D -p /var/run/haproxy/haproxy.pid -f /usr/local/etc/haproxy/haproxy.cfg -sf $(pidof haproxy) || true"
}
