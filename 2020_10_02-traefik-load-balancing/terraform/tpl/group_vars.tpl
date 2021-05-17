vip: "${cidrhost(subnet, vip)}/${element(split("/", subnet), 1)}"
backends: "${join(",", [
    for backend in backends:
        format("http://%s:%s", backend.ip == "127.0.0.1" ? backend.ip : cidrhost(subnet, tonumber(backend.ip)), backend.port)
    ])}"
%{ if keepalived_conf != "" }${keepalived_conf}%{ endif }