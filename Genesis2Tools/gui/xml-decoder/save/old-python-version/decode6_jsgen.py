import re;

from decode_globals import input_lines;
#def generate_javascript(IL, output_lines, SL, D):
#def generate_javascript(IL, SL, D):
def generate_javascript(SL, D):

#    global input_lines; input_lines = IL;
    global savelines;   savelines   = SL;
    global debug;       debug       = D;

    # Final pass to generate javascript.

    javascript_header  = "<script type=\"text/javascript\"><!--";
    javascript_trailer = "//--></script>";
    javascript_sep     = javascript_trailer + "\n\n" + javascript_header;

    print javascript_header;

#    print "\n\nFOO %d\n\n" % len(input_lines);

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
            if debug: print "fp(): ignored line %s" % line

    # END while (input_lines):

    print javascript_trailer;

# END def final_pass()
                      

def printpath(tag):
    """E.g. printpath(2, ["cgtop","DUT","p0"]) => "cgtop.DUT"""

    debugpp = 0
    if debugpp: print "\nEntering printpath(%s)" % (tag);

    rval = tag[0];
   

#    for i in range(1,plevel+1):                    # perl: for (i=1; i <= plevel; i++)
    for i in range(1,len(tag)):                    # perl: for (i=1; i <= plevel; i++)


        rval = "%s.%s" % (rval, tag[i]);
        if debugpp: print "    pp says: (i,rval,tag[i] = %d,%s,%s" % (i,rval,tag[i]);

    if (debugpp): print "    printpath(%s) = %s\n" % (tag,rval);
    return rval;

####################################################################################################
