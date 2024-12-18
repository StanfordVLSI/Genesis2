package MyLib;
use warnings;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use Exporter;

@ISA = qw(Exporter);
$VERSION = '1.00';

# ****************  METHOD 1 FOR INHERITING ALL METHODS *****************
# To make a function available in the name space of the including package,
# simply place it in the EXPORT or EXPORT_OK lists. Example:
#    @EXPORT = qw(funcName);
@EXPORT = qw(funcName);
@EXPORT_OK = qw();
# ***********************************************************************



# ****************  METHOD 2 FOR INHERITING ALL METHODS *****************
# Uncomment the following line to activate inheritance
push (@Genesis2::UniqueModule::ISA, qw(MyLib));
# ***********************************************************************

################################################################################
###################### ACTUAL TypeConv CODE STARTS HERE #######################
################################################################################
sub funcName{
    print STDERR "\n\n*************** Function: I WON!! ****************\n\n";
}
sub methodName{
    print STDERR "\n\n*************** Method: I WON!! ****************\n\n";
}

1;
