#! /usr/bin/env perl

use warnings;
use strict;

use File::Copy;
use IO::File;
use File::Basename qw();

sub exec_cmd {
    my $cmd = shift;
    chomp(my $res = `$cmd`);
    $res;
}

my $count = @ARGV;
if ($count == 0) {
    my @envs = `ls configs/Install-*.pl`;
    foreach my $e (@envs) {
        $e =~ /Install-(.+).pl/;
        print $1, "\n";
    }
    exit 0;
}

my $env = shift;
unless (-f "configs/Install-${env}.pl") {
    print "configs/Install-${env}.pl does not exist.\n";
    exit 1;
}
my %conf = %{+eval{require "configs/Install-${env}.pl"}};

my $gitcmddir = $conf{gitcmddir};
my $gitconfig = $count == 2 ? shift : $conf{gitconfig};
my $templatedir = $conf{templatedir};
my $githookshome = $conf{githookshome};
my $usesymlink = $conf{usesymlink} eq 'true';

$_ = $gitconfig;
s/~/$ENV{HOME}/;
$gitconfig = $_;

# なぜかtouchしておかないとディレクトリが作られるので回避
if ($env eq 'msys') {
    `touch "${gitconfig}"`;
}

# 自分自身をgithookshomeにすべてコピー
my $dirname = File::Basename::dirname($gitconfig);
unless (-d $dirname) {
    `mkdir -p '$dirname'`;
}
unless (-e "${githookshome}/.git") {
    `cp -fpR "./" "$githookshome"`;
}

# インストールに使用した設定を保存
copy "configs/Install-${env}.pl", "${githookshome}/install-config";

# シンボリックリンクが使えるかどうかで分岐
if ($usesymlink) {
    # サブコマンドのコピー
    foreach my $i (`ls ${githookshome}/commands/* 2>/dev/null`) {
        chomp(my $orig = $i);
        chomp(my $link = $gitcmddir . '/' . File::Basename::basename($i));
        `ln -s "$orig" "$link"`;
    }

    # GIT_HOOKS_HOMEの設定
    chomp(my $home = &exec_cmd('echo ${GIT_HOOKS_HOME}'));
    unless ($home eq $githookshome) {
        `echo "export GIT_HOOKS_HOME=\\\"${githookshome}\\\"" >> "$gitconfig"`;
    }

    # テンプレートのコピー
    copy "${githookshome}/templates/dispatcher", "${templatedir}/dispatcher";
    foreach my $h (`cat "${githookshome}/configs/hooks-list"`) {
        chomp($h);
        unless ($h eq 'ci') {
            `ln -s "${githookshome}/templates/common" "${templatedir}/$h"`;
        }
    }
}
else {
    # サブコマンドのコピー
    foreach my $i (`ls commands/* 2>/dev/null`) {
        chomp(my $src = './' . $i);
        chomp(my $dst = $gitcmddir . '/' . $i);
        copy $src, $dst
            or die '[' . $src . ' -> ' . $dst . '] ' . $!;
    }

    # GIT_HOOKS_HOMEの設定
    chomp(my $home = &exec_cmd('echo ${GIT_HOOKS_HOME}'));
    unless ($home eq $githookshome) {
        `echo "export GIT_HOOKS_HOME=\\\"${githookshome}\\\"" >> "$gitconfig"`;
    }

    # テンプレートのコピー
    copy "${githookshome}/templates/dispatcher", "${templatedir}/dispatcher";
    foreach my $h (`cat "${githookshome}/configs/hooks-list"`) {
        chomp($h);
        unless ($h eq 'ci') {
            copy "${githookshome}/templates/common", "${templatedir}/$h";
        }
    }
}
