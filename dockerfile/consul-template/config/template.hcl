consul = "192.168.32.80:8500"
token = "c3b2ae2c52056c1c2212aa72c2e0dc63f2c95039da933a47d5144bdac704003a"
reap = true

ssl {
  enabled = true
  verify = false
}

template {
  source = "/config/ha-proxy.ctmpl"
  destination  = "/usr/local/etc/haproxy/haproxy.cfg"
  command = "haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /var/run/haproxy/haproxy.pid -sf $(cat /var/run/haproxy/haproxy.pid)"
}
