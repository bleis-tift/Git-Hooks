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
        $_;
    }
    sub get {
        my $self = shift;
        my $hash = shift;
        chomp(my $msgs = `git cat-file -p $hash`);
        $msgs;
    }
}

sub is_master_branch {
    my $repos = shift;
    $repos->branch_name eq 'master';
}

sub extract_ticket_id {
    my $repos = shift;
    $_ = $repos->branch_name;
    if ($_ !~ m"id/\d+") { return ''; }
    s".*id/(\d+).*"refs #$1";
    $_;
}

sub append_msg_to_1st_line {
    my ($msg, $str) = @_;
    $_ = $msg;
    s/([^\r\n]+)/$1 $str/;
    $_;
}

sub has_ticket_id {
    my $msg = shift;
    $msg =~ /^[^\r\n]+refs #\d+/;
}

sub is_empty {
    my $msg = shift;
    foreach my $l (split(/\r\n|\r|\n/, $msg)) {
        if ($l !~ /^#|^\s*$/) { return 0; }
    }
    return 1;
}

{ package Commit;
    sub new {
        my $class = shift;
        my @msgs = split(/\n/, shift);
        my @parents = ();
        my $last_parent = 1;
        foreach my $l (@msgs) {
            if ($l =~ /^parent ([0-9a-f]{40})$/) {
                push @parents, $1;
                $last_parent += 1;
            }
        }
        my $self = { Parents => \@parents, Message => $msgs[$last_parent + 3] };
        bless $self, $class;
    }
    sub contains_ticket {
        my $self = shift;
        Git::has_ticket_id($self->{Message});
    }
    sub parents {
        my $self = shift;
        $self->{Parents};
    }
    sub has_parent {
        my $self = shift;
        my $count = scalar(@{$self->{Parents}});
        if ($count == 0) {
            return 0;
        }
        ${$self->{Parents}}[0] ne ('0' x 40);
    }
}

1;
