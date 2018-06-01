package conf;

#
#   $URL: http://svn.it.aapt.com.au/svn/mediation_custom/trunk/tcm/scripts/lib/conf.pm $
#   $Rev: 131 $
#   $Author: t500646 $
#   $Date: 2017-07-24 11:15:37 +1000 (Mon, 24 Jul 2017) $
#   $Id: conf.pm 131 2017-07-24 01:15:37Z t500646 $
#
###############################################################################
#
# Description:
# TCM configuration module. It resolves the plain text config.ini under config
# to a hash with paired key and value and creates functions to return the 
# settings.
#
# Input: NA
# Output: NA
#
###############################################################################

use Exporter;
use File::Basename;
use POSIX qw/strftime/;
use Config::Tiny;
use vars qw/@ISA @EXPORT/;

@ISA = qw/Exporter/;
@EXPORT = qw/
    s2a app dbc logc path
/;

# string config to array
sub s2a { split /\W\s*/, shift }

my $path = dirname(__FILE__)."/../../config";
my $file = "config.ini";

# Set for Hash: Config::TinyX::set;
our $C = Config::Tiny->read("$path/$file");

sub app	    { $C->{comm} }
sub dbc	    { $C->{db} }
sub logc    { $C->{log} }
sub path    { $C->{path} }

1;
