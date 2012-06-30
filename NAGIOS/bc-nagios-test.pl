#!/bin/perl

# Runs a nagios test; if a plugin exists, use it; otherwise, use
# subroutines defined here

push(@INC,"/usr/local/lib");

# this is hideous; pass args to the program using NAGIOS_ARG2
@ARGV = split(/\s+/, $ENV{NAGIOS_ARG2});

require "bclib.pl";

# for testing only!
$globopts{debug}=1;

# what are we being asked to run?
my($cmd) = $ENV{NAGIOS_ARG1};
debug("CMD: $cmd");

# split into command and arguments (removing quotes first)
$cmd=~s/\"//isg;
$cmd=~/^\s*(.*?)\s+(.*)$/;
my($bin,$arg) = ($1,$2);

debug("BIN/ARG: $bin/$arg");

# if the "binary" starts with "bc_", I want to run a local function
if ($bin=~/^bc_/) {
  # this is dangerous, but I control my nagios files
  $res = eval($cmd);
  debug("$cmd returns: $res");
  # below just for testing
  exit($res);
}

# >>8 converts Perl exit value to program exit value (kind of)
$res = system("$bin $arg")>>8;

# run function on result before returning?
# no need to do this on functions I write myself, above
if ($globopts{func}) {$res = func($globopts{func}, $res);}

# this is ugly, but works (spits out stuff to console)
# TODO: redirect output of nagios to file that should remain empty
# debug("FUNC: $globopts{func}, RES: $res");

exit($res);

=item func($func, $val)

Applies $func to $val, where func is a very simple function.

Used primarily to turn return values of 1 to 0 when needed

=cut

sub func {
  my($func,$val) = @_;

  # when I want grep to fail, 1 is good, other values are bad
  # (values like 2 indicate other problems that I do need to be aware of
  if ($func eq "1is0") {
    if ($val==1) {return 0;}
    if ($val==0) {return 2;}
    return $val;
  }

  # some scripts return '1' to mean bad, but I want to return 2
  if ($func eq "1is2") {
    if ($val==1) {return 2;}
    return $val;
  }
}

=item bc_nagios_file_size($file, $size, $options)

Confirm that $file (which can be a directory) is less than $size
bytes; $options currently unused

=cut

sub bc_nagios_file_size {
  my($file, $size, $options) = @_;
  my($stat) = `/usr/local/bin/stat $file | fgrep Size:`;
  $stat=~/Size:\s+(\d+)\s/;
  $stat=$1;
  debug("SIZE: $stat");
  if ($stat > $size) {return 2;}
  return 0;
}

=item bc_gaim_log_unanswered($options)

Checks GAIM logs for last 3 days to see if there are any conversations
awaiting my input, namely those where:

  - I am not the last speaker AND

  - The other speaker is not someone I'm intentionally ignoring.

I use GAIM's "message notification" plugin, which is much more
immediate, but this is for catching longer-term situations

~/myids.txt should contain a list of ids you use

~/badpeeps.txt should contain a list of people you are OK ignoring

~/imignoredir.txt should contain a list of your ids for which you're OK w/ someone else answering last

$options currently unused

TODO: don't hardcode my homedir (can't use $ENV{HOME}, since test runs
as root, not me)

TODO: should only find most recent file in each directory

=cut

sub bc_gaim_log_unanswered {
  # logs that are very recent probably just mean I haven't had time to
  # answer yet, so add -mmin +1
  my($out, $err, $res) = cache_command("find /home/barrycarter/.gaim/logs/ -mtime -3 -mmin +1 -type f | fgrep -vf /home/barrycarter/imignoredir.txt | xargs -n 1 tail -1 | fgrep -vf /home/barrycarter/myids.txt | fgrep -vf /home/barrycarter/badpeeps.txt", "ignoreerror=1");
  if ($err) {
    print "ERR: $err\n";
    return 2;
  }

  if ($out) {
    print "OUT: $out\n";
    return 2;
  }

  return 0;
}

