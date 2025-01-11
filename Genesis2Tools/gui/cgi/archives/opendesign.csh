#!/bin/csh -f

echo "Content-type: text/html\n\n";


set error_header = "<head><title>ChipGen Error</title></head><h1>ChipGen Error</h1>\n\n";
set dbg_msg = "<p><i>Found newdesign \"$INPUT{newdesign}\"<br />Found filename \"$INPUT{file}\"</i><br /><br />\n\n";

# Forgot newdesign name?

    echo $error_header;
    echo "<p>Oops, you forgot to choose a new design name.<br />\n";
    echo "Please use your browser's BACK button to go back and try again.\n";
    echo $dbg_msg;
    exit;

    echo '<script type="text/javascript"><!--'."\n";
    echo "alert(\'hello');\n";
    echo '//--></script>'."\n\n";

