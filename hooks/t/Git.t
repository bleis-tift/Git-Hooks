#! /usr/bin/env perl

use warnings;
use strict;

use Test::More;
use Test::MockObject;

use FindBin;
use lib "$FindBin::RealBin/..";
use Git;

my $branch = '';
my $repos = Test::MockObject->new();
$repos->mock(
    branch_name => sub { $branch; }
);

# masterブランチにいるかどうか
$branch = 'master';
ok(Git::is_master_branch($repos));

$branch = 'hoge';
ok(!Git::is_master_branch($repos));

done_testing;
