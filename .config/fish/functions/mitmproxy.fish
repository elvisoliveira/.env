function mitmproxy --wraps mitmproxy --description "mitmproxy with the CA kept in ~/documents/secrets (no ~/.mitmproxy)"
    command mitmproxy --set confdir=$HOME/documents/secrets/mitmproxy-ca $argv
end
