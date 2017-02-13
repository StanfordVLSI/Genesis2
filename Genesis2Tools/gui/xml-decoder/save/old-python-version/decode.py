#!/usr/bin/python

# set-variable indent-tabs-mode nil OR ESC-colon-(setq-default indent-tabs-mode nil)
# set-variable py-indent-offset 4

import re;
import sys;

import decode_globals;
from decode_globals import input_lines;
from decode_globals import output_lines;
from decode_globals import savelines;    # Should maybe move this to the individual passes...?

from decode_globals import output_from_this_pass_becomes_input_to_next_pass;  # So cool!

from decode1_ranges      import process_ranges;          # PASS1
from decode2_subinsts    import preprocess_subinsts;     # PASS2
from decode3_parms0      import preprocess_parameters;   # PASS3
from decode4_hashkeys    import process_hashkeys         # PASS4
from decode5_parms1      import process_parameter_items; # PASS5
from decode6_jsgen       import generate_javascript;     # PASS6 (final)

def printdie(msg): print msg; sys.exit(-1);

global debug;  debug  = 0
#global debug5; debug5 = 0
global debug6; debug6 = debug

####################################################################################################
def main():

    process_arg(sys.argv); # Initializes print_pass, do_pass

    ####################################################################################################
    # print_savelines;  

    from decode_globals import input_lines;

   #print "XXXa %4d %4d" % (len(decode_globals.input_lines), len(input_lines));

    for line in sys.stdin: input_lines.append(line); # Read complete file from stdin

    passno = 0;             # Start w/pass number 1.

    ####################################################################################################
   
    DoPass(1, "range info (#RANG)",                  process_ranges);         #PASS1: RANGES
    DoPass(2, "preprocess subinst items (#SUBINST)", preprocess_subinsts);    #PASS2: SUBINST
    DoPass(3, "preprocess hash items (#KEY)",        process_hashkeys);       #PASS3: HASHKEYS
    DoPass(4, "process parameters (#NAME and #COMM)",preprocess_parameters);  #PASS4: PARAMETERS
    DoPass(5, "process parameter items",             process_parameter_items);#PASS5: PARAMETER ITEMS
    DoPass(6, "generate javascript",                 generate_javascript);    #PASS6: FINAL (MAIN) PASS

    #print "cOO  %4d %4d" % (len(input_lines), len(output_lines));

    #if (print_savelines): debug5 = (debug or debug5);
    #process_parameter_items(input_lines, output_lines, savelines, debug5);

#END def main()
####################################################################################################

def process_arg(argv):

    global print_pass;
    global do_pass;

    print_pass = [-1,0,0,0,0,0,0]; # E.g. to print output of pass1, set $print_pass[1] = 1
    do_pass    = [-1,1,1,1,1,1,1]; # Perform only indicated passes

    if debug:
        print "";
        print "print_pass =%s" % print_pass;
        print "do_pass    =%s" % do_pass;

    if len(argv) > 1:
           
        arg = argv[1];
        print "# arg = \"%s\"" % arg;    # E.g. "-12345" => "print results of all five passes"

        # (Quit after highest printpass)

        tmpmsg = "#...we will show pass %%d/%d" % (len(print_pass)-1);

        if re.search("1", arg): print_pass[1] = 1; print tmpmsg % 1; do_pass = [-1,1,0,0,0,0,0];
        if re.search("2", arg): print_pass[2] = 1; print tmpmsg % 2; do_pass = [-1,1,1,0,0,0,0];
        if re.search("3", arg): print_pass[3] = 1; print tmpmsg % 3; do_pass = [-1,1,1,1,0,0,0];
        if re.search("4", arg): print_pass[4] = 1; print tmpmsg % 4; do_pass = [-1,1,1,1,1,0,0];
        if re.search("5", arg): print_pass[5] = 1; print tmpmsg % 5; do_pass = [-1,1,1,1,1,1,0];
        if re.search("6", arg): print_pass[6] = 1; print tmpmsg % 6; do_pass = [-1,1,1,1,1,1,1];
        print ""
    
def DoPass(passno,msg,function):
   if do_pass[passno]:
       print "# pass%d - %s" % (passno,msg);
       print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
       if (print_savelines): print "";
       decode_globals.print_savelines = print_savelines;

       foo=1
       function(savelines, debug);

       output_from_this_pass_becomes_input_to_next_pass();

####################################################################################################

#print encode_dots("hoo");                            print ""
#print encode_dots("a.b.c");                          print ""
#print encode_dots("c.dots.and$dollarsigns.are.bad"); print ""

main();
sys.exit(0);
