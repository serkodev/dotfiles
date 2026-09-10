# gitignore local
gil() {
  local local_git_file="${1:-.gitignore-local}"
  local exclude_file="./.git/info/exclude"

  # Ensure we're inside a git repo
  if [[ ! -d .git ]]; then
    echo "gil: not a git repository"
    return 1
  fi

  # Ensure exclude file exists
  mkdir -p ./.git/info
  touch "$exclude_file"

  # Append ignore file to exclude (only if not already present)
  if ! grep -Fxq "$local_git_file" "$exclude_file"; then
    echo "$local_git_file" >> "$exclude_file"
  fi

  # Create symlink if it doesn't already exist
  if [[ ! -e "$local_git_file" ]]; then
    ln -s "$exclude_file" "$local_git_file"
  fi
}
