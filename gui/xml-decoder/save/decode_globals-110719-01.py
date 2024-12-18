global input_lines; input_lines = [];
global output_lines; output_lines = [];

global print_savelines; print_savelines = 0;

def savelines(line):

    global print_savelines;

#    print "HYYin %d" % len(input_lines);
#    print "HYout %d" % len(output_lines);

    if (print_savelines): print line,
    output_lines.append(line);

#    print "HXout %d\n" % len(output_lines);

def reset_buffer():
    global output_lines;
    output_lines = [];
