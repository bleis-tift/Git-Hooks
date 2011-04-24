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

# 1行目にメッセージを追加
my $msg = 'hogehoge';
is(Git::append_msg_to_1st_line($msg, 'refs #1234'), 'hogehoge refs #1234');

$msg = <<EOS
hogehoge

piyopiyo
EOS
;
my $expected = <<EOS
hogehoge refs #3456

piyopiyo
EOS
;
is(Git::append_msg_to_1st_line($msg, 'refs #3456'), $expected);
chomp($msg);
chomp($expected);
is(Git::append_msg_to_1st_line($msg, 'refs #3456'), $expected);

# チケットIDの抽出
$branch = 'master';
is(Git::extract_ticket_id($repos), '');

$branch = 'hoge';
is(Git::extract_ticket_id($repos), '');

$branch = 'id/1234';
is(Git::extract_ticket_id($repos), 'refs #1234');

$branch = 'hoge/id/999';
is(Git::extract_ticket_id($repos), 'refs #999');

$branch = 'hoge/id/42/hogehoge';
is(Git::extract_ticket_id($repos), 'refs #42');

done_testing;
