#! /usr/bin/env perl

use warnings;
use strict;

use File::Copy;
use IO::File;

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
my %conf = %{eval(`cat "configs/Install-${env}.pl"`)};

my $gitcmddir = $conf{gitcmddir};
my $gitconfig = $count == 2 ? shift : $conf{gitconfig};
my $templatedir = $conf{templatedir};
my $githookshome = $conf{githookshome};
my $usesymlink = $conf{usesymlink} eq 'true';

$_ = $gitconfig;
s/~/$ENV{HOME}/;
$gitconfig = $_;

# 自分自身をgithookshomeにすべてコピー
unless (-e $gitconfig) { `mkdir -p "$gitconfig"`; }
unless (-e "${githookshome}/.git") {
    `cp -fpR "./" "$githookshome"`;
}

# インストールに使用した設定を保存
copy "configs/Install-${env}.pl", "${githookshome}/install-config";

# シンボリックリンクが使えるかどうかで分岐
if ($usesymlink) {
    # TODO : シンボリックリンクが使える場合は、copyじゃなくてln -sな感じで実装したい
}
else {
    # サブコマンドのコピー
    foreach my $i (`ls commands/cp-* 2>/dev/null`) {
        $i =~ /cp-(.+)/;
        chomp(my $src = './' . $i);
        chomp(my $dst = $gitcmddir . '/' . $1);
        copy $src, $dst
            or die '[' . $src . ' -> ' . $dst . '] ' . $!;
    }

    # GIT_HOOKS_HOMEの設定
    my $rc = IO::File->new($gitconfig, '>>');
    $rc->print("export GIT_HOOKS_HOME=\"${githookshome}\"\n");
    $rc->close;

    # テンプレートのコピー
    copy "${githookshome}/templates/dispatcher", "${templatedir}/dispatcher";
    foreach my $h (`cat "${githookshome}/configs/hooks-list"`) {
        chomp($h);
        if ($h ne 'ci') {
            copy "${githookshome}/templates/common", "${templatedir}/$h";
        }
    }
}
