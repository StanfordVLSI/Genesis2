import re;
from decode_globals import input_lines;

#def preprocess_parameters(IL, SL, D):
def preprocess_parameters(SL, D):
    """Process each <ParameterItem> in <Parameters> block"""

    global savelines; savelines = SL;
    global debug;     debug     = D;

    #print "i am preprocess_parameters()";

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

	#<ParameterItem> => process ParameterItem block
        if (re.search("^\W*<ParameterItem>\W*$", line)) : # Process ParameterItem block
	    preprocess_parameter_item(line);

	else : savelines(line); # Print and save for next pass
    #END while
#END def

####################################################################################################
def bypass_type(itemtype):                     # itemtype = "Array" or "Hash"
    #print "i am bypass_type(%s)" % itemtype; 

    close_tag = re.compile("^\W*<\/%sType>\W*$" % itemtype); # "ArrayType" or "HashType"
    block = [];

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        if (debug): print "#bt processing line %s" % line,
        block.append(line);

        if   (re.search("^\W*<ArrayType>\W*$", line)): block = block + bypass_type("Array");
        elif (re.search("^\W*<HashType>\W*$",  line)): block = block + bypass_type("Hash");
        elif (close_tag.search(line)):                 return block;
    #END while
    print "\nERROR decode3_parms0.py:bypass_type() found no close-tag for <%sType>" % itemtype;
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

    global input_lines;

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        doc    = re.search("^\s*<Doc>([^<]*)<\/Doc>",   line);
        name   = re.search("^\s*<Name>([^<]+)<\/Name>", line);
        hatype = re.search("^\s*<(Array|Hash)Type>",    line);

        #<Doc>..</Doc> => save comment
        if (doc) :
            if (doc.group(1) != "") : parmdoc = doc.group(1); # Default is "no comment"

            parmblock.append("#" + line);  # perl: push @parmblock, "\#$line";
            #parmdoc = "\"%s\"" % parmdoc;  # perl: $parmdoc = "\"$parmdoc\""; # this happens later...

        #<Name>..</Name> => save parmname
        elif (name) :
            parmname = name.group(1);                  # $parmname = $1; 
            parmblock.append("#" + line);              # push @parmblock, "\#$line";

        # ALSO POSSIBLE TO HAVE "<ArrayType></ArrayType>" (no ArrayItem's)

        # Skip ArrayType/HashType w/no enclosed Item's
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
            savelines("#COMM %s = \"%s\"\n" % (parmname, parmdoc)) #savelines("#COMM $parmname = $parmdoc\n");
            
            for tmp in parmblock: savelines(tmp);              #savelines(@parmblock, $line);
            savelines(line);

            break; # last; # We done.

        else:
            parmblock.append(line);            # push @parmblock, $line;

    #END while
#END def
