#!/usr/bin/perl
use strict;
use File::Glob ':glob';  # To turn e.g. "~steveri" into "/home/steveri"
use Cwd;

# Old csh version updatedesigndirs.csh took five seconds (real time)
# compared to 0.14 seconds for this (perl) version.  Whoopeee!

sub print_help_and_die {
    print "With \"-doit\" switch, Updates all design dirs with current .xml links etc.\n";
    print "\n";
    print "To work, must start from \"designs\" aux directory (e.g. \"GENESIS/gui/designs.aux\")\n";
    print "\n";
    print "To test:  cd GENESIS/gui/designs.aux; $0 -test\n";
    print "To run:   cd GENESIS/gui/designs.aux; $0 -doit\n";
    print "For both: cd GENESIS/gui/designs.aux; $0 -doit -test\n";
    exit(-1);
}

if ($#ARGV < 0) { print_help_and_die(); } 

my ($DOIT,$TEST) = (0,0);
foreach my $arg (@ARGV) {
    if    ($arg eq "-doit") { $DOIT = 1; }
    elsif ($arg eq "-test") { $TEST = 1; }  # Actually more "verbose"
}

if ((! $DOIT) & (! $TEST)) { print_help_and_die(); }

# BUG/TODO maybe flag zombie designs...?

my $DL = get_design_list_filename(); # E.g. "/home/steveri/gui/configs/design_list_stanford.txt"
open DL, "<$DL" or die "Could not find design list \"$DL\"";

# Based on what we find in the design list, make
# a list of designs and their source directories.

my %designs;

foreach my $line (<DL>) {

    # Make a list of designs and their source directories
    if ($line =~ /^\s*([^\#]\S+)\s+(\S+)/) {     # E.g. "demo /home/steveri/genesis_designs/demo"
        #print $line; print "-$1-$2\n";
        $designs{$1} = $2; # E.g. $designs{"demo"} = "/home/steveri/genesis_designs/demo" 
    }

    # Find and eliminate deleted designs by renaming them with ".deleted" extension
    elsif ($line =~ /^\s*[\#]\s*(\S+)\s+(\S+)/) {
        my $dbasename  = $1;  # Name of deisgn to delete
        my $dsourcedir = $2;  # Sourcedir associated w/design to delete.

        my $delete_candidate = "../designs/$1";

        if (! -d $delete_candidate) { next; } # Already deleted.

        # Trouble if design is on both "deleted" list and "designs" list;
        # this means that the design got renamed at least once, e.g.
        #     "#tile_megan /home/wachs/.../TileGenTest/gui"
        #     " tile_megan /home/wachs/.../TileGenTest"
        #
        # Thus:  name AND sourcedir must match before delete.

        if (-e "$delete_candidate/__SOURCEDIR__") {
            my $dc_source = `cat "$delete_candidate/__SOURCEDIR__"`; chomp($dc_source);
            if ($dc_source ne $dsourcedir) {
                if ($TEST) { print "Want to delete '$dbasename' => '$dsourcedir';\n".
                                 "existing '$dbasename' maps to '$dc_source';\n".
                                 "therefore this is not the droid.\n\n";
                }
                next; # Don't delete mismatched design.
            }
        }
        # Note: designs with no __SOURCEDIR__ file will be deleted.  That's okay;
        # "delete" is the conservative thing to do.  Legit designs will return.

        # Okay time to go ahead and delete the unwanted design...

        # Don't overwrite existing dirs or files, I guess...
        # May need multiple delete dirs if there are multiple deletes/remappings.
        my $i=0; while (-e "$delete_candidate.deleted.$i") { $i++; }
        my $deleted = "$delete_candidate.deleted.$i";

        if ($TEST) { print "MUST RENAME $delete_candidate TO $deleted\n"; }
        if ($DOIT) { `mv $delete_candidate $deleted`; if ($?) { print "ERROR Could not delete $delete_candidate\n"; }}
    }
}

# Okay this might be stoopid (and too late?) but for now we need to do it anyway.
if (! -d "../designs") { mkdir "../designs" or die $!; }

# Make sure copies of all the design directories exist in the server's local directory;
chdir "../designs";
find_and_get_missing_directories(\%designs);

# BUG/TODO find_and_delete_zombie_directories
# if name not on list, rename to *.deleted (instead of thing above)
find_and_delete_zombie_directories(\%designs);

if ($TEST) { print "Check for updated links to all .xml and .js files\n"; }


# new1: For each file $f = {*.js,*.xml} in source directory $s but not
# in GUI cache $d, make a copy of $s/$f and add it to $d
# BUT ALSO make a copy for each $s/$f whose timestamp differs from $d/$f
#
# New exception: if $s.deleteme exists in gui cache $d, don't update.

my $basedir = cwd();

foreach my $d (sort(keys(%designs))) {
    my $s = $designs{$d};

    if ($TEST) { print "\nDesign '$d' updates needed:\n"; }

    chdir "$basedir/$d";

    if (-e "__SOURCEDIR__") {
        my $sourcedir = `cat "__SOURCEDIR__"`; chomp($sourcedir);
        if ($sourcedir ne $s) {
            print "WARNING: Design dir '$d': list source '$s' does not match SOURCEDIR '$sourcedir';\n";
            print "WARNING: This might lead to problems...?\n";
        }
    }

    # Preserve the source dir in a place where it can easily be accessed by e.g. editdesigns.pl
    if ($DOIT) { `echo $s > __SOURCEDIR__`; }

    # Okay let's see if we can bring in the makefile(s)
    foreach my $f (bsd_glob("$s/*akefile*")) {
        if ($TEST) { print "  Add makefile: $f\n"; }
        # Note need '-f' because Makefiles are frequently read-only...
        if ($DOIT) { `cp -f --preserve=timestamp $f .` }
    }

#    foreach my $f (bsd_glob("$s/*.{js,xml}")) {
    # By special request, include files in sourcedir/SysCfgs subdir if exists.

    foreach my $f (bsd_glob("{$s,$s/SysCfgs}/*.{js,xml}")) {
        #if ($f =~ /655/) { print "foo $f\n"; }

        use File::Basename;

        # For fileparse() see http://perldoc.perl.org/File/Basename.html
        my $sf = $f;            # E.g. "demo/base_design.xml"
        my $df = fileparse($f); # E.g. "base_design.xml"

        #if ($f =~ /655/) { print "sf=\"$sf\"\ndf=\"$df\"\n"; }

        ##################################################################
        # No symbolic links!

        if (-l $df) {
            if ($TEST) { print "    Incapacitate symbolic link $df"; }

            #if ($DOIT) { `mv $df $df.deleteme`; }
            my $i=0; while (-e "$df.deleteme.$i") { $i++; }
            if ($DOIT) { `mv $df $df.deleteme.$i`; if ($?) { print "ERROR Could not delete symlink $df\n"; }}
        }

        ##################################################################
        # Okay this ".deleteme" thing is oh so stoopid!  But necessary.
        # See note above; this is only way to keep SysCfg files from returning.
        if (-e "$df.deleteme") { next; } # Don't update deleted file!

        ##################################################################
        # If file from $s doesn't exist in $d, add it.

        if (! -e $df) {
            if ($TEST) { print "  Add missing file $df\n"; }

            # Weird.  It's just gonna get updated on time check below...??!
            if ($DOIT) { `cp --preserve=timestamp $sf .; chmod +w $df;`; }
        }

        # stat() returns: 0$dev, 1$ino, 2$mode, 3$nlink, 4$uid, 5$gid,
        # 6$rdev, 7$size, 8$atime, 9$mtime, $ctime, $blksize, $blocks) = stat($file);

        my @sfstat = stat($sf); my $stime = $sfstat[9];
        my @dfstat = stat($df); my $dtime = $dfstat[9];

        #print "sfsize=$sfstat[7]\ndfsize=$dfstat[7]\n";
        #print "sftime=$sfstat[9]\ndftime=$dfstat[9]\n";

        #print "\n  $basedir/$d/$df $sf\n    sftime=$stime\n    dftime=$dtime\n";

        if ($stime != $dtime) {
           #if ($TEST) { print "  Renew outdated file $df"; }
            if ($TEST) { print "  Replace file $df because of mismatched timestamp"; }
            if ($TEST) { print " (stime:$stime dtime:$dtime)\n"; }
            if ($DOIT) { `cp --preserve=timestamp $sf .`; }
        }
    }
    # Make sure that at least *one* design exists in each design directory.
    `test -e empty.xml || echo "<HierarchyTop></HierarchyTop>" > empty.xml`;
}


  
sub get_design_list_filename {

    # E.g. "DESIGN_LIST     ~steveri/gui/configs/design_list_stanford.txt"

    open CONFIG, "<../CONFIG.TXT" or print_help_and_die(); # Maybe in wrong directory?
    foreach my $line (<CONFIG>) {
        if ($line =~ /^DESIGN_LIST\s+(\S+)/) {
            my $DL = bsd_glob($1, GLOB_TILDE | GLOB_ERR); # Turns e.g. "~steveri" into "/home/steveri"
            if ($TEST) { print "Found design list \"$DL\"\n\n"; }
            close CONFIG;
            return $DL;
        }
    }
    #my $homedir = bsd_glob('~steveri', GLOB_TILDE | GLOB_ERR);
    #print "$homedir\n\n";
}

sub find_and_get_missing_directories {
    my $designs = shift @_;

    if ($TEST) { print 'List "design => sourcedir" for each design:'."\n\n"; }

    # Make sure copies of all the design directories exist in the server's local directory;
    # for each one that's missing, add it to a list.

    my @missing;

    foreach my $d (sort(keys(%{$designs}))) {
        my $s = $designs->{$d};

        if ($TEST) { printf "  %-24s %s\n", $d, $s; }
        if (! -e $d) {
            #if ($TEST) { print "oopsy cannot find $d\n\n"; }
            push @missing, $d;
        }
    }

    if ($TEST) { print "\n"; }

    #if ($#missing >= 0) {
    foreach my $missing_dir (@missing) {
        if ($TEST) {
            print "Found missing design directory \"$missing_dir\"\n";
            print "Doing: 'mkdir $missing_dir'\n\n";
        }
        if ($DOIT) {
            #`mkdir $missing_dir` or die "Could not create missing design \"$missing_dir\"\n";
            # => dies even though "mkdir" succeeds

            my $err = `mkdir $missing_dir`; # print ".$err.\n";
            if ($err ne "") { die "Could not create missing design \"$missing_dir\"\n"; }
        }
    }
}


sub find_and_delete_zombie_directories {
    my $designs = shift @_;
     
    # Coordinate "exclude_dirs" with "cgi/getdesigns.pl"
    my $exclude_dirs = qr/tgt0.broken|tmp.tgt0|^old$|^save/;

    if ($TEST) { print "Zombie directories that will be deleted:\n"; }
    opendir(DIR, ".");
    my @FILES= readdir(DIR);
    foreach my $designdir (@FILES) {
        if (! -d $designdir) { next; }
        if ($designdir =~ /^[.]/)          { next; } # Skip "." and ".." (!!)
        if ($designdir =~ /$exclude_dirs/) { next; }
        if ($designdir =~ /[.]deleted[.]*[0-9]*$/)   { next; } # This is how we flag deleted designs, e.g. "OferDesign.deleted"

        # If you're not on the list, then you gotta go!
        if (! $designs->{$designdir}) {
            #if ($TEST) { print "  $designdir => $designdir.deleted\n"; }
            #if ($DOIT) { `mv $designdir $designdir.deleted`; }

            my $i=0; while (-e "$designdir.deleted.$i") { $i++; }
            my $deleted = "$designdir.deleted.$i";
            if ($TEST) { print "  $designdir => $deleted\n"; }
            if ($DOIT) { `mv $designdir $deleted`; if ($?) { print "ERROR Could not delete $designdir\n" ; }}
        }
    }
    if ($TEST) { print "\n"; }
    closedir (DIR);
}
