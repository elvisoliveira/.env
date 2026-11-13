function mitmweb --wraps mitmweb --description "mitmweb with the CA kept in ~/documents/secrets (no ~/.mitmproxy)"
    command mitmweb --set confdir=$HOME/documents/secrets/mitmproxy-ca $argv
end
