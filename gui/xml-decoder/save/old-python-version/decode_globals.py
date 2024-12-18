input_lines = [];
output_lines = [];
print_savelines = 69;

def savelines(line):
    global print_savelines, output_lines;
    if (print_savelines): print line,
    output_lines.append(line);

def output_from_this_pass_becomes_input_to_next_pass():

    global input_lines;         # Why?  Necessary, but...why? Maybe because: first mod will create new local.
    global output_lines;        # Why?  Necessary, but...why?

    #    print "FOO  %4d %4d" % (len(input_lines), len(output_lines));

    # Line below breaks because an assignment ALWAYS creates a local.  Right?

    #input_lines = output_lines;                           # This breaks.  Why?  Changes the pointer, right?


    # This (below) works because we're not creating a new input_lines; we're modifying
    # the one that already exists.
   
    for line in output_lines: input_lines.append(line);   # This works.  It's maddening.

    output_lines = [];  # Again; not so much an assignment as a mod of existing?
