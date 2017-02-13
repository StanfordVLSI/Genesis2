import re;

def preprocess_subinsts(input_lines, output_lines, savelines):
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

#def savelines(line):
#    if (print_savelines): print line,
#    output_lines.append(line);
#
#
