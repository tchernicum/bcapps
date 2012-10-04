#!/bin/perl

# Another program that helps only me (if that), this tracks my weight
# loss and estimates the time until I reach my non-obese and then
# non-overweight goals, starting from when I started tracking calories

require "/usr/local/lib/bclib.pl";

# my weight and when I started tracking calories
$stime = 1347412858;
$startime = stardate($stime-6*3600);
$sweight = 191.8;

# obtain all weights and do linear regression (experimental for now)
%weights = obtain_weights($stime);

# to make life easier, converting times to days since $stime
for $i (sort keys %weights) {
  push(@x, ($i-$stime)/86400);
  push(@y, $weights{$i});
  push(@z,log($weights{$i}));
}

# the regression coefficients for standard and log regression
($b,$m) = linear_regression(\@x,\@y);
# <h>I've always wanted to name a variable $blog for a good reason!</h>
($blog,$mlog) = linear_regression(\@x,\@z);

debug("$m $b and $mlog $blog");

# target weights (borders for obese, overweight, normal, and severely underweight) [added midpoints 30 Sep 2012 JFF]
@t=(180,165,150,135,120,105,90);

print "\n";

# I store my current weight in /home/barrycarter/TODAY/yyyymmdd.txt
# files as 'x#%%' where x is my weight in pounds [there used to be
# numbers before the % signs but not any more]

# go backwards through days until finding a weight
for ($i=0;;) {
  $stardate = strftime("%Y%m%d",localtime(time()-86400*$i++));
  # last result is the one I want
  $res= `fgrep '#%%' /home/barrycarter/TODAY/$stardate.txt | tail -1`;
  if ($res) {last;}
}

# from $res, extract date and weight
$res=~s/^(\d{6})//;
$date = $1;
$res=~s/([\d\.]+)\#%%//;
$wt = $1;

# convert date to seconds
$secs = datestar("$stardate.$date");

# TODO: use linear regression, not first/last points?

# compute weight loss and targets time (linear)
$tloss = $sweight-$wt;
$days = ($secs-$stime)/86400;

print "Starting weight: $sweight at $startime\nCurrent weight: $wt at $stardate.$date\n\n";

printf("Loss of %0.2f lbs in %0.2f days\nLoss/day: %0.2f lbs\nLoss/week: %0.2f lbs\n\n", $tloss, $days, $tloss/$days, $tloss/$days*7);

printf("Linear Regression: %0.2f + %0.4f*t = %0.2f\n\n", $b, $m, $b+$m*$days);

# time to targets (linear)
for $i (0..$#t) {
  $time[$i] = ($wt-$t[$i])/($tloss/$days)*86400+$secs;
  # rtime = linear w regression
  $rtime[$i] = ($t[$i]-$b)/$m*86400+$stime;
  print strftime("Achieve $t[$i] lbs (linear): %c\n",localtime($time[$i]));
  print strftime("Achieve $t[$i] lbs (linreg): %c\n",localtime($rtime[$i]));
  print "\n";
}

print "\n";

# weight loss (log)
$pctloss = $wt/$sweight;

printf("Loss of %0.2f%% in %0.2f days\nLoss/day: %0.2f%\nLoss/week: %0.2f%\n\n", 100*(1-$pctloss), $days, 100*(1-($pctloss**(1/$days))), 100*(1-($pctloss**(7/$days))));

# time to targets (log)
for $i (0..$#t) {
  $ltime[$i] = (log($wt)-log($t[$i]))/(log($sweight)-log($wt))*$days*86400+$secs;
  print strftime("Achieve $t[$i] lbs (log): %c\n",localtime($ltime[$i]));
}

print "\n";
