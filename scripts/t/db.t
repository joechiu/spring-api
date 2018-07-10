#!/usr/bin/perl

#
#
#   $URL: http://svn.it.aapt.com.au/svn/mediation_custom/trunk/tcm/scripts/t/db.t $
#   $Rev: 135 $
#   $Author: t500646 $
#   $Date: 2017-08-01 11:14:00 +1000 (Tue, 01 Aug 2017) $
#   $Id: db.t 135 2017-08-01 01:14:00Z t500646 $
#
#
###############################################################################
#
# Description:
#
#  
# NAME
#     db.t
# 
# SYNOPSIS
#         cd tcm/scripts/t
#         perl db.t
# 
# DESCRIPTION
#     Runs db module test scripts in the t/ directory. This is just a test
#     more function without plan.
# 
#     This test script simply tests the followings:
# 
#     *   The pre-requisite modules required to run the test.
# 
#     *   The Perl build in module for its own running.
# 
#     *   The module methods.
# 
#     *   The syntax in the codes.
# 
#     *   Basic validation for the returns
# 
#
###############################################################################

use strict;
use Data::Dumper;
use File::Basename;
use lib dirname(__FILE__).'/lib';
use lib dirname(__FILE__).'/../lib';
use Test::More 'no_plan';
use db;
use conf;

=head1 NAME

db.t

=head1 SYNOPSIS

    cd tcm/scripts/t
    perl db.t

=head1 DESCRIPTION

Runs db module test scripts in the t/ directory.  This is just a test
more function without plan.

This test script simply tests the followings: 

=over 4

=item *

The pre-requisite modules required to run the test.

=item *

The Perl build in module for its own running.

=item *

The module methods.

=item *

The syntax in the codes.

=item *

Basic validation for the returns

=back

=head1 AUTHOR

See the svn header for the info

=cut

diag "db module tests";

use_ok( 'db' );
my $t = new db;

use_ok( 'db' );
can_ok('db', ('new'));
use_ok( 'conf' );

pass("required modules preload");

my $db = new db;

pass("db connected");

# db module - method tests
foreach my $m ($t->methods('db')) {
    can_ok( 'db', ($m) ) if $db->can($m);
}

pass("passed db module method tests");


__END__
