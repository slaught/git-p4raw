#!/usr/bin/perl

use strict vars, subs;
use warnings;
use Env qw(PGDATABASE GIT_DIR);
use Scriptalicious;
use Maptastic;
use Maptastic::DBI qw(row_iter);
use FindBin qw($Bin);
use List::Util qw(sum max min);
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use DBI;
use Cwd;
use IO::Handle;
use File::Path qw(rmtree);
use Fatal qw(:void open);
use Digest::SHA1;
use Digest::MD5 qw(md5_hex);
use Text::Wrap;
$Text::Wrap::columns = 72;
use JSON 1.15;
use YAML;
use Encode;


# this is the set of tables that we load from the Perforce repository.
# everything else - views, client maps, etc, I didn't see to be
# interesting historically.
my %wanted =
	( "db.desc" => "change_desc",
#	  "db.integed" => "integed",
	  "db.change" => "change",
	  "db.depot" => "depot",
	  "db.revcx" => "revcx",
	  "db.user" => "p4user",
	  "db.rev" => "rev",
#	  "db.label" => "label",
	  "db.change_branches" => "change_branches",
	  "db.change_parents" => "change_parents",
	  "db.marks" => "marks",
	  "db.rev_marks" => "rev_marks",
	  "db.change_marks" => "change_marks",
	);

print %wanted;
print "\n";

my @a = qw(test word here);
print @a ;
print "\n";
foreach  my $i (@a) {
  print $i . "\n";
}
