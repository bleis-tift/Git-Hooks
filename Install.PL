#! /usr/bin/env perl

use warnings;
use strict;

use File::Copy;
use IO::File;
use File::Basename;
use Getopt::Long;

my $verbose = 0;

sub ln {
    return if (-e $_[1]);
    if ($verbose) {
        print("ln -s @_\n");
    }
    symlink $_[0], $_[1] or die;
}

sub cp {
    if ($verbose) {
        print("cp @_\n");
    }
    copy @_ or die;
}

sub exec_cmd {
    my $cmd = shift;
    if ($verbose) {
        print($cmd, "\n");
    }
    chomp(my $res = `$cmd`);
    $res;
}

my $prefix;
{
    my $res = GetOptions(
        'verbose' => \$verbose,
        'prefix=s' => \$prefix,
    );
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
if (defined($prefix) and -d $prefix) {
    $prefix =~ s|/+$||;
    foreach my $k (keys(%conf)) {
        my $v = $conf{$k};
        $v =~ s|^/usr(/)?|$prefix$1|;
        $conf{$k} = $v;
    }
}

my $gitcmddir = $conf{gitcmddir};
my $gitconfig = $count == 2 ? shift : $conf{gitconfig};
my $templatedir = $conf{templatedir};
my $githookshome = $conf{githookshome};
my $usesymlink = $conf{usesymlink} eq 'true';
unless ($usesymlink) {
    no warnings 'redefine';
    *main::ln = \&cp;
}

$_ = $gitconfig;
s/~/$ENV{HOME}/;
$gitconfig = $_;

# なぜかtouchしておかないとディレクトリが作られるので回避
if ($env eq 'msys') {
    `touch "${gitconfig}"`;
}

# 自分自身をgithookshomeにすべてコピー
my $dirname = dirname($gitconfig);
unless (-d $dirname) {
    exec_cmd("mkdir -p '$dirname'");
}
unless (-d "${githookshome}/.git") {
    if ($verbose) {
        print("cp -fpR \"./\" \"$githookshome\"", "\n");
    }
    unless (-d $githookshome) {
        exec_cmd("mkdir -p '$githookshome'");
    }
    `cp -fpR "./" "$githookshome"`;
}

# インストールに使用した設定を保存
cp("configs/Install-${env}.pl", "${githookshome}/install-config");

# シンボリックリンクが使えるかどうかで分岐
if ($usesymlink) {
    unless (-d $gitcmddir) {
        exec_cmd("mkdir -p '$gitcmddir'");
    }
    # サブコマンドのコピー
    foreach my $i (`ls ${githookshome}/commands/* 2>/dev/null`) {
        chomp(my $orig = $i);
        chomp(my $link = $gitcmddir . '/' . basename($i));
        ln($orig, $link);
    }

    # GIT_HOOKS_HOMEの設定
    my $home = $ENV{GIT_HOOKS_HOME} || '';
    unless ($home eq $githookshome) {
        if ($verbose) {
            print('echo \'GIT_HOOKS_HOME=\"' . $githookshome . '\"; export GIT_HOOKS_HOME\' >> ' . $gitconfig, "\n");
        }
        open my $fh, '>>', $gitconfig or die;
        print $fh 'GIT_HOOKS_HOME="' . $githookshome . '"; export GIT_HOOKS_HOME', "\n";
    }

    # テンプレートのコピー
    unless (-d $templatedir) {
        exec_cmd("mkdir -p '$templatedir'");
    }
    cp("${githookshome}/templates/dispatcher", "${templatedir}/dispatcher");
    chmod(0755, "${templatedir}/dispatcher");
    foreach my $h (`cat "${githookshome}/configs/hooks-list"`) {
        chomp($h);
        unless ($h eq 'ci') {
            ln("${githookshome}/templates/common", "${templatedir}/$h");
        }
    }
}
else {
    # サブコマンドのコピー
    foreach my $i (`ls commands/* 2>/dev/null`) {
        chomp(my $src = './' . $i);
        chomp(my $dst = $gitcmddir . '/' . $i);
        cp($src, $dst)
            or die '[' . $src . ' -> ' . $dst . '] ' . $!;
    }

    # GIT_HOOKS_HOMEの設定
    chomp(my $home = &exec_cmd('echo ${GIT_HOOKS_HOME}'));
    unless ($home eq $githookshome) {
        `echo "export GIT_HOOKS_HOME=\\\"${githookshome}\\\"" >> "$gitconfig"`;
    }

    # テンプレートのコピー
    cp("${githookshome}/templates/dispatcher", "${templatedir}/dispatcher");
    foreach my $h (`cat "${githookshome}/configs/hooks-list"`) {
        chomp($h);
        unless ($h eq 'ci') {
            cp("${githookshome}/templates/common", "${templatedir}/$h");
        }
    }
}
