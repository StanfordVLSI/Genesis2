import re;
from decode_globals import input_lines;

#def process_hashkeys(IL, SL, D):
def process_hashkeys(SL, D):

    global savelines;   savelines   = SL;
    global debug;       debug       = D;

    # Move hash key to top of "HashItem" block

    while (input_lines):
        line = input_lines[0]; input_lines.pop(0);     # (pop(0) == shift);

        savelines(line);
        if (re.search("^\W*<HashItem>\W*$", line)) :
            hashlines = find_hashkey();
            for tmp in hashlines : savelines(tmp);
        #END if

    #END while
#END def

def find_hashkey():
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
