alias cpf='copyfile'
alias gcm='git commit -m'
alias no-sleep='caffeinate -dimsu'
alias kubectl="GODEBUG=netdns=cgo kubectl"
alias k="GODEBUG=netdns=cgo kubectl"

auto-commit() {
  git add . && git commit -m "chore: automated commit $(date '+%Y-%m-%d %H:%M:%S')" && git push
}

ci-commit() {
  git commit --allow-empty -m "ci: refresh pipeline components" && git push
}
