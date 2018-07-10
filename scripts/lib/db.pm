package db;

#
# Description:
# DB module for DR API to create an db handler to connect to mysql database and 
# provides the well data retrive functions.
#
# Input: NA
# Output: NA
#
###############################################################################

use DBI;
use strict;
use lib '.';
use POSIX qw/strftime/;
use Sys::Hostname;
use IO::File;
use Time::HiRes qw/gettimeofday tv_interval/;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;
use vars qw/ 
    @ISA
    @EXPORT
    $dbh
    $sql
    $errors
    $TEST
/;
require Exporter;
@ISA = qw/ Exporter /;
@EXPORT = qw/
    $dbh
    tt
    lp
    $TEST
/;

use conf;
use constant LOGDIR => logc->{path};
use constant LOGLEN => logc->{len};
use constant LOGAGE => logc->{age};

our $dbh;
my $ERRDEBUG = 0;
my $DEBUG;

sub run;
sub  pe; # perl catch
sub  lp; # log
sub   l; # log
sub   p; # print
sub   d; # dump
sub   w; # write
sub   t; # test

my $db;	
my $host;
my $dbi;	
my $user;
my $pass;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    my %c = @_;
    map { $self->{lc($_)} = $c{$_} } keys %c;

    $self->{errstr} = undef;
    $self->{errarr} = [];
    $DEBUG = $self->{debug};

    $self->dbh;

    return $self;
}

sub dbh {
    my $self = shift;

    $db	  = $self->{db}	  || dbc->{db};
    $host = $self->{host} || dbc->{host};
    $user = $self->{user} || dbc->{user};
    $pass = $self->{pass} || dbc->{pass};
    $dbi  = "DBI:mysql:$db:$host";

    # try to get dbh
    eval  { 
	$dbh = DBI->connect( $dbi, $user, $pass, {
	    PrintError => 0,
	    AutoCommit => 0,
	    RaiseError => 1,
	}); 
    };

    if ($@) {
	die "cannot connect to db - $@";
    }

    return $dbh;
}

# transaction
sub tt {
    my $self = shift;
    my $sqls = shift || [];

    unless (@$sqls) {
	return $self->dberr( "no sql found!" );
    }

    eval { 
	foreach my $sql (@$sqls) {
	    $dbh->do($sql) || 
		return $self->dberr( $dbh->errstr );
	}
	$dbh->commit;
    };

    if ( $@ ) {
	$dbh->rollback;
	return $self->dberr( $@ );
    }

    $self->{errstr} = undef;
    0;
}

# db error
sub dberr { 
    my $self = shift;
    my $msg = shift || $self->errstr;
    $self->{errstr} = $msg unless $self->errstr;
    lp "error: $msg\n" if $msg;
    return "error: $msg";
}

sub row {
    my $self = shift;
    my $sql = shift;
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    my $h = $sth->fetchrow_hashref || return undef; 
    return $h;
}

sub array {
    my $self = shift;
    my $sql = shift;
    my $a = [];
    eval {
	$a= $dbh->selectall_arrayref($sql, { Slice => [] });
    };
    $self->pe("array - $sql");
    return $a;
}

sub query {
    my $db = shift;
    my $pt = shift || return undef;
    my @cols = s2a dbc->{cols};
    my $query = sprintf qq(
	    SELECT %s
	    UNION ALL
	    SELECT %s
	    FROM cab_trip_data
	    WHERE date(pickup_datetime) = '$pt'
	    INTO OUTFILE '%s'
	    FIELDS TERMINATED BY ','
	    ENCLOSED BY '"'
	    LINES TERMINATED BY '\n';
	), 
	'"'.join('","',@cols).'"',
	join(',', @cols),
	$db->{cfile};
    $db->{query} = $query;
    return $db->tt([$query]);
}

# print errors - private
sub pe { 
    my $self = shift;
    my $msg = shift;
    if ($@) {
	$@ =~ /(.*?)\n/;
	$self->{errstr} = "$msg - $1";
	lp "$msg - $1";
    }
}

sub p {
    print shift, "\n" if $DEBUG;
}

sub logit {
    my $self = shift;
    my $msg = shift || $self->{msg};
    lp $msg;
    return $msg;
}

# log print - public
sub lp {
    my ($msg, $postfix) = @_;
    my $path = LOGDIR;
    my $now = strftime("%H:%M:%S", localtime);
    my $today = strftime("%Y%m%d", localtime);
    my $head = logc->{head};
    my $file = "$head-$today";
    chomp $msg;
    $msg = substr($msg, 0, LOGLEN).$postfix;
    my $log = "[$today $now]\t$msg\n";
    my $logfile = "$path/$file.log";
    my $fh = new IO::File;
    map { unlink $_ if -M $_ > LOGAGE } glob "$path/$head-*";
    $fh->open(">> $logfile");
    print $fh $log;
}

sub neatit {
    my $self = shift;
    my $str = shift;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    return $str;
}

sub errstr {
    my $self = shift;
    return $self->{errstr};
}

sub err {
    my $self = shift;
    return $self->{errstr};
}

sub errhash {
    my $self = shift;
    my $hash = shift;
    push @{$self->{errarr}}, $hash;
}

sub usage {
    my $self = shift;
    print qq(Usage: $0 \n);
    exit(1);
}

1;
