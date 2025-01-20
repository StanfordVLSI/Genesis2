#!/usr/bin/env perl

# This script (INSTALL.pl) should only be called from its wrapper
# INSTALL.sh, which basically 
# 1. makes sure that /usr/bin/env perl exists and
# 2. makes sure that INSTALL.pl was called from the correct directory.

use strict;
use warnings;

my $GENESIS_DIR = "/genesis";

if (defined($ENV{GENESIS_DIR})) {
    $GENESIS_DIR = $ENV{GENESIS_DIR};

    # Make sure it starts with a slash; that's easy to forget.
    if (! ($GENESIS_DIR =~ /^\//)) { $GENESIS_DIR = "/".$GENESIS_DIR; }

    print "\n";
    print "Using environment variable \$GENESIS_DIR = \"$GENESIS_DIR\"\n";
    print "\n";
    print "If you don't know what this means, you should probably use\n";
    print "^C to kill this job, then undefine the environment variable\n";
    print "GENESIS_DIR and then restart.\n";
    print "\n";
    print "In csh you do this: \"unset GENESIS_DIR\"\n\n";
    print
            "Hit ^C to exit, else hit the \"Enter\" key to continue.\n\n"
            ;
        my $continue = <STDIN>;
}

my $DBG=1;
my $partial_install=1; # If 1, only install a small portion of the gui as a test.

verify_directory();

# We should be starting in "<installdir>/gui/configs/install"
# if ($DBG) { print "Yoo hoo here I am\n".`pwd`."\n"; }

# Now we should be in "<installdir>"

my $cname = get_name_of_config_file(); # E.g. "stanford"
if ($DBG) { print "Using config filename \"$cname\"\n\n"; }

my @config_vars = (              # Examples
                   "SERVER_URL", # http://www-vlsi.stanford.edu
                   "sep",
                   "CGI_DIR",    # /usr/lib/cgi_bin/genesis
                   "CGI_URL",    # /cgi-bin/genesis
                   "sep",
                   "GUI_HOME_DIR", # /var/www/homepage/genesis
                   "GUI_HOME_URL", # /genesis
                   "sep",
                   "DESIGN_LIST"   # $GUI_HOME_DIR/configs/design_list_stanford.txt
                   );

my $cfile = "../CONFIG_$cname.txt";
my %CONFIG;

# If existing config file $config exists, use that;
# otherwise, build a new one using user-supplied info.

use_existing_or_build_new_config_file($cfile);

# Show contents of config file to user, ask for verification.

verify_config_file($cfile, @config_vars); print "\n\n";

# If existing index file ../index_$cname.htm exists, offer to use that;
# otherwise, build a new one using the template.

find_or_build_index_file($cname);

##########################################################################
# We are in <installdir>/gui/configs/install;
# need to
#  1. pop up to <installdir>
#  2. cp -R gui/* <destdir> (or? cp --preserve=timestamp -R $sourcedir $destdir ?)
#     (i.e. cp -R gui/* /var/www/homepage/genesis)

#  1. pop up to <installdir>

if (! -d "../../../gui") {
    die "ERROR: Where are we?  Should have started in <installdir>/gui/configs/install.";
}

chdir("../../..");

use Cwd 'getcwd';           # Could also use simply 'cwd'---what's the diff?
my $install_dir = getcwd(); # E.g. "/home/steveri/installgui"

if ($DBG) { print "Now we're here: $install_dir\n\n"; }

# Now it's time to copy everything from here (<installdir>/gui)
# to there (GUI_HOME_DIR = e.g. /var/www/homepage/genesis)
# Remember:
#  2. cp -R gui/* <destdir> (or? cp --preserve=timestamp -R $sourcedir $destdir ?)
#     (i.e. cp -R gui/* /var/www/homepage/genesis)

my $ghd = $CONFIG{GUI_HOME_DIR}; # E.g. "/home/steveri/installgui"

print "Copying files from source to dest\n";

# my $syscmd = "cp -R gui/* $ghd";
my $syscmd =
    $partial_install ?
    "cp -Rf gui/configs/install/* $ghd" :  # Do this if we're testing the script
    "cp -Rf gui/* $ghd" ;                  # Do this if we're installing for realsies.

if ($DBG) { print "$syscmd\n"; }
my $syserr = `$syscmd`;

if ($syserr ne "") {
    die "ERROR ?copy error?: $syserr\n\n";
}

print "okay now check $ghd for new stuff...\n\n";

# Remember $install_dir = e.g. "/home/steveri/installgui"

# Remember: my $ghd = $CONFIG{GUI_HOME_DIR}; # E.g. "/var/www/homepage/genesis"
chdir($ghd);

############################################################################
## Link to site-appropriate config file.
#  ln -sf $config CONFIG.TXT
#  ls -l CONFIG.TXT         # Confirm successful link

# Remember $cname = e.g. "stanford" or "cmu"
my $config = "configs/CONFIG_$cname.txt";
if (! -e "$ghd/$config") { die "ERROR: Could not find $ghd/$config.  Why?\n"; }

print "Initiating link to config file \"CONFIG.TXT\" -> \"$config\"...\n";
my ($oldfile,$newfile) = ($config,"CONFIG.TXT");
if (-e $newfile) {
    print "Deleting existing $newfile...\n";
    unlink($newfile) or die "Can't delete existing config file \"$newfile\": $!\n";
}
symlink($oldfile,$newfile) or die "Can't create the link from $oldfile to $newfile:\n$!\n";

if ($DBG) { print
    "Did it work?  Try this:\n".
    "ls -l $ghd/$newfile\n\n\n";
        }

############################################################################
## Link to site-appropriate index file.
#  ln -sf $index index.htm
#  ls -l index.htm         # Confirm successful link

# Remember $cname = e.g. "stanford" or "cmu"
my $index  = "configs/index_$cname.htm";
if (! -e "$ghd/$index")  { die "ERROR: Could not find $ghd/$index.  Why?\n"; }
    
print "Initiating link to index file \"index.htm\" -> \"$index\"...\n";
($oldfile,$newfile) = ($index,"index.htm");
if (-e $newfile) {
    print "Deleting existing $newfile...\n";
    unlink($newfile) or die "Can't delete existing config file \"$newfile\": $!\n";
}
symlink($oldfile,$newfile) or die "Can't create the link from $oldfile to $newfile:\n$!\n";

if ($DBG) { print
    "Did it work?  Try this:\n".
    "ls -l $ghd/$newfile\n\n\n";
        }

# FINALLY: make sure cgi is all set up
# something like: ln -s GUI_HOME_DIR/cgi $CGI_DIR
# e.g. ln -s /var/www/homepage/genesis/cgi /usr/lib/cgi_bin/genesis

my $cgidir = $CONFIG{CGI_DIR};
($oldfile,$newfile) = ("$ghd/cgi",$cgidir);
if (! -d "$oldfile")  { die "ERROR: Could not find cgi dir $oldfile.  Why?\n"; }

if (-e $newfile) {
    print "Deleting existing $newfile...\n";
    unlink($newfile) or die "Can't delete existing config file \"$newfile\": $!\n";
}
symlink($oldfile,$newfile) or die
    "Can't create the link from $oldfile to $newfile:\n".
    "$!\n\n".
    "Try this (should succeed without error):\n".
    "touch $newfile\n";

if ($DBG) { print
    "Did it work?  Try this:\n".
    "ls -l $newfile\n\n\n";
        }

exit -1;


##########################################################################################
# If existing index file ../index_$cname.htm exists, offer to use that;
# otherwise, build a new one using the template.

sub find_or_build_index_file {
    my $cname = shift @_;

    my $ixfile = "../index_$cname.htm";
    my $template = "../index_template.htm";

    if (-f $ixfile) {
        print
            "------------------------------------------------------------------------\n".
            "Found existing index file \"$ixfile\".\n".
            "If you don't want to use this file, then\n".
            "  1. ^C to kill this install script;\n".
            "  2. Rename, move or delete \"$ixfile\";\n".
            "  3. Restart the install script.\n\n".
            "Otherwise, hit the \"Enter\" key to continue.\n\n"
            ;
        my $continue = <STDIN>;
        return;
    }
    print
        "\nDesign \"$cname\" does not yet appear to have\n".
        "an associated index file \"$ixfile\".\n\n".
        "I will attempt to create one for you using\n".
        "the generic template \"$template\".\n"
        ;

    # replace "FULL_CGI_URL" with "SERVER_URL"."CGI_URL"
    # E.g. "http://www-vlsi.stanford.edu"."/cgi-bin/genesis/"

    my $fcu = $CONFIG{SERVER_URL}.$CONFIG{CGI_URL}."/";
    if ($DBG) { print "fcu = $fcu\n"; }

    open TEMPLATE, "<$template" or die "Could not read \"$template\"\n";
    my @template = <TEMPLATE>;
    close TEMPLATE;

    open IXFILE, ">$ixfile" or die "Could not create \"$ixfile\"\n";

    # replace "FULL_CGI_URL" with "SERVER_URL"."GUI_HOME_URL"

    foreach my $line (@template) {
        $line =~ s/FULL_CGI_URL/$fcu/g;
        print IXFILE "$line";
    }
    close IXFILE;

    print "\nCreated index file \"$ixfile\".\n\n";

#    print
#        "Wanna check it?\n".
#        "diff ../index_template.htm $ixfile\n".
#        "diff ../index_stanford.htm $ixfile\n".
#        "??\n";
#    exit -1
}

sub verify_directory {
    my $DBG = 0;
    
    use Cwd 'abs_path';
    my $ps_ap = abs_path($0);
    if ($DBG) { print "full path of perl script is $ps_ap\n\n"; }
    
    use File::Basename;
    my $ps_dir  = dirname($ps_ap); 
    if ($DBG) { print "called perl script dir is $ps_dir\n\n"; }
    
    use Cwd 'getcwd'; # Could also use simply 'cwd'---what's the diff?
    my $cwd = getcwd();
    if ($DBG) { print "cur working dir        is $cwd\n\n"; }

    if ($ps_dir ne $cwd) {
        my $ps_basename = basename($0);
        die "ERROR: Looks like we started from the wrong directory.  Try this\n\n".
            "    cd $ps_dir; ./$ps_basename\n\n";
    }
        
}

sub get_name_of_config_file {
    my @configs = glob("../CONFIG*.txt");
    if (@configs) {
        print "Found the following existing config files:\n";
        foreach my $f (@configs) {
            $f =~ /CONFIG_(.*)[.]txt/;
            printf("    %-24s (%s)\n", $1, $f);
        }
    }
    
    print "\n";
    print "Please type the name of an existing config file (e.g. \"stanford\"),\n";
    print "BUT ONLY IF IT IS ALREADY CONFIGURED FOR YOUR SITE!\n";
    print "Otherwise (safer) choose a new name to create a new config file\n";
    print "\n";
    
    print "\n";
    print "Type the name of the config file (existing or new) here (e.g. \"stanford\"): ";
    
    my $cname;
    while ($cname = <STDIN>) {
        chomp($cname);
        if ($cname =~ /^[a-zA-Z0-9_]+$/) { last; }
        print "\nPlease use only alphanumeric chars (a-z,A-Z,0-9) or underbar\n";
        print "\n";
        print "Type the name of the config file (existing or new) here: ";
    }
    
    return $cname;
}

sub getvar {
    my $vartext = shift @_;
    my $desc    = shift @_;
    my $example = shift @_;

    print "\n\nThe $vartext is $desc.\n";

    my $done = 0;
    while (! $done) {
        print "\n";
        print "Please type in the $vartext ";
        print "(e.g. \"$example\"): ";

        my $varval = <STDIN>; chomp($varval);
        if ($varval eq "") { $varval = $example; }

        print "\nYou typed \"$varval\".  Is this correct (y or n)? ";
        my $response = <STDIN>; chomp($response);
        $done = ($response eq "y");
        print "\n\n\n";
        if ($done) { return $varval; }
    }
}

    
sub use_existing_or_build_new_config_file {
    my $cfile = shift @_; # e.g. "../CONFIG_cmu.txt"

    if (-f $cfile) {
        print "You chose existing gui config \"$cfile\"\n";
        return;
    }
    print "Creating new gui config \"$cfile\"\n\n";

    # See above for globals "@config_vars" and "%CONFIG"

    my $var = "SERVER_URL";
    $CONFIG{$var} = getvar("server URL",
                           "the URL people use to visit your site",
                           "http://www-vlsi.stanford.edu");

    $var = "CGI_DIR";
    do {
        $CONFIG{$var} = getvar("cgi directory",
                               "where cgi files live on your server",
                               "/usr/lib/cgi-bin");
        if (! -d $CONFIG{$var}) {
            print "WARNING: No such directory \"$CONFIG{$var}\"; please try again.\n";
        }
    }
    until (-d $CONFIG{$var});
    $CONFIG{$var} .= $GENESIS_DIR;               # Default $GENESIS_DIR = "/genesis";
    print "Okay now $var = $CONFIG{$var}\n";

    $var = "CGI_URL";
    $CONFIG{$var} = getvar("cgi URL",
                           "the pathname your server uses to access cgi files",
                           "/cgi-bin");
    $CONFIG{$var} .= $GENESIS_DIR;               # Default $GENESIS_DIR = "/genesis";
    print "Okay now $var = $CONFIG{$var}\n";

    $var = "GUI_HOME_DIR";
    $CONFIG{$var} = getvar("webserver home directory",
                           "where \"/\"-level html files live on your server",
                           "/var/www/homepage");
    $CONFIG{$var} .= $GENESIS_DIR;               # Default $GENESIS_DIR = "/genesis";
    print "Okay now $var = $CONFIG{$var}\n";

    verify_gui_home_dir();

    # E.g.
    # GUI_HOME_URL    /genesis
    # DESIGN_LIST     /var/www/homepage/genesis/configs/design_list_stanford.txt

    $CONFIG{"GUI_HOME_URL"} = $GENESIS_DIR; # Default $GENESIS_DIR = "/genesis";
    $CONFIG{"DESIGN_LIST"} =
        $CONFIG{"GUI_HOME_DIR"}."/configs/design_list_".$cname.".txt";

    print "Okay writing new config file \"$cfile\"...\n";
    open CONFIG, ">$cfile" or die $!;

    foreach my $v (@config_vars) {
        if ($v eq "sep") { print CONFIG "\n"; }
        else {
            printf CONFIG "%-12s %s\n", $v, $CONFIG{$v} or die "ERROR: Could not print to \"$cfile\"";
        }
    }
    print CONFIG "\n#END#\n";
    close CONFIG;

    print "\nCreated config file \"$cfile\".\n\n";
}

sub verify_config_file {
    my $cfile = shift @_;
    my @config_vars = @_;

    print "\nConfig file \"$cfile\" looks like this:\n";

    my $halfline = "---------------------------------------------";

    print "/$halfline$halfline\n";
    open CONFIG, "<$cfile";
    foreach my $line (<CONFIG>) {
        print "|| $line";
        if ($line =~ /^\s*([^\#]\S*)\s+([^\#]\S*)/) {
            $CONFIG{$1} = $2;
        }
    }
    print "\\$halfline$halfline\n";
    close CONFIG;

    print "\n";
    print "If this information doesn't look right,";
    print "please ^C out of this\nand start over; ";
    print "next time choose 'create a new config file'.\n";
    print "\n";
    print "(Alternatively, you may choose to edit \"$cfile\" directly\n";
    print "so that it correctly reflects your site's configuration.\n";
    print "Either way, you should quit this install and restart when ready.)\n";
    print "\n";

    print "Type \"Enter\" to continue, \"control-C\" to exit: ";
    my $dummy = <STDIN>;

    print "\n\n\n";

    foreach my $var (@config_vars) {
        if ($var eq "sep") { next; }
        # print "Found SERVER_URL = ".$CONFIG{"SERVER_URL"}."\n";
        printf("Found %-12s = %s\n", $var, $CONFIG{$var});
    }
    print "\n";
}

sub verify_gui_home_dir {

    # 1. Make sure that destination dir GUI_HOME_DIR exists

    my $ghd = $CONFIG{GUI_HOME_DIR}; # E.g. "/home/steveri/installgui"
    if (! -d $ghd) {
        print "Cannot find GUI_HOME_DIR \"$ghd\";\nwould you like me to try and create it for you (y or n)?\n";