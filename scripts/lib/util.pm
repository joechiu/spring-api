package util;

#
# Description:
# DR API utility module: provide file caching, validation, 
#
# Input: NA
# Output: NA
#
###############################################################################

use strict;
use POSIX qw/strftime/;
use Time::HiRes qw/gettimeofday tv_interval/;
use Exporter;
use conf;
use vars qw/@ISA @EXPORT/;
@ISA = qw/Exporter/;
@EXPORT = qw/
    _gettime
    _timediff
/;

our $t2;
$|++;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub cache {
    my $u = shift;
    my $cclean = $u->{cclean};
    my $day = $u->{day};
    my $nn;
    my $msg;
    exit print "Invalid params found" unless $cclean;
    chdir path->{cache};
    if ($day) {
	map { do { $nn++; $msg .= "$_ \n" ; unlink $_ } if -M $_ > $day } glob "*";
    } else {
	map { $nn++; $msg .= "$_ \n"; print "$msg\n"; print unlink $_ } glob "*";
    }
    exit print "$msg\n $nn cleaned\n" if $nn;
    exit print "No caches found" unless $nn;
}

# validate pick date 
sub validate {
    my $u = shift;
    my $pt = shift;
    $pt || return "error: no picktime found";
    $pt =~ s/\s//g;
    $pt =~ /\d{4}\W\d{2}\W\d{2}/ || return "error: invalid picktime";
    return undef;
}

sub _gettime {
    return [ gettimeofday ];
}

sub _timediff {
    my $t1 = shift || _gettime;
    $t2 = _gettime;
    my $diff = tv_interval($t1, $t2);
    return $diff;
}

1;

__END__
