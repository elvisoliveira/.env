# One-shot Bitwarden: asks for the master password, runs the command and locks the vault right after.
# The session lives in a function-local variable and is never exported to the shell.
function bw --wraps bw --description 'bitwarden-cli unlocked per command'
    switch "$argv[1]"
        case login logout config status lock unlock serve '' --help -h help --version -v
            # commands that do not need the vault unlocked
            command bw $argv
            return
    end
    set -l sess (command bw unlock --raw); or return 1
    BW_SESSION=$sess command bw $argv
    set -l rc $status
    BW_SESSION=$sess command bw lock >/dev/null
    return $rc
end
