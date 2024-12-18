#!/usr/bin/python

# set-variable indent-tabs-mode nil OR ESC-colon-(setq-default indent-tabs-mode nil)
# set-variable py-indent-offset 4

import re;
import sys;

####################################################################################################
def main():

    # Should these be global!??  And/or why do we need both?
    global debug; debug = 1
    DBG   = 0

    process_arg(sys.argv); # Initializes print_pass, do_pass

    ####################################################################################################
    # print_savelines;  

    global input_lines;                              # Used by everyone
    input_lines = [];                                #
    for line in sys.stdin: input_lines.append(line); # Read complete file from stdin

    global output_lines;    # Used by savelines()...others?
    output_lines = [];      # Clear the output buffer

    global print_savelines; # Used by savelines() (duh!): If TRUE print lines as they are processed

    passno = 0;             # Start w/pass number 1.

    ####################################################################################################
    #PASS1: RANGES

    passno = passno + 1;
    if do_pass[passno]:
        print "# pass%d - range info (#RANG)" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";

        process_ranges();

        input_lines = output_lines; output_lines = []; # Reset input lines.

    #help(process_ranges);

    ####################################################################################################
    #PASS2: SUBINST

    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - preprocess subinst items (#SUBINST)" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";

        preprocess_subinsts();

        input_lines = output_lines; output_lines = []; # Reset input lines.

    ####################################################################################################
    #PASS3: HASHKEYS

    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - preprocess hash items (#KEY)" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";

        # Move hash key to top of "HashItem" block

        while (input_lines):
            line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

            #if ($line =~ /^\W*<HashItem>\W*$/) {
            #    savelines($line, find_hashkey());
            #else {
            #    savelines($line);

            savelines(line);
            if (re.search("^\W*<HashItem>\W*$", line)) :
                hashlines = find_hashkey();
                for tmp in hashlines : savelines(tmp);

        input_lines = output_lines; output_lines = []; # Reset input lines.

    ##############################################################################
    #PASS4: PARAMETERS

    #if ($do_pass[++$passno]) {
    #    print "# pass$passno - process parameters\n";
    #    $print_savelines = $print_pass[$passno];
    #
    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - process parameters (#NAME and #COMM)" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";

        preprocess_parameters();

        input_lines = output_lines; output_lines = []; # Reset input lines.

    ##############################################################################
    #PASS5: PARAMETER ITEMS

    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - process parameter items" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";

        process_parameter_items();

        input_lines = output_lines; output_lines = []; # Reset input lines.

    ################################################################################################
    #PASS6: FINAL (MAIN) PASS

    passno = passno + 1
    if do_pass[passno]:
        print "# pass%d - generate javascript" % passno;
        print_savelines = print_pass[passno];  # If == 1 then print lines as they are processed.
        if (print_savelines): print "";

        final_pass();


#END def main()
####################################################################################################

def final_pass():

    # Final pass to generate javascript.

    javascript_header  = "<script type=\"text/javascript\"><!--";
    javascript_trailer = "\n\n//--></script>\n";
    javascript_sep     = javascript_trailer + javascript_header;

    print javascript_header;

    #Blank/empty file generates a single "top" object and quits
    if (re.search("\W*<HierarchyTop>\W*<.HierarchyTop>\W*$", input_lines[0])
        or
        (len(input_lines) <= 1)                 # len == 1 for blank file (!)
        ):
	print "var cgtop = new Object();";
	print "cgtop.BaseModuleName = \"top\";";
	print "cgtop.InstanceName   = \"top\";";
	print javascript_trailer;
        sys.exit(0);                            # Done!

    tag = ["cgtop"];

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

	# Print incoming line as a comment, if it isn't already one.

        if re.search("^#", line): print line,;
        else:                     print "#" + line,;

        oneliner = re.search("^\s*<([^>]+)>([^<]+)<\/([^>]+)>", line);
        parmhint = re.search("^\#PARM (.*)", line);
        parmcomm = re.search("^\#COMM (.*)", line);
        parmrang = re.search("^\#RANG (.*)", line);

        find_sub   = re.search("^\#SUBINST (\w*)", line);
        find_obj   = re.search("^\#OBJECT (.*)", line);
        find_ipath = re.search("^\#IPATH (.*)", line);
            
        lonetag  = re.search(  "^\s*<([^\/>]+)>\s*$", line);
        closetag = re.search("^\s*<\/([^\/>]+)>\s*$", line);

	# "<HierarchyTop>" is the signal to start
        # BUG/TODO use HierarchyTop instead of cgtop in javascript?
        if re.search("^<HierarchyTop>\W*$", line):
	    print "var cgtop = new Object();";


	# Tag + data + close-tag all together on a line e.g. "<BaseModuleName>top</BaseModuleName>"
	# => 'path.BaseModuleName = "top";'
        elif oneliner:                            # E.g. <(Name)>(foo)</(Name)>

	    #	print "DBG INPUT= $_";
	    #	print "DBG $1:::$2:::$3\n";

            tag1 = oneliner.group(1);
            data = oneliner.group(2);
            tag2 = oneliner.group(3);

            #print "DBG " + tag1;

            if not(tag1 == tag2): print "\nERROR!!!  tags no matchee for \"%s\"\n" % tag1;
            else:
		print("%s.%s = \"%s\";" % (printpath(tag), tag1, data));

        elif (parmhint):                                # "^\#PARM (.*)"

            # E.g. #PARM MODE = "VERIF"
           
            path = printpath(tag);

	    #printf("%s.Parameters.%s;\n", $path, $1);
	    #print ("$path.Parameters.$1;\n");

#            print "FOOOO %s.%s;" % (path,parmhint.group(1));  # perl:  print ("$path.$1;\n");
            print "%s.%s;" % (path,parmhint.group(1));  # perl:  print ("$path.$1;\n");

        elif (parmcomm):                                # "^\#COMM (.*)"

            path = printpath(tag);

	    # "cgtop.Parameters"           => "cgtop.Comments"
	    # ("cgtop.ImmutableParameters" => "cgtop.ImmutableComments")?

            path = path[0:(len(path)-10)];     #perl: $path = substr($path,0,length($path)-10); 

            print "%sComments.%s;" % (path,parmcomm.group(1)); # print ($path."Comments.$1;\n");


        elif (parmrang):                      # "^\#RANG (.*)"

            path = printpath(tag);

	    # "cgtop.Parameters"          => "cgtop.Range"
	    # "cgtop.ImmutableParameters" => "cgtop.ImmutableRange"

            path = path[0:(len(path)-10)];     #perl: $path = substr($path,0,length($path)-10); 

            print "%sRange.%s;" % (path,parmrang.group(1)); # print ($path."Range.$1;\n");

	elif (find_sub):                                           # "^\#SUBINST (\w*)"



            tag.append(find_sub.group(1));


	    print "%s = new Object();" % printpath(tag);

	elif (find_obj):                                           # "^\#OBJECT (.*)"
	    print "%s.%s;" % (printpath(tag), find_obj.group(1));

	elif (find_ipath):                                         # "^\#IPATH (.*)"
	    print "%s.%s;" % (printpath(tag), find_ipath.group(1));

        # Tag by itself on a line builds a new object
        # e.g. "<top>" => "path.top = new Object();"

        elif (lonetag):  # "^\s*<([^\/>]+)>\s*$"

            tagname = lonetag.group(1);

	    # Browsers don't like huge contiguous javascripts, so we break them up per SubInstance

            if (tagname == "SubInstances"): print javascript_sep;
            
            elif (tagname == "SubInstanceItem"):
                if debug: print "\nfp(): ignoring lone tag %s (i hope)\n" % tagname
                continue;
            else:
                if debug: print "\nfp(): adding lone tag %s to tag list\n" % tagname

	    # Build a new object, remember the tag for error check purposes.

#            if (len(tag) >= nestlevel): tag.append(tagname);
#            else: tag.append(find_sub.group(1));

            tag.append(tagname);



            print "%s = new Object();" % printpath(tag);

	    # BUG/TODO what a hack!!!
	    # For every "Parameter"/"ImmutableParameter", build Comments and Range objects

            if ((tagname == "Parameters") or (tagname == "ImmutableParameters")):

		path = printpath(tag);

                # "cgtop.Parameters" => "cgtop."
                # "cgtop.ImmutableParameters" => "cgtop.Immutable"

                path = path[0:(len(path)-10)];     # perl: $path = substr($path,0,length($path)-10);

		# BUG/TODO builds an object whether it's needed or not
		# BUG/TODO i.e. builds an object whether or not Range/Comment actually exists

                # "cgtop.Parameters"          => "cgtop.Comments"
		# "cgtop.ImmutableParameters" => "cgtop.ImmutableComments"

		print "%sComments = new Object();" % path;
		print "%sRange = new Object();"    % path;

            # END if ((tagname...

        # END elif (lonetag)

	# Close-tag on a line by itself
	
        elif (closetag):                    # "^\s*<\/(.+)>\s*$"

            if debug: print "fp(): found close-tag " + closetag.group(1)
            if debug: print "path now = %s" % printpath(tag)

	    # TODO/BUG why the exceptions?
	    # Because SubinstanceItem tag value "tag[i]" is pathname, not "SubInstanceItem"
	    # How would we "fix" that?  Push a "SubinstanceItem" tag when find "SUBI"?
	    # Can't do it---need path in tag for e.g. "printpath" to work.
	    # Correct fix: use separate arrays to track tags, pathnames.

            tagname = closetag.group(1);

            if   (tagname == "SubInstanceItem"):pass;  # Exceptions for SubInstanceItem, HierarchyTop
            elif (tagname == "HierarchyTop")   :pass;  # Exceptions for SubInstanceItem, HierarchyTop

            elif (tagname != tag[-1]):

		print "ERROR line = %s" % line;
		print "ERROR: tags no match-o: \"%s\" != \"%s\"\n" % (tagname,tag[-1]);
                sys.exit(-1);

            #END elif

            tag.pop();                  # removes last element of the list

	#END elif (closetag)

        else:
            if debug: print "FOO ignored line %s" % line,

    # END while (input_lines):
    print "\nfp not yet completed"; sys.exit(0);

# END def final_pass()
                      

def printpath(tag):
    """E.g. printpath(2, ["cgtop","DUT","p0"]) => "cgtop.DUT"""

    debugpp = 1
    if debugpp: print "\nEntering printpath(%s)" % (tag);

    rval = tag[0];
   

#    for i in range(1,plevel+1):                    # perl: for (i=1; i <= plevel; i++)
    for i in range(1,len(tag)):                    # perl: for (i=1; i <= plevel; i++)


        rval = "%s.%s" % (rval, tag[i]);
        if debugpp: print "    pp says: (i,rval,tag[i] = %d,%s,%s" % (i,rval,tag[i]);

    if (debugpp): print "    printpath(%s) = %s\n" % (tag,rval);
    return rval;



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
        ####################################################
    """
        
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
            savelines(line);    # Save lines in "output_lines" block for next pass.
            input_lines.pop(0); # (pop(0) == shift);
            continue;

        #<Range> => process Range block
        list = [];                               # Enumerated range e.g. "true false"
        min = ""; max = ""; step = "";           # Allowed range min, max, step

        #rangeblock = ["#" + line];  # Save lines until parm block is completely processed
        rangeblock = [];

        while (input_lines):
            line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

            # Bypass existing commented-out lines.
            if re.search(line, "^#"): rangeblock.append(line); continue;

            list_item = re.search("^\s*<List>([^<]*)</List>", line);
            min_item  = re.search("^\s*<Min>([^<]+)</Min>" , line);
            max_item  = re.search("^\s*<Max>([^<]+)</Max>" , line);
            step_item = re.search("^\s*<Step>([^<]+)</Step>" , line);

            #<List>..</List> => add to enum list
            #if ($line =~ /^\s*<List>([^<]*)<\/List>/) { push(@list, $1); }

            if (list_item):
            #if (re.search("^\s*<List>([^<]*)</List>", line)) :
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

                if (len(list) > 0) : range = " ".join(list);
                else               : range = min + "," + max + "," + step;

                tmp = "#RANG %s = \"%s\"\n" % (parmname, range); # E.g. "#RANG MILLIVOLTS = ",100,12.5"
                savelines(tmp);

                
                rangeblock.append("#" + line);           # perl: push @rangeblock, "#".$line;
                for tmp in rangeblock : savelines(tmp);
                break;                                   # perl: last

            # All processed lines become comments.
            rangeblock.append("#" + line);               # perl: push @rangeblock, "#".$line;

        # END while (input_lines)
    # END while (input_lines)

    savelines("\n");

# END def process_ranges()
####################################################################################################

def preprocess_subinsts():
    """
    # Add #SUBINST comment w/name of subinstance.

    #####################################################
    # Example (SUBINST added):
    #
    # #SUBINST tst2dut_cfg_ifc
    #    <SubInstanceItem>
    #      <BaseModuleName>cfg_ifc</BaseModuleName>
    #      ...
    #      <InstanceName>tst2dut_cfg_ifc</InstanceName>
    #      ...
    #    </SubInstanceItem>
    #####################################################
    """
    #print "hello i am preprocess_subinsts";

    #while (@input_lines) {
    #   my $line = shift @input_lines;

    while (input_lines):
        line = input_lines[0];

        # Not interested unless we find a "SubInstanceItem" block.

        #if (! ($line =~ /^\W*<SubInstanceItem>\W*$/)) {
        #    savelines($line); # Save lines in "output_lines" block for next pass.
        #    next;
        #}
        
        if (not (re.search("^\W*<SubInstanceItem>\W*$", line))) :
            savelines(line);    # Save lines in "output_lines" block for next pass.
            input_lines.pop(0); # (pop(0) == shift);
            continue;


	#<SubInstanceItem> alone on a line: start looking for InstanceName.

	#my @saveblock = ("#$line");
        #saveblock = ["#" + line];  # Save lines until parm block is completely processed
        saveblock = [];

#	while (my $subline = shift(@input_lines)) {
#

        while (input_lines):
            subline = input_lines[0];
            #print "FOOKOO " + line,;
            input_lines.pop(0); # (pop(0) == shift);


            #push @saveblock, $subline;  # Save lines in buffer until find InstanceName
            saveblock.append(subline);

            match_iname = re.search("^\s*<InstanceName>([^<]+)</InstanceName>" , subline);


            if re.search(subline, "^\W*<SubInstanceItem>\W*$"):
                printdie("ERROR: no InstanceName before SubInstanceItem");

            elif re.search(subline, "^\W*</SubInstanceItem>\W*$"):
                printdie("ERROR: no InstanceName in SubInstanceItem block");

            #elsif ($subline =~ /^\s*<InstanceName>([^<]+)<\/InstanceName>/) {
            elif match_iname:

                #savelines("#SUBINST $1\n");
                #savelines(@saveblock);
                #last; # We done (with SubInstanceItem block).

                # Found InstanceName; write it out, along with saved lines.
                savelines("#SUBINST %s\n" % match_iname.group(1));
                for tmp in saveblock : savelines(tmp);
                break;                                   # perl: last

    # END while (input_lines)
# END def preprocess_subinsts

####################################################################################################

def find_hashkey() :
    """
    ########################################################################
    # IN:
    #    <HashItem>
    #      ...
    #      <Key>keyname</Key>
    #      ...
    #
    # OUT:
    #    #KEY keyname
    #    <HashItem>
    #      ...
    #    #  <Key>keyname</Key>
    #      ...
    ########################################################################
    """
    #print "i am find_hashkey"

    block = [];
    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        key = re.search("s*<Key>([^<]+)<\/Key>", line);

        if (re.search("^\W*<HashItem>\W*$", line)) : # Recursively find subitem keys.

            block.append(line);                      #push @block, $line;
            block = block + find_hashkey();          #push @block, find_hashkey();

        elif (key) :

            block.append("#" + line);           # Comment out to show it's been processed.
            hashkey = key.group(1);             # Save the key

        elif (re.search("^\W*</HashItem>\W*$", line)) : # Found the key; save and return.

            block.append(line);                         #push @block, $line;
            return ["#KEY " + hashkey + "\n"] + block;

        else :
            block.append(line);                         #push @block, $line;

    # END while

    print "ERROR could not find close-hashitem tag \"</HashItem>\""; sys.exit(-1);

# END def find_hashkey()

####################################################################################################

def preprocess_parameters() :
    """Process each <ParameterItem> in <Parameters> block"""

    #print "i am preprocess_parameters()";

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

	#<ParameterItem> => process ParameterItem block
        if (re.search("^\W*<ParameterItem>\W*$", line)) : # Process ParameterItem block
	    preprocess_parameter_item(line);

	else : savelines(line); # Print and save for next pass

####################################################################################################
def bypass_type(itemtype):                     # itemtype = "Array" or "Hash"
    #print "i am bypass_type(%s)" % itemtype; 

    close_tag = re.compile("^\W*<\/%sType>\W*$" % itemtype); # "ArrayType" or "HashType"
    block = [];

    debug = 0;
    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        if (debug): print "#bt processing line %s" % line,
        block.append(line);

        if   (re.search("^\W*<ArrayType>\W*$", line)): block = block + bypass_type("Array");
        elif (re.search("^\W*<HashType>\W*$",  line)): block = block + bypass_type("Hash");
        elif (close_tag.search(line)):                 return block;
    #END while
    print "\nERROR bypass_type() found no close-tag for <$type>";
    sys.exit(0);

#END def


####################################################################################################
def preprocess_parameter_item(line_in):

    """# Move "Name" and "Doc" to the top of the ParameterItem block starting w / $in_line."""

    ###############################################################
    #IN:
    #        <ParameterItem>
    #          ...
    #          <Doc>Comment</Doc>
    #          <Name>MODE</Name>
    #          ...
    #        </ParameterItem>
    #
    #OUT (add NAME and COMM comments)
    #
    #    #NAME MODE
    #    #COMM "Comment"
    #         <ParameterItem>
    #          ...
    #    #      <Doc></Doc>
    #    #      <Name>MODE</Name>
    #          ...
    #         </ParameterItem>
    ###############################################################

    #print "i am preprocess_parameter_item"
    #print "i am going to process:",
    #print line_in,
    
    parmdoc = "no comment";                              # Initialize parm documentation
    parmblock = [line_in]  #my @parmblock = ($line_in);  # Save lines until parm block is completely processed

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        doc = re.search("^\s*<Doc>([^<]*)<\/Doc>", line);
        #doc  = re.search( "^\s*<Doc>([^<]+)<\/Doc>",  line);
        name = re.search("^\s*<Name>([^<]+)<\/Name>", line);
        hatype = re.search("^\s*<(Array|Hash)Type>", line);

        #<Doc>..</Doc> => save comment
        if (doc) :

            #push @parmblock, "\#$line";
            #if ($1 eq "") { $parmdoc = "no comment"; }
            #else          {	$parmdoc = $1;           }
            #$parmdoc = "\"$parmdoc\"";

            if (doc.group(1) != "") : parmdoc = doc.group(1);

            parmblock.append("#" + line);
            parmdoc = "\"%s\"" % parmdoc;

        #<Name>..</Name> => save parmname

        elif (name) :
            parmname = name.group(1);                  # $parmname = $1; 
            parmblock.append("#" + line);              # push @parmblock, "\#$line";

        # ALSO POSSIBLE TO HAVE "<ArrayType></ArrayType>" (no ArrayItem's)

        # Skip ArrayType/HashType w/no enclosed Item's
        #elsif ($line =~ /^\s*<(Array|Hash)Type>\W*<\/(Array|Hash)Type>\W*$/) {
        elif (re.search("\s*<(Array|Hash)Type>\W*<\/(Array|Hash)Type>\W*$", line)) :
            #print "#foo ITS_OK pre_pi found $1 type w/no $1 items\n";
            parmblock.append(line);                    # push @parmblock, $line;

            

        # Skip ArrayType/HashType along w/enclosed Item's
        elif (hatype) :
            parmblock.append(line);                    # push @parmblock, $line;
            #push @parmblock, bypass_type($1);         # BUG/TODO BUG/TODO BUG/TODO ###########
            for tmp in bypass_type(hatype.group(1)) : parmblock.append(tmp);
            
        # Close-tag "</ParameterItem>" => print parmname, parmval, parmblock; done.
        elif (re.search("^\W*<\/ParameterItem>\W*$", line)) :
            
            savelines("#NAME %s\n" % parmname);                #savelines("#NAME $parmname\n");
            savelines("#COMM %s = %s\n" % (parmname, parmdoc)) #savelines("#COMM $parmname = $parmdoc\n");
            
            for tmp in parmblock: savelines(tmp);              #savelines(@parmblock, $line);
            savelines(line);

            break; # last; # We done.

        else:
            parmblock.append(line);            # push @parmblock, $line;

####################################################################################################
def process_parameter_items():
    if debug: print "#DBG i am process_parameter_items";

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        namesearch = re.search("^\#NAME (.*)", line);

        if (namesearch):
            parmname = namesearch.group(1);

	    # ***TODO/BUG/EGREGIOUS HACK ALERT!  Some browsers can't handle "default".
            if (parmname == "default"): parmname = "defaultHACK";
            
	#<ParameterItem> => process ParameterItem block
        if (re.search("^\s*<ParameterItem>\s*$", line)):
            process_parameter_item(line, parmname);
        else:
            savelines(line);

def process_parameter_item(firstline, path):
   #print "i am process_parameter_item(\n    \"%s    \"%s\n)" % (firstline, path);

    parmdoc = ""; parmname = ""; parmval = "";

    parmblock = ["#" + firstline]; # Save lines until parm block is completely processed

    simpleparm = 0; found_ipath = 0;

    parmname = path;

    if debug: print("#foo found parameteritem block with name %s" % path);

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        if debug: print "#ppi() processing line %s" % line,;

        # Comment-out all lines not already commented-out.
        parmblock.append(commentline(line));

        valsearch = re.search("^\s*<Val>([^<]*)<\/Val>", line);
        ipsearch  = re.search("^\s*<InstancePath>([^<]+)<\/InstancePath>", line);
        hatype    = re.search("^\s*<(Array|Hash)Type>", line);
        hatype1   = re.search("^\W*<(Hash|Array)Type>\W*<\/(Hash|Array)Type>\W*$", line); # one-liner

        if (re.search("^\#", line)) : ();      # Do nothing (does this work??)

	# ("Name" and "Doc" have already been processed in a prior pass.)

	#<Val>..</Val> => save parmval
        elif (valsearch): # "^\s*<Val>([^<]*)<\/Val>"
	    parmval = "\"%s\"" % valsearch.group(1);
            if debug: print "ppi() found parmval %s" % parmval;
	    simpleparm = 1;

        elif (ipsearch): # "^\s*<InstancePath>([^<]+)<\/InstancePath>"
            found_ipath = ipsearch.group(1);

        elif (hatype): # "^\s*<(Array|Hash)Type>"
            if debug: print "ppi(): appending #OBJECT %s = new Object()\n" % path;
            parmblock.append("#OBJECT %s = new Object()\n" % path);
            parmblock = parmblock + process_hash_or_array_type(path, hatype.group(1)); # "Array" or "Hash"
            if debug: print "ppi(): back from calling phat(); next input line = %s\n" % input_lines[0]
            
	# ALSO POSSIBLE TO HAVE "<ArrayType></ArrayType>" (no ArrayItem's)
        
        elif (hatype1): # "^\W*<(Hash|Array)Type>\W*<\/(Hash|Array)Type>\W*$"
            ht1 = hatype1.group(1);
            if debug: print "#FOO ITS_OK ppi found %s type w/no %s items" % (ht1,ht1);
            parmblock.append("#OBJECT %s = new Object()\n" % path);

	#</ParameterItem> => print parmname, parmval, parmblock; done.
        elif (re.search("^\W*<\/ParameterItem>\W*$", line)):

            if (simpleparm):
                if debug: print "HEY ppi(): simpleparm=%s found_ipath=%s" % (simpleparm,found_ipath)
                savelines("#PARM %s = %s\n" % (parmname, parmval));
                #savelines("#COMM %s = %s\n" % (parmname, parmdoc));
            elif (found_ipath):
                savelines("#IPATH %s = new Object()\n" % parmname);
                savelines("#IPATH %s.InstancePath = \"%s\"\n" % (parmname, found_ipath));

            for tmp in parmblock: savelines(tmp);
            break; # We done.

        # BUG/TODO this will break someday i.e. assuming we're done with parmblock just because
        # there's an unrecognized tag...?

        else:
            for tmp in parmblock: print tmp,
            print "\n#%s" % line;
            print "ERROR ParameterItem contains %s\n" % line;
            taglist = "Doc, Name, Val, InstancePath, ArrayType, HashType or /ParameterItem";
            printdie("ERROR shoulda been one of: %s\n" % taglist);

#END def process_parameter_item(firstline, path):


# Comment out given line ONLY IF it's not already commented out.
def commentline(line):
    if (re.search("^\#", line)): return line;

    else: return ("#" + line);
    print "i am next";
    sys.exit(0);


def process_hash_or_array_type(path,itemtype):
#    printdie("process_hash_or_array_type not implemented yet.");

    block = [];
    i = 0;      # Array index starts at zero...

    type = itemtype + "Type";    # "ArrayType" or "HashType"
    item = itemtype + "Item";    # "ArrayItem" or "HashItem"

    new_item   = re.compile ("^\W*<%s>\W*$"  % item);   #  "ArrayItem" or  "HashItem"
    close_type = re.compile("^\W*<\/%s>\W*$" % type);   # "/ArrayType" or "/HashType"

    # An ArrayType is composed of one or more ArrayItem's
    # A HashType is composed of one or more HashItem's

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        if debug: print "phat() processing line %s" % line;

#        print "FOO " + line;

        if new_item.search(line):       # i.e. "HashItem" or "ArrayItem"
            block.append("#" + line);   # Comment-out processed lines.

            subpath = path;
            if (itemtype == "Array"): subpath = "%s[%d]" % (path,i); i = i + 1;

            block = block + process_item(subpath, itemtype); # "[0]", "[1]", "[2]"...

        elif close_type.search(line):   # i.e. "/HashType" or "/ArrayType"
            block.append("#" + line);   # Comment-out processed lines.
            return block;

        else:
            for tmp in block: print tmp;
	    printdie("ERROR shoulda been %sItem or close-Type\n" % itemtype);

def process_item(path,itemtype):
#    printdie("pi not yet implemented");

    block = [];

    # An ArrayItem/HashItem is composed of an ArrayType, a HashType,
    # a simple value (array) or a key-value pair (hash)
    # A simple value is a "<Val>value</Val>" altogether on a line

    item = itemtype + "Item";              #  "ArrayItem" or  "HashItem"
    ct_string = "^\W*<\/%s>\W*$" % item;   # "/ArrayItem" or "/HashItem"


    close_tag = re.compile(ct_string);   # "/ArrayItem" or "/HashItem"

    if (debug): print "#process_item(%s)" % itemtype;

    found_key = 0;
    print_object = 0;
    val = "nuthin";

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        if debug: print "#process_item() processing line %s" % line,;

        findkey = re.search("^\#KEY (.*)",             line);
        findval = re.search("^\s*<Val>([^<]*)<\/Val>", line);

        find_ipath = re.search("^\s*<InstancePath>([^<]+)<\/InstancePath>", line);
        oneliner   = re.search("^\W*<(Hash|Array)Type>\W*<\/(Hash|Array)Type>\W*$", line);


        if (findkey):
            hash_key = findkey.group(1);

	    # ***TODO/BUG/EGREGIOUS HACK ALERT!  Some browsers can't handle "default".
	    # ***TODO/BUG should implement the hack for every "new Object()" not just key
            if (hash_key == "default"):
		print "#DBG implementing egregious DEFAULT hack.\n";
		hash_key = "defaultHACK";    

	    # ***TODO/BUG/EGREGIOUS HACK #2!
	    # This is where I punish you for doing things like foo{"top.DUT.rh"} = 4
	    # i.e. using dots in key names.  I will URL-encode the string and...
	    # (sounds of evil laughter) NEVER UNENCODE IT!!!
	    # Eventually this will break at the other end and someone (probably me)
	    # will have to fix it...

	    hacked_key = encode_dots(hash_key);  # BUG URL URI
            if not (hacked_key == hash_key):
		print "#DBG Oh, the humanity!  Hash-escape hack \"%s\" => \"%s\"" % (hash_key, hacked_key);
		hash_key = hacked_key;

	    path = "%s.%s" % (path,hash_key);
            if debug: print "#foo  path now = %s\n" % path;
            block.append(line);                        # "#KEY" line passes through unchanged.

	# Bypass existing commented-out lines.
        elif (re.search("^\#", line)): block.append(line);


        elif(findval):  # ($line =~ /^\s*<Val>([^<]*)<\/Val>/)
            if debug: print "pi(): appending #OBJECT %s = \"%s\"\n" % (path, findval.group(1));
            block.append("#OBJECT %s = \"%s\"\n" % (path, findval.group(1)));
            block.append("#" + line);    # Comment-out processed lines.

	# BUG/TODO let's call it a "hack"...
        elif (find_ipath):    # ($line =~ /^\s*<InstancePath>([^<]+)<\/InstancePath>/) {
            if debug: print "#FOO in arrayitem; pushing object onto block\n";
            block.append("#OBJECT %s = \"%s\"\n" % (path, findval.group(1)));
            block.append("#" + line);    # Comment-out processed lines.

        elif re.search("^\W*<ArrayType>\W*$", line):
            block.append("#" + line);    # Comment-out processed lines.
	    block.append("#OBJECT %s = new Object()\n" % path);
            if debug: print "#FOO calling process_hash... with path %s\n" % path;
            block = block + (process_hash_or_array_type(path,"Array"));


        elif re.search("^\W*<HashType>\W*$", line):
            block.append("#" + line);    # Comment-out processed lines.
	    block.append("#OBJECT %s = new Object()\n" % path);
            if debug: print "#FOO calling HashType line = %s" % line;
            block = block + (process_hash_or_array_type(path,"Hash"));

	# ALSO POSSIBLE TO HAVE "<ArrayType></ArrayType>" (no ArrayItem's)

        elif (oneliner):    # ($line =~ /^\W*<(Hash|Array)Type>\W*<\/(Hash|Array)Type>\W*$/)
            block.append("#" + line);    # Comment-out processed lines.
            if debug: print "#FOO ITS_OK found %s type w/no %s items\n" % oneliner.group(1);
	    block.append("#OBJECT %s = new Object()\n" % path);

	elif close_tag.search(line):
            block.append("#" + line);    # Comment-out processed lines.
            return block;

        else:
            for tmp in block: print tmp;

	    print "ERROR I am a %s\n" % itemtype;
	    print "ERROR found %s\n"  % line;
	    errmsg = "ERROR shoulda been close-Item tag or one of: (list)\n";
	    printdie(errmsg);




def encode_dots(oldstring):
    """E.g. "dots.and$dollarsigns.are$bad" => "dots%2Eand%24dollarsigns%2Eare%24bad" """

    newstring = "";
    for char in oldstring:
        if   (char == "$"): char = "%24"; # Replace all "." characters with "$2E"
        elif (char == "."): char = "%2E"; # Replace all "$" characters with "%24"
        newstring = newstring + char;
    return newstring;

def process_arg(argv):

    global print_pass;
    global do_pass;

    print_pass = [-1,0,0,0,0,0,0]; # E.g. to print output of pass1, set $print_pass[1] = 1
    do_pass    = [-1,1,1,1,1,1,1]; # Perform only indicated passes

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
    
def printdie(msg): print msg; sys.exit(-1);

def savelines(line):
    if (print_savelines): print line,
    output_lines.append(line);

####################################################################################################


#print encode_dots("hoo");                            print ""
#print encode_dots("a.b.c");                          print ""
#print encode_dots("c.dots.and$dollarsigns.are.bad"); print ""

main();
sys.exit(0);
