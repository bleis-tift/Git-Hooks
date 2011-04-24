#! /usr/bin/env perl

use warnings;
use strict;

use Test::More;
use Test::MockObject;

use FindBin;
use lib "$FindBin::RealBin/..";
use Git;

my $branch = '';
my %git_repos = ();
my $repos = Test::MockObject->new();
$repos->mock(branch_name => sub { $branch; });
$repos->mock(get => sub {
    my ($self, $hash) = @_;
    $git_repos{$hash};
});

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

# メッセージが空かどうか
$msg = 'hoge';
ok(!Git::is_empty($msg));

$msg = <<EOS

hoge
EOS
;
ok(!Git::is_empty($msg));
chomp($msg);
ok(!Git::is_empty($msg));

$msg = '';
ok(Git::is_empty($msg));

$msg = '   ';
ok(Git::is_empty($msg));

$msg = <<EOS

# this line is comment
EOS
;
ok(Git::is_empty($msg));
chomp($msg);
ok(Git::is_empty($msg));

########################################
# コミットの生成
sub gen_commit {
    my $msg = shift;
    my @parents = @_;

    my $parents = join("\nparent ", @parents);
    
    return <<EOS
tree 1234567890
parent ${parents}
author bleis-tift <hoge\@example.jp> 13010335648 +0900
committer bleis-tift <hoge\@example.jp> 13010335648 +0900

${msg}
EOS
    ;
}

# ハッシュで組み立てずにcommitとかmergeとかって関数使って組み立てるべき？
%git_repos = (
    '1234567890' x 4 => gen_commit('first commit', '0' x 40),

    'cafebabe' => gen_commit('hoge refs #1234', '1234567890' x 4),

    'babecafe' => gen_commit('piyo refs #1154', '1' x 40, 'a' x 40),
    '1' x 40 => gen_commit('foo refs #1', 'cafebabe'),
    'a' x 40 => gen_commit('bar refs #1111', 'cafebabe'),

    '9f' x 20 => gen_commit('start refs #1', '9' x 40, 'f' x 40),
    '9' x 40 => gen_commit('aaa refs #2', '8' x 40),
    '8' x 40 => gen_commit('bbb refs #3', '7' x 40),
    '7' x 40 => gen_commit('ccc refs #4', 'cafebabe'),
    'f' x 40 => gen_commit('AAA refs #5', 'e' x 40),
    'e' x 40 => gen_commit('BBB refs #6', 'd' x 40),
    'd' x 40 => gen_commit('CCC refs 7', 'cafebabe'),
);

# チケットIDがあるパターン
$msg = Commit->new($repos->get('cafebabe'));
ok($msg->contains_ticket);
ok($msg->has_parent);
is(${$msg->parents}[0], '1234567890' x 4);

# 根っこのコミットなのでチケットIDはない
$msg = Commit->new($repos->get('1234567890' x 4));
ok($msg->contains_ticket == 0);
ok($msg->has_parent == 0);
is(${$msg->parents}[0], '0' x 40);

# 複数の親を持つパターン
$msg = Commit->new($repos->get('babecafe'));
ok($msg->contains_ticket);
is(${$msg->parents}[0], '1' x 40);
is(${$msg->parents}[1], 'a' x 40);

done_testing;
