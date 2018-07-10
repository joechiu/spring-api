#!/usr/bin/perl

#
# NAME
#     spring-api.pl
# 
# SYNOPSIS
#       usage:
#             perl spring-api.pl pickdate nocache clean day
#
#	Input: action, picktime, clean and day
#	Output: cache and result
# 
# DESCRIPTION
#         Provide a lite caching mechanism for heavy load processes.
# 
#         Provide a simplistic method to control the data transferring from end to end.
# 
# CACHEFLOW
#         1. validate and check the query existence
#         2. implement the db module to make a query to cache the data retrieved from database if not existing
#         3. fresh the cache if receive no cache signal
#         4. return the cache md5 hex
# 
# GITHUB
#     https://github.com/joechiu/spring-api
# 
#
###############################################################################

use strict;
use File::Basename;
use lib dirname(__FILE__).'/lib';
use Digest::MD5 qw(md5_hex);
use conf;
use util;
use db;

my $db = new db;
my $u = new util;
my @cols = s2a dbc->{cols};
# action
my $act = shift || exit print $db->logit("error: no action found");
# get pick date from argv
my $pt = $u->{pickdate} = shift;
my $nocache = $u->{nocache} = shift;
# cache clean
my $cclean = $u->{cclean} = shift;
# keep the caches for the given day 
my $day = $u->{day} = shift;
my $ret;

my $t1 = _gettime;

$u->cache if $act =~ /^cache$/i;

my $err = $u->validate($pt);
exit print $db->logit($err) if $err;

$db->{cfile} = path->{cache}.'/'.md5_hex($pt);
$db->logit("cache file: $db->{cfile}, cache: $nocache");

if ($nocache eq "true") {
    unlink $db->{cfile} if -e $db->{cfile};
    $ret = $db->query($pt);
} else {
    if (!-e $db->{cfile}) {
	$ret = $db->query($pt);
    }
}

$u->{real} = _timediff($t1);
my $msg = join ",", map { "'$_':'$u->{$_}'" } qw/pickdate nocache cclean day real/;
lp("{$msg}");

# return the error message which handled by the db module
exit print $ret if $ret;
print $db->{cfile};

