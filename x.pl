
use strict;
use Data::Dumper ;

my @columns = (1,2,3,4,5,6,7,8,9,10,11,12);
my $db = "rev";

print scalar @columns;
#print Dumper(@columns);
print "\n";
# (always set to 0 in my checkpoint files).
#if ($db eq "rev" && @columns > 12) {
#    splice(@columns,9,1);
#}
splice(@columns,9,2);

print scalar @columns;
print Dumper([@columns]);
print "\n";

__DATA__

use Env qw(PGDATABASE GIT_DIR);


print $PGDATABASE . "\n";

if (defined($GIT_DIR)) {
  print "foudn it\n";
  if ( ! -d $GIT_DIR ) {
    mkdir $GIT_DIR;
  }
}
