import re;
from decode_globals import input_lines;

#def preprocess_subinsts(input_lines, savelines, debug):
def preprocess_subinsts(savelines, debug):
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

    while (input_lines):
        line = input_lines[0];

        # Not interested unless we find a "SubInstanceItem" block.

        if (not (re.search("^\W*<SubInstanceItem>\W*$", line))) :
            savelines(line);    # Save lines in "output_lines" block for next pass.
            input_lines.pop(0); # (pop(0) == shift);
            continue;

        process_subinst_item(savelines);

    # END while (input_lines)
# END def preprocess_subinsts

def process_subinst_item(savelines):
    #<SubInstanceItem> alone on a line: start looking for InstanceName.

    #saveblock = ["#" + line];  # Save lines until parm block is completely processed
    saveblock = [];

    while (input_lines):
        subline = input_lines[0];
        input_lines.pop(0); # (pop(0) == shift);

        saveblock.append(subline);

        match_iname = re.search("^\s*<InstanceName>([^<]+)</InstanceName>" , subline);

        if re.search(subline, "^\W*<SubInstanceItem>\W*$"):
            printdie("ERROR: no InstanceName before SubInstanceItem");

        elif re.search(subline, "^\W*</SubInstanceItem>\W*$"):
            printdie("ERROR: no InstanceName in SubInstanceItem block");

        #elsif ($subline =~ /^\s*<InstanceName>([^<]+)<\/InstanceName>/) {
        elif match_iname:

            # Found InstanceName; write it out, along with saved lines.
            savelines("#SUBINST %s\n" % match_iname.group(1));
            for tmp in saveblock : savelines(tmp);
            break;   # We done (with SubInstanceItem block) (python "break" = perl "last").

        #END elif match_iname
    #END while (input_lines)
# END def preprocess_subinst_item

