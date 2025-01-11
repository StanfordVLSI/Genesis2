#!/usr/bin/python

# set-variable py-indent-offset 4

def savelines(line):
    if (print_savelines): print line,
    output_lines.append(line);

def process_ranges():
    """
	# Replace <Range>...</Range> block with "#RANG" comment.
	
	####################################################
	# LIST example:
	# --------------------------------------------------
	#        <ParameterItem>
	#          <Doc>the value can be true or false</Doc>
	#          <Name>COND</Name>
	#
	#        #RANG COND = "false true"
	#        #  <Range>
	#        #    <List>false</List>
	#        #    <List>true</List>
	#        #  </Range>
	#          ...
	#        </ParameterItem>
	#
	####################################################
	# MIN/MAX/STEP example:
	# --------------------------------------------------
	#        <ParameterItem>
	#          <Doc>Power supply</Doc>
	#          <Name>MILLIVOLTS</Name>
	#
	#        #RANG MILLIVOLTS = ",1000,12.5"
	#        #  <Range>
	#        #    <Min></Min>
	#        #    <Max>1000</Max>
	#        #    <Step>12.5</Step>
	#        #  </Range>
	#          ...
	#        </ParameterItem>
	#
	####################################################"""
	
    import re;

    #readtag  = re.compile("^\s*(<[^<]+>)([^<]*)(</[^<]+>)");

    #    for line in input_lines :
    while (input_lines):
	line = input_lines[0];

	# BUG/TODO: should only do name search within the context of each ParameterItem

	# BUG/TODO: Depends on <Name> preceding <Range>
        #<Name>..</Name> => save parmname
	#findname   = re.compile("^\s*<Name>([^<]+)</Name>")
	#m = (findname).search(line);
	m = (re.compile("^\s*<Name>([^<]+)</Name>")).search(line);
	if m : parmname = m.group(1);
	#if m: print "HEYtoo %s" % line
	#if m: print "HEY1 %s\n" % parmname

	#emptyrange = re.compile("^\s*<Range>\S*</Range>")
	rangebegin = re.compile("^\s*<Range>\S*$");

	# Empty <Range> tags get commented away.
	#      m = emptyrange.search(line);
	#if emptyrange.search(line):
	#if (re.compile("^\s*<Range>\S*</Range>")).search(line):
	if (re.search("^\s*<Range>\S*</Range>", line)):
	    savelines("#" + line); # Print and save for next pass
	    input_lines.pop(0); # (pop(0) == shift);
	    continue;

	# Not interested unless we find a "Range" block.
        #elif (not rangebegin.search(line)):
        #elif (not (re.compile("^\s*<Range>\S*$")).search(line)):
        elif (not (re.search("^\s*<Range>\S*$", line))) :
	    savelines(line);       # Print and save for next pass
	    input_lines.pop(0); # (pop(0) == shift);
	    continue;

        #<Range> => process Range block
	list = [];                               # Enumerated range e.g. "true false"
	min = ""; max = ""; step = "";           # Allowed range min, max, step

	#rangeblock = ["#" + line];  # Save lines until parm block is completely processed
	rangeblock = [];

	while (input_lines):
	    line = input_lines[0];
	    #print "FOOKOO " + line,;
	    input_lines.pop(0); # (pop(0) == shift);

	    # Bypass existing commented-out lines.
	    if re.search(line, "^#"): rangeplock.append(line); continue;

	    list_item = re.search("^\s*<List>([^<]*)</List>", line);
	    min_item  = re.search("^\s*<Min>([^<]+)</Min>" , line);
	    max_item  = re.search("^\s*<Max>([^<]+)</Max>" , line);
	    step_item = re.search("^\s*<Step>([^<]+)</Step>" , line);

	    #<List>..</List> => add to enum list
	    #if ($line =~ /^\s*<List>([^<]*)<\/List>/) { push(@list, $1); }

	    #if (list_item):
	    if (re.search("^\s*<List>([^<]*)</List>", line)) :
	        #print "found list item " + list_item.group(1);
	        list.append(list_item.group(1));
		#sys.exit(0);

	    #<Min,Max,Step>..</Min,Max,Step> => save min,max,step
	    elif (min_item):  min  =  min_item.group(1);
	    elif (max_item):  max  =  max_item.group(1);
	    elif (step_item): step = step_item.group(1);

	    #</Range> => print range info; done
	    elif (re.search("^\s*<\/Range>\s*$", line)):
	    
		#print "listlen = "; print len(list);

		if (len(list) > 0): range = " ".join(list);
		else:                range = min + "," + max + "," + step;
	        #else:                range = "howdy";

		list = [];  # Otherwise it just accumulates...

		tmp = "#RANG %s = \"%s\"\n" % (parmname, range); # E.g. "#RANG MILLIVOLTS = ",100,12.5"
		savelines(tmp);

		#FOO FOO FOO BUG/TODO BUG/TODO BUG/TODO CONTINUE FROM HERE

		print "heydeho"
		#push @rangeblock, "#".$line;
		rangeblock.append("#" + line);
		for tmp in rangeblock : savelines(tmp);
		break;                                   # "last" in Perl, right?

	    # All processed lines become comments.
	    # push @rangeblock, "#".$line;
	    rangeblock.append("#" + line);



	    #range_end = re.compile("^\s*</Range>\S*$");
	    #if (range_end.search(line)): continue;

	# END while (input_lines)

    # END while (input_lines)

    savelines("\n");

# END def process_ranges()
####################################################################################################

debug = 1

debug_range = 1
debug_range = 0

mytoggler = 1

DBG = 0

####################################################################################################
print_pass = [0]*4    # print_pass = [0,0,0,0]
do_pass    = [1]*4    # do_pass    = [1,1,1,1]

print "print_pass =%s" % print_pass
print "do_pass    =%s" % do_pass

# sub process_args

import sys
if len(sys.argv) > 1 :
	print ""; print "# arg0 = %s" % sys.argv[1]  # E.g. "-0123" for "do all four passes"

	do_pass = [0,0,0,0]

	import re
	if re.search("0", sys.argv[1]) : do_pass[0] = 1; print "# ...we will do pass 0/3"
	if re.search("1", sys.argv[1]) : do_pass[1] = 1; print "# ...we will do pass 1/3"
	if re.search("2", sys.argv[1]) : do_pass[2] = 1; print "# ...we will do pass 2/3"
	if re.search("3", sys.argv[1]) : do_pass[3] = 1; print "# ...we will do pass 3/3"
	print ""

	print_pass = do_pass # E.g. [0,1,1,0]

	# shift @ARGV; # NOT OPTIONAL!  Otherwise tries to open e.g. file called "-0123"

####################################################################################################
# print_savelines;  # If TRUE print lines as they are processed

# input_lines = <>;
# output_lines = ();  # Clear the output buffer

#input_lines = sys.stdin;                 # Read complete file from stdin
##for line in input_lines : print line,

input_lines = [];
for line in sys.stdin: input_lines.append(line);



output_lines = [];                       # Clear the output buffer

passno = -1;

####################################################################################################
#PASS0: RANGES

#if ($do_pass[++$passno]) {
#    print "# pass$passno - range info\n";
#    $print_savelines = $print_pass[$passno];  # If =1 then print lines as they are processed.
#    process_ranges();
#    @input_lines = @output_lines; @output_lines = (); # Reset input lines.
#}

passno = passno + 1;
if do_pass[passno]:
    print "# pass%d - range info" % passno;
    print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
    process_ranges();

    print "OUTPUT LINES";
    for line in output_lines : print line,

    input_lines = output_lines; output_lines = []; # Reset input lines.

#help(process_ranges);


sys.exit(0)


###################################################################################################
###################################################################################################
###################################################################################################
###################################################################################################


# To use: e.g. "test.py yahoo.com" returns contents of http://yahoo.com

print "hola mis amigos"

import sys

# print "foo %d" % len(sys.argv)

if len(sys.argv) != 2 :
  print ""
  print "Usage:\n  %s [url]\n" % sys.argv[0]
  print "Example:\n  %s yahoo.com" % sys.argv[0]
  print "or\n  %s http://yahoo.com" % sys.argv[0]
  print ""

  sys.exit(0)

# for arg in sys.argv: print arg

arg = sys.argv[1]

# e.g. arg = 'yahoo.com' or 'http://yahoo.com';
url = arg
if arg[0:4] != "http": url = 'http://' + arg

print url

from urllib import urlopen

for line in urlopen(url):
        print line,

########################################################################
# import re
# 
# if re.search("a", "abc"): print "foopy"
#
# if re.search("href", line):
#     print "we out"

