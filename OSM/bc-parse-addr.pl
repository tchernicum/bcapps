#!/bin/perl

# adds ABQ street addresses to OSM (openstreetmap.org)

=item proc

Procedure to obtain ABQ centroid address list:

  - download and unzip http://www.cabq.gov/gisshapes/base.zip

  - note that base.shp.xml says:

<projcsn Sync="TRUE">
NAD_1983_HARN_StatePlane_New_Mexico_Central_FIPS_3002_Feet
</projcsn>

and http://resources.esri.com/help/9.3/arcgisserver/apis/rest/pcs.html
tells us this is SRID 2903

  - shp2pgsql -s 2903 base abq3 | psql > /dev/null;: (use version 8.2 of
  shp2pgsql or later; earlier versions will work, but not yield any
  useful information)

WGS84 is SRID4326
(http://postgis.refractions.net/docs/using_postgis_dbmanagement.html),
so

ALTER TABLE abq3 ADD centroid TEXT;
UPDATE abq3 SET centroid = ST_ASTEXT(ST_TRANSFORM(ST_CENTROID(the_geom),4326));

<h>COALESCE would make a good street name</h>

And get the data:

ALTER TABLE abq3 ADD data_export TEXT;

UPDATE abq3 SET data_export = TRIM(
COALESCE(lot,'')||'|'||
COALESCE(block,'')||'|'||
COALESCE(subdivisio,'')||'|'||
COALESCE(streetnumb,0)||'|'||
COALESCE(streetname,'')||'|'||
COALESCE(streetdesi,'')||'|'||
COALESCE(streetquad,'')||'|'||
COALESCE(apartment,'')||'|'||
COALESCE(pin,'')||'|'||
COALESCE(centroid,'')
);

SELECT data_export FROM abq3; (output of this is in db/abqaddr.bz2)

=cut

=item NOTES

For chunk 1, obtained changeset id: 12068062


=cut

require "/usr/local/lib/bclib.pl";

# TODO: add comments/tags to changeset (ie, metadata)

# uploading in small chunks of 100 addr each (sharing changeset, but
# not HTTP connection); chunkstart/end is now an option to prog
$changesetid = $globopts{changesetid};
$chunkstart = $globopts{chunkstart};
$chunkend = $globopts{chunkend};

unless ($changesetid && $chunkstart && $chunkend) {
  die ("Usage: $0 --changesetid=x --chunkstart=x --chunkend=x");
}

# file for XML and XML headers
open(B,">/tmp/abqaddresses-$chunkstart-$chunkend.xml");
print B "<osmChange><create>\n";

# sort the address in 'pin' order (no real reason why I chose this field)
unless (-f "/tmp/abqsortbypin.txt") {
  system("bzcat /home/barrycarter/BCGIT/db/abqaddr.bz2|sort -t'|' -k9 > /tmp/abqsortbypin.txt");
}

# NOTE: I manually edited /tmp/abqsortbypin.txt after the above to
# remove the addresses I'd already added via changeset 12068601

open(A,"/tmp/abqsortbypin.txt");

while (<A>) {
  
  # HTML escaping
  s/\&/&amp;/isg;
  s/\'/&apos;/isg;

  # counting here means I'm counting addresses I don't even use, but is faster
  # number these so I can upload them one batch at a time
  $count++;

  # this controls which ones I upload this batch (hardcoding here is
  # bad, but this is ultimately a 'single-use' program)

  unless ($count>=$chunkstart && $count<=$chunkend) {next;}

  $_ = trim($_);
  ($lot, $block, $subdivision, $num, $sname, $stype, $sdir, $apt, $pin,
$latlon) = split(/\|/, $_);

  # if addr is 0 or missing, pointless
  # 99999 also indicates some sort of weirdness
  unless ($num && $num != 99999) {next;}

  # get lat lon (or skip if NA)
  unless ($latlon=~/^POINT\((.*?)\s+(.*?)\)$/) {next;}
  ($lon, $lat) = ($1, $2);

  $data = osm_cache_bc($lat,$lon);

  if ($data=~/$num $sname/is) {
    debug("FOUND($n) $num $sname in $sha!");
    next;
  }

  # count of addresses I actually add
  $truecount++;

  # determine street address (base.zip doesn't include it sadly)
  my($saddr) = "$num $sname $stype $sdir";
  if ($apt) {$saddr = "$saddr #$apt";}

  # strip extra spaces
  $saddr=~s/\s+/ /isg;
  $saddr=trim($saddr);

  # this is the XML to add this address
  # meta-tags will appear in changeset only
my($xml) = << "MARK";
<node id="-$count" lat="$lat" lon="$lon" changeset="$changesetid">
<tag k='name' v='$saddr' />
<tag k='lot' v='$lot' />
<tag k='block' v='$block' />
<tag k='subdivision' v='$subdivision' />
<tag k='pin' v='$pin' />
</node>
MARK
;

print B $xml;

  # at this point, we need to add (or at least record that we need to add)
  push(@{$list{$sha}}, $_);
}

close(A);

# footer for xml
print B "</create></osmChange>\n";
close(B);

# and the command I should run (but don't actually run it)
$cmd = "curl -f -Ss -n -d \@/tmp/abqaddresses-$chunkstart-$chunkend.xml -XPOST http://api.openstreetmap.org/api/0.6/changeset/$changesetid/upload >& /tmp/output-chunkstart-$chunkstart.txt";

# if none at all, pointless
unless ($truecount) {die "No addressed added, not running curl";}

debug("CMD",$cmd);

# $res = system($cmd);

debug("RES: $res");

# expect success, report failure
if ($res) {
  die "Something is not right, something is quite wrong!";
}

=item tags_for_changeset



=cut
