#!/bin/csh -f

# I dunno, maybe "verify_stewie.csh vlsiweb 8080"?

set CGI = "http://$1/cgi"

echo
echo "Checking fftgen at $CGI"


set initdesign_url = \
'http://vlsiweb.stanford.edu:8080/cgi/fftgen_initdesign.pl?file=..%2Fdesigns%2FFFTGenerator%2Fempty.xml&newdesign=fo%40ba&DBG=0'

set builddesign_url = \
'http://vlsiweb.stanford.edu:8080/cgi/updatedesign.pl?newdesign=fo%40ba&curdesign=..%2Fdesigns%2FFFTGenerator%2Fempty.js&modpath=top_fft&DBG=0&n_fft_points=8&units_per_cycle=1&SRAM_TYPE=TRUE_1PORT&swizzle_algorithm=round7'

set runfft_url = \
'http://vlsiweb.stanford.edu:8080/cgi/do_anything.pl?../designs/FFTGenerator/&/home/steveri/fftgen&bin/gui_test5.csh'


set tmp = /tmp/fft_test$$
set user = "fft_test%40kiwi"

set echo
##############################################################################
# Initialize the design using username "fft_test@kiwi"

set out = ${tmp}-1.init.out
set log = ${tmp}-1.init.log

echo "Initialize the design, username '$user'" | sed 's/%40/@/'
set url = \
"${CGI}/fftgen_initdesign.pl?file=..%2Fdesigns%2FFFTGenerator%2Fempty.xml&newdesign=${user}&DBG=0"

unset FAIL
wget "$url" -O $out -o $log
grep OK $log || set FAIL
if ($?FAIL) echo "APPEARS TO HAVE FAILED!"

echo

##############################################################################
# Build the design and generate verilog

set out = ${tmp}-2.build.out
set log = ${tmp}-2.build.log

echo "Build the design and generate verilog"
set url = \
"${CGI}/updatedesign.pl?newdesign=${user}&curdesign=..%2Fdesigns%2FFFTGenerator%2Fempty.js&modpath=top_fft&DBG=0&n_fft_points=8&units_per_cycle=1&SRAM_TYPE=TRUE_1PORT&swizzle_algorithm=round7"

unset FAIL
wget "$url" -O $out -o $log
grep OK $log || set FAIL
if ($?FAIL) echo "APPEARS TO HAVE FAILED!"

echo

##############################################################################
# Run the test and show the answer

set out = ${tmp}-3.do_test.out
set log = ${tmp}-3.do_test.log

echo "Run the test and show the answer"

set url = \
"${CGI}/do_anything.pl?../designs/FFTGenerator/&/home/steveri/fftgen&bin/gui_test5.csh"

unset FAIL
wget "$url" -O $out -o $log
grep OK $log || set FAIL
if ($?FAIL) echo "APPEARS TO HAVE FAILED!"

echo 'If there are problems maybe look at vlsiweb:/tmp/gui.simv.*'
echo 'FFT TEST RESULTS (verify that date is correct!)'
echo
sed -n '/V C S/,/to complete/p' $out

head $out