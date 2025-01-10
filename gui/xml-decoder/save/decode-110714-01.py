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
    #PASS5: FINAL (MAIN) PASS

#END def main()
####################################################################################################

def final_pass(): print "not yet implemented"; sys.exit(0);

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
            
            savelines("#NAME %s\n" % parmname);                  #savelines("#NAME $parmname\n");
            savelines("#COMM %s = %s\n" % (parmname, parmdoc)) #savelines("#COMM $parmname = $parmdoc\n");
            
            for tmp in parmblock: savelines(tmp);            #savelines(@parmblock, $line);
            savelines(line);

            break; # last; # We done.

        else:
            parmblock.append(line);            # push @parmblock, $line;

####################################################################################################
def process_parameter_items():
    print "i am process_parameter_items";

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
    print "i am process_parameter_item(\n    \"%s    \"%s\n)" % (firstline, path);

    parmdoc = ""; parmname = ""; parmval = "";

    parmblock = ["#" + firstline]; # Save lines until parm block is completely processed

    simpleparm = 0; found_ipath = 0;

    parmname = path;

    print "#foo found parameteritem block with name %s" % path;

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

	print "#foo processing line %s" % line;

        # Comment-out all lines not already commented-out.
        parmblock.append(commentline(line));

        valsearch = re.search("^\s*<Val>([^<]*)<\/Val>", line);
        ipsearch  = re.search("^\s*<InstancePath>([^<]+)<\/InstancePath>", line);
        hatype    = re.search("^\s*<(Array|Hash)Type>", line);
        hatype1   = re.search("^\W*<(Hash|Array)Type>\W*<\/(Hash|Array)Type>\W*$", line); # one-liner

        if (re.search("^\#", line)) : ();      # Do nothing (does this work??)

	# ("Name" and "Doc" have already been processed in a prior pass.)

	#<Val>..</Val> => save parmval
        elif (valsearch):
	    parmval = "\"%s\"" % valsearch.group(1);
	    simpleparm = 1;

        elif (ipsearch):
            found_ipath = ipsearch.group(1);

        elif (hatype):
            parmblock.append("#OBJECT %s = new Object()" % path);
            parmblock = parmblock + process_hash_or_array_type(path, hatype.group(1)); # "Array" or "Hash"
            
	# ALSO POSSIBLE TO HAVE "<ArrayType></ArrayType>" (no ArrayItem's)
        
        elif (hatype1):
            ht1 = hatype1.group(1);
	    print "#FOO ITS_OK ppi found %s type w/no %s items" % (ht1,ht1);
            parmblock.append("#OBJECT %s = new Object()" % path);

	#</ParameterItem> => print parmname, parmval, parmblock; done.
        elif (re.search("^\W*<\/ParameterItem>\W*$", line)):

            if (simpleparm or found_ipath):
                savelines("#IPATH %s = new Object()\n" % parmname);
                savelines("#IPATH %s.InstancePath = \"%s\"\n" % (parmname, found_ipath));
            else:
                savelines("#PARM %s = %s\n" % (parmname, parmval));
                #savelines("#COMM %s = %s\n" % (parmname, parmdoc));

        for tmp in parmblock: savelines(tmp);
        break; # We done.
    else:
        for tmp in parmblock: print tmp
        print "\n\n#%s" % line;
        print "ERROR ParameterItem contains %s\n" % line;
        taglist = "Doc, Name, Val, InstancePath, ArrayType, HashType or /ParameterItem";
        printdie("ERROR shoulda been one of: %s\n" % taglist);

#END def process_parameter_item(firstline, path):


#BUG/TODO BUG/TODO BUG/TODO BUG/TODO BUG/TODO  restart here


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

        print "FOO " + line;

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

    if (debug): print "#foo pi I am a %s\n"      % itemtype,;
    if (debug): print "#foo pi close-tag = %s\n" % ct_string,;

    found_key = 0;
    print_object = 0;
    val = "nuthin";

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

	print "#process_item processing line %s" % line,;
	print "#close-tag = %s\n"                % ct_string,;

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
		print "#DBG Oh, the humanity!  Hash-escape hack \"%s\" => \"%s\"\n" % (hash_key, hacked_key);
		hash_key = hacked_key;

	    path = "%s.%s" % (path,hash_key);
	    print "#foo  path now = %s\n" % path;
            block.append(line);                        # "#KEY" line passes through unchanged.

	# Bypass existing commented-out lines.
        elif (re.search("^\#", line)): block.append(line);


        elif(findval):  # ($line =~ /^\s*<Val>([^<]*)<\/Val>/)
	    print "#FOO in arrayitem; pushing object onto block\n";
            block.append("#OBJECT %s = \"%s\"\n" % (path, findval.group(1)));
            block.append("#" + line);    # Comment-out processed lines.

	# BUG/TODO let's call it a "hack"...
        elif (find_ipath):    # ($line =~ /^\s*<InstancePath>([^<]+)<\/InstancePath>/) {
	    print "#FOO in arrayitem; pushing object onto block\n";
            block.append("#OBJECT %s = \"%s\"\n" % (path, findval.group(1)));
            block.append("#" + line);    # Comment-out processed lines.

        elif re.search("^\W*<ArrayType>\W*$", line):
            block.append("#" + line);    # Comment-out processed lines.
	    block.append("#OBJECT %s = new Object()\n" % path);
	    print "#FOO calling process_hash... with path %s\n" % path;
            block.append(process_hash_or_array_type(path,"Array"));


        elif re.search("^\W*<HashType>\W*$", line):
            block.append("#" + line);    # Comment-out processed lines.
	    block.append("#OBJECT %s = new Object()\n" % path);
	    print "#FOO calling HashType line = %s" % line;
            block.append(process_hash_or_array_type(path,"Hash"));

	# ALSO POSSIBLE TO HAVE "<ArrayType></ArrayType>" (no ArrayItem's)

        elif (oneliner):    # ($line =~ /^\W*<(Hash|Array)Type>\W*<\/(Hash|Array)Type>\W*$/)
            block.append("#" + line);    # Comment-out processed lines.
	    print "#FOO ITS_OK found %s type w/no %s items\n" % oneliner.group(1);
	    block.append("#OBJECT %s = new Object()\n" % path);

	elif close_tag.search(line): return block;

        else:
            for tmp in block: print tmp;

	    print "ERROR I am a %s\n" % itemtype;
	    print "ERROR found %s\n"  % line;
	    errmsg = "ERROR shoulda been close-Item tag or one of: (list)\n";
	    printdie(errmsg);






















def encode_dots(oldstring):
    """E.g. "dots.and$dollarsigns.are$bad" => "dots%2Eand%24dollarsigns%2Eare%24bad" """
#    printdie("ed not yet implemented");

    newstring = "";
    for char in oldstring:
        print "hyde c = " + char;
        if   (char == "$"): char = "%24"; # Replace all "." characters with "$2E"
        elif (char == "."): char = "%2E"; # Replace all "$" characters with "%24"
        newstring = newstring + char;

    return newstring;

#    foreach my $c (split //, $oldstring) {
#	if    ($c eq "\$") { $c = "\$24"; }
#	elsif ($c eq  ".") { $c = "\$2E"; }
#	$newstring .= $c;
#    }
#    return $newstring;
#}
#
#
#
#
#









def process_arg(argv):

    global print_pass;
    global do_pass;

    print_pass = [-1,0,0,0,0,0]; # E.g. to print output of pass1, set $print_pass[1] = 1
    do_pass    = [-1,1,1,1,1,1]; # Perform only indicated passes

    print "";
    print "print_pass =%s" % print_pass;
    print "do_pass    =%s" % do_pass;

    if len(argv) > 1:
           
        arg = argv[1];
        print "# arg = \"%s\"" % arg;    # E.g. "-12345" => "print results of all five passes"

        # (Quit after highest printpass)

        tmpmsg = "#...we will show pass %%d/%d" % (len(print_pass)-1);

        if re.search("1", arg): print_pass[1] = 1; print tmpmsg % 1; do_pass = [-1,1,0,0,0,0];
        if re.search("2", arg): print_pass[2] = 1; print tmpmsg % 2; do_pass = [-1,1,1,0,0,0];
        if re.search("3", arg): print_pass[3] = 1; print tmpmsg % 3; do_pass = [-1,1,1,1,0,0];
        if re.search("4", arg): print_pass[4] = 1; print tmpmsg % 4; do_pass = [-1,1,1,1,1,0];
        if re.search("5", arg): print_pass[5] = 1; print tmpmsg % 5; do_pass = [-1,1,1,1,1,1];
        if re.search("6", arg): print_pass[6] = 1; print tmpmsg % 6; do_pass = [-1,1,1,1,1,1];
        print ""
    
def printdie(msg): print msg; sys.exit(-1);

def savelines(line):
    if (print_savelines): print line,
    output_lines.append(line);

####################################################################################################
print encode_dots("hoo");                            print ""
print encode_dots("a.b.c");                          print ""
print encode_dots("c.dots.and$dollarsigns.are.bad"); print ""
####################################################################################################
main();
sys.exit(0);
