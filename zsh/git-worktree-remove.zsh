# gwr / gwr! - Git Worktree Remove
#
# Remove the worktree associated with a local branch (if any),
# then remove the local branch.
#
# Usage:
#   gwr <branch>    Safe removal
#   gwr! <branch>   Force removal
#
# Example:
#   gwr "feature/foo"
#   gwr! "feature/foo"

gwr() {
  local force=false

  if [[ "$1" == "--force" ]]; then
    force=true
    shift
  fi

  local branch="$1"

  if [[ -z "$branch" ]]; then
    echo "Usage: gwr[!] <branch>"
    return 1
  fi

  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "gwr: not inside a git repository"
    return 1
  fi

  local worktree_path

  worktree_path=$(
    git worktree list --porcelain | awk -v target="refs/heads/$branch" '
      /^worktree / {
        path = substr($0, 10)
      }
      /^branch / {
        if (substr($0, 8) == target) {
          print path
          exit
        }
      }
    '
  )

  if [[ -n "$worktree_path" ]]; then
    echo "Removing worktree: $worktree_path"

    if [[ "$force" == true ]]; then
      git worktree remove --force "$worktree_path" || return 1
    else
      git worktree remove "$worktree_path" || return 1
    fi
  fi

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Removing branch: $branch"

    if [[ "$force" == true ]]; then
      git branch -D "$branch"
    else
      git branch -d "$branch"
    fi
  fi
}

function gwr! {
  gwr --force "$@"
}
