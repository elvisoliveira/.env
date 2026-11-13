function sandbox-android --description 'Redroid tunnel (adb 15555 + Reactotron reverse 9090), Ctrl+C closes'
    set -l dev 127.0.0.1:15555
    # adb setup waits for the tunnel; ssh stays in the foreground so Ctrl+C reaches it
    fish -c '
        for i in (seq 30); nc -z 127.0.0.1 15555; and break; sleep 0.5; end
        adb connect $argv[1]
        timeout 15 adb -s $argv[1] wait-for-device; or begin; echo "redroid did not respond" >&2; exit 1; end
        adb -s $argv[1] reverse tcp:9090 tcp:9090
        echo "ready: adb -s $argv[1]"
    ' $dev &
    ssh -N mac-sandbox
    adb disconnect $dev 2>&1
end
