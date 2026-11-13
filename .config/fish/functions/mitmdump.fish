function mitmdump --wraps mitmdump --description "mitmdump with the CA kept in ~/documents/secrets (no ~/.mitmproxy)"
    command mitmdump --set confdir=$HOME/documents/secrets/mitmproxy-ca $argv
end
