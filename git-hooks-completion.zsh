#!zsh

_git-hooks ()
{
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -C \
    ':command:->command' \
    '*::options:->options'

  case $state in
    (command)

      local -a subcommands
      subcommands=(
        'list:list'
        'enabled:enabled'
        'disabled:disabled'
        'on:on'
        'off:off'
        'update:update'
      )
      _describe -t commands 'git hooks' subcommands
    ;;

    (options)
      case $line[1] in

        (list)
          ;;

        (enabled)
          ;;

        (disabled)
          ;;

        (on)
            __git-hooks-on/off
          ;;

        (off)
            __git-hooks-on/off
          ;;
        (update)
          _arguments \
              ':remote:__git_remotes'\
          ;;
      esac
    ;;
  esac
}

__git-hooks-on/off ()
{
  local expl
  declare -a hooks

  hooks=(${${(f)"$(_call_program hooks git hooks list 2> /dev/null)"}})
  __git_command_successful || return

  _wanted hooks expl 'hooks' compadd $hooks
}

__git_remotes() {
  local expl
  declare -a remotes

  remotes=(${${(f)"$(_call_program remote git --git-dir=$GIT_HOOKS_HOME/.git for-each-ref --format='"%(refname)"' refs/remotes 2>/dev/null)"}#refs/remotes/})
  __git_command_successful || return

  _wanted remotes expl 'remotes' compadd $remotes
}

__git_branch_names () {
  local expl
  declare -a branch_names

  branch_names=(${${(f)"$(_call_program branchrefs git --git-dir=$GIT_HOOKS_HOME/.git for-each-ref --format='"%(refname)"' refs/heads 2>/dev/null)"}#refs/heads/})
  __git_command_successful || return

  _wanted branch-names expl branch-name compadd $* - $branch_names
}

__git_command_successful () {
  if (( ${#pipestatus:#0} > 0 )); then
    _message 'not a git repository'
    return 1
  fi
  return 0
}

zstyle ':completion:*:*:git:*' user-commands hooks:'Git-Hooks manage command'
