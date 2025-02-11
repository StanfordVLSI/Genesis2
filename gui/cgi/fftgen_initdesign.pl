#!/usr/bin/env perl
use strict;

# The standalone FFT generator needs to initialize its fftgen
# design directory when stewie is first activated...

# So...this is going to be called from fftgen_gateway.htm
# along with some env parms like 
# "file=../designs/FFTGenerator/empty.xml&email=foo@br&DBG=1"
# It needs to do its business and then pass the torch to opendesign.pl

print "Content-type: text/html; charset=utf-8\n\n";
print
    '<!DOCTYPE HTML PUBLIC '.
    '"-//W3C//DTD HTML 4.01 Transitional//EN" '.
    '"http://www.w3.org/TR/html4/loose.dtd">'.
    "\n";

my $DBG = 0;
# my $DBG = 1;

sub embed_alert_script {

  my $s = shift(@_);         # E.g. "FOO! We're now at line 12\n"

  my ($second, $minute, $hour) = localtime();
  my $clocktime = "$hour:$minute:$second";
  $s = "$clocktime $s";

  while (chomp($s)) {}       # Remove trailing <cr> characters
  if ($s eq "") { return ""; }  # If nothing left, skip it.

  $s =~ s/\n/\\n/g;   # Strip off trailing <cr> characters.
  $s =~ s/\'/\"/g;    # Single quotes can mess you up, man.

  my $script = 
   '<script type="text/javascript"><!--'."\n".
   "alert(\'$s\');\n".
   '//--></script>'."\n\n";

  return $script;
}  

# E.g. "file=../designs/FFTGenerator/empty.xml&email=foo@br&DBG=1"
my $qs = $ENV{QUERY_STRING};
if ($qs =~ /DBG=1/) { $DBG=1; }

my $test = $DBG ? " -test" : "";

# I think this will do the right thing...???
my $udd = "../designs.aux/updatedesigndirs.pl -doit$test\n"
    . "   1> /tmp/tmp$$.1 2> /tmp/tmp$$.2;\n"
    . "   cat /tmp/tmp$$.[12]\n\n";

if ($DBG) { print embed_alert_script("ready to call: $udd"); }

$udd =~ s/\n//g;

#   if (! $DBG) { $gencmd = "$gencmd | grep '^Genesis'"; } # Maybe this works better?

my $alert_msg = `$udd`; 

if ($DBG) { print embed_alert_script($alert_msg); }

if (($alert_msg =~ /Usage/) || ($alert_msg =~ /ERR/)) {
    print "updatedesigndirs.pl returned the following error:\n";
    print "$alert_msg\n";
    exit;
}

# Now call opendesign.pl (with the appropriate env parms still intact maybe)

my $opendesign = "./opendesign.pl";
if ($DBG) { print embed_alert_script("ready to call: $opendesign"); }

my $alert_msg = `$opendesign`; 
# if ($DBG) { print embed_alert_script($alert_msg); }
# Mmmmm....maybe opendesign prints things that it thinks will go to the screen directly...
print $alert_msg;

