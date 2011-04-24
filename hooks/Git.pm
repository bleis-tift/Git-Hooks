#! /usr/bin/env perl

package Git;

use warnings;
use strict;

{ package Repository;
    sub new {
        my $class = shift;
        my $dir = shift;
        my $self = { GitDir => $dir };
        bless $self, $class;
    }
    sub branch_name {
        my $self = shift;
        my $dir = $self->{GitDir};
        chomp($_ = `git --git-dir="$dir" symbolic-ref HEAD 2>/dev/null`);
        s"refs/heads/"";
    }
}

sub is_master_branch {
    my $repos = shift;
    $repos->branch_name eq 'master';
}

1;
