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

# チケットIDを持っているかどうか
$msg = 'hogehoge refs #42';
ok(Git::has_ticket_id($msg));

$msg = 'hogehoge refs #';
ok(!Git::has_ticket_id($msg));

$msg = <<EOS
hogepiyo refs #234

foobar
EOS
;
ok(Git::has_ticket_id($msg));

$msg = <<EOS
hogepiyo

foobar refs #234
EOS
;
ok(!Git::has_ticket_id($msg)); # 1行目じゃないとダメ
chomp($msg);
ok(!Git::has_ticket_id($msg));

done_testing;
