#!/usr/bin/perl

#
#
#   $URL: http://svn.it.aapt.com.au/svn/mediation_custom/trunk/tcm/scripts/t/conf.t $
#   $Rev: 135 $
#   $Author: t500646 $
#   $Date: 2017-08-01 11:14:00 +1000 (Tue, 01 Aug 2017) $
#   $Id: conf.t 135 2017-08-01 01:14:00Z t500646 $
#
#
###############################################################################
#
# Description:
#
# NAME
#     conf.t
# 
# SYNOPSIS
#         cd tcm/scripts/t
#         perl conf.t
# 
# DESCRIPTION
#     Runs conf module test scripts in the t/ directory. This is just a test
#     more function without plan.
# 
#     This test script simply tests the followings:
# 
#     *   The pre-requisite modules required to run the test.
# 
#     *   The Perl build in module for its own running.
# 
#     *   The validation of the comm configuration.
# 
#     *   Basic validation for the returns
# 
# AUTHOR
#     See the svn header for the info
# 
# 
#
###############################################################################

use strict;
use Data::Dumper;
use File::Basename;
use lib dirname(__FILE__).'/lib';
use lib dirname(__FILE__).'/../lib';
use Test::More 'no_plan';
use xc;

=head1 NAME

conf.t

=head1 SYNOPSIS

    cd tcm/scripts/t
    perl conf.t

=head1 DESCRIPTION

Runs conf.t in the t/ directory.  This script implement a test
more function without plan.

This test script simply tests the followings: 

=over 4

=item *

The pre-requisite modules required to run the test.

=item *

The Perl build in module for its own running.

=item *

The methods in the module.

=item *

The syntax in the codes.

=item *

The basic validation of the comm configuration.

=back

=head1 AUTHOR

See the svn header for the info

=cut

diag "conf module tests";

use_ok( 'tt' );

use_ok( 'xc' );

pass("required modules preload");

my $t = new tt;

# method tests
can_ok( 'xc', ('UPDATE') );

pass("passed module method tests");

pass("change config module worked");


__END__
