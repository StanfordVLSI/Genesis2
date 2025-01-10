import re;
from decode_globals import input_lines;

#def process_parameter_items(IL, SL, D):
def process_parameter_items(SL, D):

    global savelines;   savelines   = SL;
    global debug;       debug       = D;

    global debug5; debug5 = 0;
#    if (decode.print_savelines): debug5 = (debug or debug5);
    if debug5: print "\nprocess_parameter_items() begin";

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

    #END while
#END def

def process_parameter_item(firstline, path):
   #print "i am process_parameter_item(\n    \"%s    \"%s\n)" % (firstline, path);

    parmdoc = ""; parmname = ""; parmval = "";
    parmblock = ["#" + firstline]; # Save lines until parm block is completely processed

    simpleparm = 0; found_ipath = 0;

    parmname = path;

    if debug5: print("\nppi(): found parameteritem block with name %s" % path);

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        if debug5: print "ppi() processing line %s" % line,;

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
            if debug5: print "ppi() found parmval %s\n" % parmval;
	    simpleparm = 1;

        elif (ipsearch): # "^\s*<InstancePath>([^<]+)<\/InstancePath>"
            found_ipath = ipsearch.group(1);

        elif (hatype): # "^\s*<(Array|Hash)Type>"

            if debug5: print "ppi(): appending #OBJECT %s = new Object()" % path;
            parmblock.append("#OBJECT %s = new Object()\n" % path);
            parmblock = parmblock + process_hash_or_array_type(path, hatype.group(1)); # "Array" or "Hash"
            if debug5: print "ppi(): back from calling phat(); next input line = %s\n" % input_lines[0]
            
	# ALSO POSSIBLE TO HAVE "<ArrayType></ArrayType>" (no ArrayItem's)
        
        elif (hatype1): # "^\W*<(Hash|Array)Type>\W*<\/(Hash|Array)Type>\W*$"
            ht1 = hatype1.group(1);
            if debug5: print "#FOO ITS_OK ppi found %s type w/no %s items" % (ht1,ht1);
            parmblock.append("#OBJECT %s = new Object()\n" % path);

	#</ParameterItem> => print parmname, parmval, parmblock; done.
        elif (re.search("^\W*<\/ParameterItem>\W*$", line)):

            if (simpleparm):
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
        #END if-then-else
    #END while
#END def process_parameter_item(firstline, path):


# Comment out given line ONLY IF it's not already commented out.
def commentline(line):
    if (re.search("^\#", line)): return line;

    else: return ("#" + line);
    print "i am next";
    sys.exit(0);


def process_hash_or_array_type(path,itemtype):
#    printdie("process_hash_or_array_type not implemented yet.");

#    block = [];
    block = ["#OBJECT %s = new Object()\n" % path];

    i = 0;      # Array index starts at zero...

    type = itemtype + "Type";    # "ArrayType" or "HashType"
    item = itemtype + "Item";    # "ArrayItem" or "HashItem"

    new_item   = re.compile ("^\W*<%s>\W*$"  % item);   #  "ArrayItem" or  "HashItem"
    close_type = re.compile("^\W*<\/%s>\W*$" % type);   # "/ArrayType" or "/HashType"

    # An ArrayType is composed of one or more ArrayItem's
    # A HashType is composed of one or more HashItem's

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        if debug5: print "\nphat() processing line %s" % line;

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

    if (debug5): print "process_item(%s)" % itemtype;

    found_key = 0;
    print_object = 0;
    val = "nuthin";

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        if debug5: print "process_item() processing line %s" % line,;

        findkey = re.search("^\#KEY (.*)",             line);
        findval = re.search("^\s*<Val>([^<]*)<\/Val>", line);

        find_ipath = re.search("^\s*<InstancePath>([^<]+)<\/InstancePath>", line);
        oneliner   = re.search("^\W*<(Hash|Array)Type>\W*<\/(Hash|Array)Type>\W*$", line);

        global counter;

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
                fmt = "#\n#WARNING Oh, the humanity!  Hash-escape hack \"%s\" => \"%s\"\n#";
		print fmt % (hash_key, hacked_key);

		hash_key = hacked_key;

	    path = "%s.%s" % (path,hash_key);
            block.append(line);                        # "#KEY" line passes through unchanged.

	# Bypass existing commented-out lines.
        elif (re.search("^\#", line)): block.append(line);

        elif(findval):  # ($line =~ /^\s*<Val>([^<]*)<\/Val>/)
            if debug5: print "pi(): appending #OBJECT %s = \"%s\"" % (path, findval.group(1));
            block.append("#OBJECT %s = \"%s\"\n" % (path, findval.group(1)));
            block.append("#" + line);    # Comment-out processed lines.

	# BUG/TODO let's call it a "hack"...
        elif (find_ipath):    # ($line =~ /^\s*<InstancePath>([^<]+)<\/InstancePath>/) {
            if debug5: print "#FOO in arrayitem; pushing object onto block\n";
            block.append("#OBJECT %s = \"%s\"\n" % (path, findval.group(1)));
            block.append("#" + line);    # Comment-out processed lines.

        elif re.search("^\W*<ArrayType>\W*$", line):
            block.append("#" + line);    # Comment-out processed lines.
	    block.append("#OBJECT %s = new Object()\n" % path);
            block = block + (process_hash_or_array_type(path,"Array"));

        elif re.search("^\W*<HashType>\W*$", line):
            block.append("#" + line);    # Comment-out processed lines.
	    block.append("#OBJECT %s = new Object()\n" % path);
            if debug5: print "#FOO calling HashType line = %s" % line;
            block = block + (process_hash_or_array_type(path,"Hash"));

	# ALSO POSSIBLE TO HAVE "<ArrayType></ArrayType>" (no ArrayItem's)

        elif (oneliner):    # ($line =~ /^\W*<(Hash|Array)Type>\W*<\/(Hash|Array)Type>\W*$/)
            block.append("#" + line);    # Comment-out processed lines.
            if debug5: print "#FOO ITS_OK found %s type w/no %s items\n" % oneliner.group(1);
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

#END def

