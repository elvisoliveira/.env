# Bitwarden de uso único: pede a senha mestra, roda o comando e bloqueia o cofre logo depois.
# A sessão fica numa variável local da função, nunca exportada para o shell.
function bw --wraps bw --description 'bitwarden-cli com desbloqueio por comando'
    switch "$argv[1]"
        case login logout config status lock unlock serve '' --help -h help --version -v
            # comandos que não precisam do cofre aberto
            command bw $argv
            return
    end
    set -l sess (command bw unlock --raw); or return 1
    BW_SESSION=$sess command bw $argv
    set -l rc $status
    BW_SESSION=$sess command bw lock >/dev/null
    return $rc
end
