#!/bin/perl

# Gave up on learning python (whitespace is significant? blech!), and
# porting bc-excuse-to-learn.py to Perl: this attempts to perform all
# weather functions that other programs have done individually: create
# Voronoi and Delauney maps for multiple data, download latest data,
# maintain db, etc. Once complete, this program will replace many others

# Program attempts to be efficient by using GNU parallel as much as possible

# --nocurl: don't run curl if metar.txt and buoy.txt already exist

require "bclib.pl";

# fixed temporary directory
dodie('chdir("/tmp/bcweatherall")');

# get the METAR and BUOY files in parallel
unless (-f "metar.txt" && -f "buoy.txt" && $globopts{nocurl}) {
  write_file("curl http://weather.aero/dataserver_current/cache/metars.cache.csv.gz | gunzip | tail -n +6 > metar.txt
curl -o buoy.txt http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt
", "commands");
  system("parallel -j 0 < commands");
}

handle_metar_and_buoy("BUOY");

# this subroutine is specific to this program; created since
# METAR/BUOY files are SIMILAR, but not identical; arg is either
# 'METAR' or 'BUOY'

sub handle_metar_and_buoy {
  my($arg) = @_;
  my(@fields, @dbf, @dbv, @hashes, %hash);

  # read file
  my(@reports) = split(/\n/, read_file(lc($arg).".txt"));

  # get headers
  my($headers) = shift(@reports);

  # sky_cover and cloud_base_ft_agl appear >=2 times, but I don't need
  # the latter (only for METAR, but doesnt hurt for BUOY)
  $headers=~s/,sky_cover,/",sky_cover" . $n++ .","/iseg;
  # below only for BUOY (but doesnt hurt METAR either)
  $headers=~s/\#//isg;

  # the headers
  if ($arg eq "METAR") {
    @headers = csv($headers);
  } else {
    @headers = split(/\s+/, $headers);
  }

  # for BUOY, 2nd line is ignorable
  if ($arg eq "BUOY") {shift(@reports);}

  # go thru the reports
  for $i (@reports) {
    if ($arg eq "METAR") {
      @fields = csv($i);
    } else {
      @fields = split(/\s+/, $i);
    }

    # db query + fill hash
    @dbf = ();
    @dbv = ();
    %hash = ();
    for $j (0..$#headers) {
      push(@dbf, $headers[$j]);
      push(@dbv, qq%"$fields[$j]"%);
      $hash{$headers[$j]} = $fields[$j];
    }

    push(@hashes, {%hash});

    # db query
    debug("DBF", @dbf);
    debug("DBV", @dbv);



  }

  

  debug(unfold(@hashes));
}
