
# Kill process by port
# Usage:
#   kp 8080   # show process, then ask: [N/y/f]
#   kp! 8080  # force kill immediately
kp() {
  local force=false
  local port="$1"

  # Force mode
  if [[ "$1" == "-f" ]]; then
    force=true
    port="$2"
  fi

  # Check port
  if [[ -z "$port" ]]; then
    echo "Usage: kp <port> | kp! <port>"
    return 1
  fi

  # Find PID
  local pids=(${(f)"$(lsof -ti :"$port")"})

  if (( ${#pids[@]} == 0 )); then
    echo "No process found on port $port"
    return 0
  fi

  for pid in $pids; do
    # Get process name and executable path
    local process=$(ps -p "$pid" -o comm=)
    local path=$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p')

    echo "Port:    $port"
    echo "PID:     $pid"
    echo "Process: $process"
    echo "Path:    ${path:-unknown}"

    # kp! → force kill immediately
    if $force; then
      kill -9 "$pid" || continue
      echo "✓ Force killed $process ($pid) — ${path:-unknown}"
      continue
    fi

    # kp → ask before killing
    local answer
    read "answer=Kill this process? [N/y/f] "

    case "${answer:l}" in
      y)
        kill "$pid" || continue
        echo "✓ Killed $process ($pid) — ${path:-unknown}"
        ;;
      f)
        kill -9 "$pid" || continue
        echo "✓ Force killed $process ($pid) — ${path:-unknown}"
        ;;
      *)
        echo "Cancelled."
        ;;
    esac
  done
}

# kp! = force kill
alias 'kp!'='kp -f'
