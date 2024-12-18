#!/usr/bin/python

# set-variable indent-tabs-mode nil OR ESC-colon-(setq-default indent-tabs-mode nil)
# set-variable py-indent-offset 4

import re;
import sys;

#import decode_globals;
#from decode_globals import input_lines;
#from decode_globals import output_lines;
#from decode_globals import print_savelines;
#from decode_globals import savelines;

global input_lines; input_lines = [];
global output_lines; output_lines = [];

global print_savelines; print_savelines = 0;

def savelines(line):

    global print_savelines;

#    print "HYYin %d" % len(input_lines);
#    print "HYout %d" % len(output_lines);

    if (print_savelines): print line,
    output_lines.append(line);

#    print "HXout %d\n" % len(output_lines);

def reset_buffer():
    global output_lines;
    output_lines = [];













def printdie(msg): print msg; sys.exit(-1);

global debug;  debug  = 0
#global debug5; debug5 = 0
global debug6; debug6 = debug




from decode1_ranges      import process_ranges;          # PASS1
from decode2_subinsts    import preprocess_subinsts;     # PASS2
from decode3_parms0      import preprocess_parameters;   # PASS3
from decode4_hashkeys    import process_hashkeys         # PASS4
from decode5_parms1      import process_parameter_items; # PASS5
from decode6_jsgen       import generate_javascript;     # PASS6 (final)

####################################################################################################
def main():

#    savelines = decode_globals.savelines;

    # Should these be global!??  And/or why do we need both?
    DBG   = 0

    process_arg(sys.argv); # Initializes print_pass, do_pass

    ####################################################################################################
    # print_savelines;  

    global input_lines;                              # Used by everyone
    global output_lines;                              # Used by everyone
#    input_lines = decode_globals.input_lines;
#    input_lines = [];                                #

    for line in sys.stdin: input_lines.append(line); # Read complete file from stdin

    global output_lines;    # Used by savelines()...others?
    output_lines = [];      # Clear the output buffer

    global print_savelines; # Used by savelines() (duh!): If TRUE print lines as they are processed
#    print_savelines = decode_globals.print_savelines;

    passno = 0;             # Start w/pass number 1.

    ####################################################################################################
    #PASS1: RANGES

    passno = passno + 1;
    if do_pass[passno]:
        print "# pass%d - range info (#RANG)" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";


        decode_globals.print_savelines = print_savelines;

#        process_ranges(input_lines, output_lines, savelines);
        process_ranges(output_lines, savelines);

#        input_lines = output_lines; output_lines = []; # Reset input lines.
        decode_globals.input_lines = decode_globals.output_lines;
        input_lines = decode_globals.input_lines;
        decode_globals.reset_buffer();

    #help(process_ranges);

    ####################################################################################################
    #PASS2: SUBINST

    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - preprocess subinst items (#SUBINST)" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";
        decode_globals.print_savelines = print_savelines;

        preprocess_subinsts(input_lines, output_lines, savelines);

#        input_lines = output_lines; output_lines = []; # Reset input lines.
        decode_globals.input_lines = decode_globals.output_lines;
        input_lines = decode_globals.input_lines;
        decode_globals.reset_buffer();


    ####################################################################################################
    #PASS3: HASHKEYS

    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - preprocess hash items (#KEY)" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";
        decode_globals.print_savelines = print_savelines;

        process_hashkeys(input_lines, output_lines, savelines, debug);

#        input_lines = output_lines; output_lines = []; # Reset input lines.
        decode_globals.input_lines = decode_globals.output_lines;
        input_lines = decode_globals.input_lines;
        decode_globals.reset_buffer();

    ##############################################################################
    #PASS4: PARAMETERS

    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - process parameters (#NAME and #COMM)" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";
        decode_globals.print_savelines = print_savelines;

        preprocess_parameters(input_lines, output_lines, savelines);

#        input_lines = output_lines; output_lines = []; # Reset input lines.
        decode_globals.input_lines = decode_globals.output_lines;
        input_lines = decode_globals.input_lines;
        decode_globals.reset_buffer();


    ##############################################################################
    #PASS5: PARAMETER ITEMS

    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - process parameter items" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";
        decode_globals.print_savelines = print_savelines;

#        if (print_savelines): debug5 = (debug or debug5);

#        process_parameter_items(input_lines, output_lines, savelines, debug5);
        process_parameter_items(input_lines, output_lines, savelines, debug);

#        input_lines = output_lines; output_lines = []; # Reset input lines.
        decode_globals.input_lines = decode_globals.output_lines;
        input_lines = decode_globals.input_lines;
        decode_globals.reset_buffer();

    ################################################################################################
    #PASS6: FINAL (MAIN) PASS

#    print "\n\nFOO %d\n\n" % len(input_lines);


    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - generate javascript" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";
        decode_globals.print_savelines = print_savelines;

#        final_pass();

        generate_javascript(input_lines, output_lines, savelines, debug);



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
    
#def savelines(line):
#    if (print_savelines): print line,
#    output_lines.append(line);

####################################################################################################


#print encode_dots("hoo");                            print ""
#print encode_dots("a.b.c");                          print ""
#print encode_dots("c.dots.and$dollarsigns.are.bad"); print ""

main();
sys.exit(0);
