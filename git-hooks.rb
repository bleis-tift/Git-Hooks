require 'formula'

class GitHooks < Formula
  head 'http://github.com/clairvy/Git-Hooks.git', :branch => 'rewrite'
  homepage 'https://github.com/bleis-tift/Git-Hooks'

  def install
    system "perl", "Install.PL", "-v", "linux", "--prefix=" + prefix

    bin.install "commands/git-hooks"

    (prefix + "etc/bash_completion.d").install "git-hooks-completion.bash"

    ohai 'You must set envirnment variable GIT_HOOKS_HOME to your startup script(like .bashrc).'
    puts '# BEGIN example. (write into $HOME/.bashrc if use bash)'
    puts 'GIT_HOOKS_HOME=/usr/local/share/git-core/Git-Hooks; export GIT_HOOKS_HOME'
    puts '# END'

    ohai 'If you use zsh and want to completion git hooks, write bellow setting in .zshrc'
    puts '# BEGIN use git hooks completion'
    puts 'source /usr/local/etc/bash_completion.d/git-hooks-completion.bash'
    puts '# END'

    ohai 'and run bellow'
    puts '$ git config --global alias.hooks hooks'
  end
end
