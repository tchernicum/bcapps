#!/bin/perl

# Obtain twitter followers by following others
# --username: twitter username
# --password: supertweet (NOT TWITTER) password
# --create: create SQLite3 table it it doesn't already exist

# WARNING: Twitter often bans users who use programs like this; use
# with caution

push(@INC,"/usr/local/lib");
require "bclib.pl";
require "bc-twitter.pl";

# get_twits(); die "TESTING";

# twitter is case-insensitive, so lower case username
$globopts{username} = lc($globopts{username});
unless ($globopts{username} && $globopts{password}) {
  die "--username=username --password=password required";
}

# SQL db to store data for this program
$dbname = "$ENV{HOME}/bc-twitter-follow-$globopts{username}.db";

# die if sqlite3 db doesn't exist or has 0 size
unless (-s $dbname) {
  unless ($globopts{create}) {
    die("$dbname doesn't exist or is empty; use --create to create");
  } else {
    create_db("$dbname.db");
  }
}

# my friends and followers
@followers = twitter_friends_followers_ids("followers", $globopts{username}, $globopts{password});
@friends = twitter_friends_followers_ids("friends", $globopts{username}, $globopts{password});

# people who follow me, but I don't followback
@tofollow = minus(\@followers, \@friends);

# some people have to approve your follow request; choosing to follow
# in the same order just means you'll fail on these requests, so
# randomize @tofollow order

@tofollow = randomize(\@tofollow);

debug("SIZES: $#followers, $#friends, $#tofollow");

# not sure reciprocality is useful, but it's polite
for $i (@tofollow) {
  debug("FOLLOWING: $i");
  $res = twitter_follow($i, $globopts{username}, $globopts{password});

  if ($res) {
    $failsinrow++;
    debug("FAILS IN ROW: $failsinrow");
  } else {
    $failsinrow=0;
  }
  
  if ($failsinrow>=10) {die "too many fails in row";}

  # below to avoid slamming twitter/supertweet API
  sleep(1);
}

# NOTE: I'm copying this from a much longer program that does a lot more!

=item create_db($file)

Create SQLite3 db in file $file

=cut

sub create_db {
  my($file) = @_;
  local(*A);
  open(A, "|sqlite3 $file");
  print A << "MARK";
CREATE TABLE bc_twitter_follow (
 userid BIGINT,
 -- action is one of 'FOLLOW','UNFOLLOW','BLOCKED','FOLLOWED','UNFOLLOWED'
 action TEXT,
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
MARK
;
  close(A);
}

=item get_twits(\%hash, $n=100)

Obtain a list of $n user ids, starting from the public timeline, that
are not keys in %hash.

For example, if %hash keys are friends/followers, return $n ids of
twits who are not friends/followers.

=cut

sub get_twits {
  my($hashref, $n) = @_;
  my(@res); # result
  my(@init); # list of "seeds" from which I recurse into followers/friends
  unless ($n) {$n=100;}

  # obtain ids from the public timeline
  # TODO: this unnecessarily excludes friends/followers of people in %hash???
  my(@tweets) = twitter_public_timeline();
  for $i (@tweets) {
    my($id) = $i->{user}{id};
    unless ($hashref->{$id}) {
      push(@init, $id);
    }
  }





  # TODO: filter out people in hash!
  
#  debug(@tweets);
}
