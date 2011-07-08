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
  end
end
