<script type="text/javascript"><!--

ParmBoxForm = new function() {

    var DBG9=0;
//  var DBG9=1;
//  var DBG9=9;

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.Build = Build;            // For normal parm lists.
  this.Build2 = Build2;          // For arrays of hashes.
  this.checkrange = checkrange;
  this.CheckChanges = CheckChanges;

  ///////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                       //
  ///////////////////////////////////////////////////////////////////////

  // E.g. ParmBoxForm.Build(m, m.Parameters, "immutable")'
  function Build(mparent, m, mutability) {  

      var DBG9=DBG9; // As local as we wanna be...

    // BUG/TODO: ugh.
    // Returns an html form containing a list of optionally-readonly parameters (parms)
    //   eg: ParmBoxForm.Build("sublist", sublist[i],             "mutable");
    //   or: ParmBoxForm.Build(    m,     m.Parameters,           "mutable");
    //   or: ParmBoxForm.Build(    m,     m.ImmutableParameters, "immutable");

    if (m == undefined) { return ""; }

    //////////////////////////////////////////////////////////////////////////////
    // A writable form gets id "parmbox" and a read-only form gets id "immparmbox"

    var pltclass = (mutability == "immutable") ?
	           'class="parmlist_table_imm" ' :
                   'class="parmlist_table" '     ;

    var id   = (mutability == "mutable") ? " id=parmbox" : " id=immparmbox";
    var modpath = ModuleNavigator.curpathstring(); // e.g. "top.dut.regs"
    var name = ' name="' + modpath + '"';

    // Want a unique name for the sublist form, something like "sublist<curdepth>"
    // Button_CancelSubmit will use this id to refer to the form unambiguously...
    // see Button_CancelSubmit, search for "form_id"

    if (mparent == "sublist") {
	var form_id = "sublist" + SublistMgmt.CurDepth();
        id = " id=" + form_id;
    }

    var rval = "<form " + id + name + ">\n";
    rval +=    "  <table " + pltclass + ">\n";

    //#  cgtop.path.Parameters.MODE = "VERIF"
    //#  cgtop.path.Parameters.ASSERTION = "ON"
    //#  cgtop.path.ImmutableParameters.MILLIVOLTS = "25"
    //#
    //#  cgtop.path.Comments.MODE = "VERIF to debug."
    //#  cgtop.path.Comments.ASSERTION = "On or off."
    //#  cgtop.path.ImmutableComments.MILLIVOLTS = "Power supply."
    //#
    //#  cgtop.path.Range.MODE = "VERIF NORMAL"
    //#  cgtop.path.Range.ASSERTION = "ON OFF"
    //#  cgtop.path.ImmutableRange.MILLIVOLTS = ",1000,12.5"

    for (pname in m) { // E.g. m["SYNTHESIS"] = "off", m["INSTRS"] = {"add","sub","ld","st"...}

      if (DBG9>1) { alert("pname parm " + pname + " is type " + typeof(m[pname])); }

      var pval =  m[pname];  // E.g. if m["SYNTHESIS"] = "off", pval = "off"

      rval += "    <tr>\n"; // One row per parm

      if (typeof(pval) == "object") {  // E.g. if m["INSTRS"] = {"add","sub","ld","st"...}

	// If a parm is itself an object, the form entry is replaced by a "click to
	// expand" button w/id "subparmlist<n>", where n = the nth subparmlist found.

        var obj_comment;
        if (mutability == "immutable") {
            obj_comment  = mparent.ImmutableComments? mparent.ImmutableComments[pname] : "";
        }
        else {
            obj_comment  = mparent.Comments? mparent.Comments[pname] : "";
        }
	var sublistno = Sublists.RegisterSublist(pname, m[pname], mutability);
          var cte = click_to_expand(pname, sublistno, obj_comment); // This builds the button.
          if (DBG9>1) { alert(cte); }
          rval += cte;
      }
      else {
        // Simple input form for simple parameter.
        rval += parm(mparent, mutability, pname, pval);
      }

      // if mparent = "sublist" it's an array or a hash
      if (mparent=="sublist" && mutability=="mutable") {

          // If it's an array, include buttons to add and subtract array items.
          if (! isNaN(parseInt(pname))) {
              if (DBG9) { alert("looks like we got us a ARRAY"); }
              rval += add_array_edit_button(pname);
          }
          // If it's a hash, don't include anything extra.
          else {
              if (DBG9) { alert("nope guess it's a hash"); }
          }
      }
      rval += "    <\/tr>\n";
    }
    rval += "<\/table><\/form>\n"; //alert(rval);
    if (DBG9) { alert("PBF-B:\n"+rval); }
    return rval;
  }

    function recurse_to_leafs(label, list) { // Only used by Build2, below...

        // Returns a list of parms and values e.g.
        //
        // [ DATA_MEM_OPS.0.name = METALOAD,  DATA_MEM_OPS.0.tiecode = 4,
        //   DATA_MEM_OPS.1.name = METASTORE, DATA_MEM_OPS.1.tiecode = 36,
        //   DATA_MEM_OPS.2.name = SYNCLOAD,  DATA_MEM_OPS.2.tiecode = 2... ]

        if (typeof(list) === 'object') {
            var rval = []; // Declare an array.
            for (var i in list) {
                // On initial call, label=""; don't add a dot unless label is non-null.
                // BUG/TODO I feel like this is not the best way to do this...
                var dot = (label == "") ? "" : ".";
                rtl = recurse_to_leafs((label + dot + i), list[i]);
                rval = rval.concat(rtl);
            }
            return(rval);
        }
        else {
            var rval = label + " = " + list;
            // alert("found leaf: " + rval);
            return( [rval] ); // Return is as an array, so concat() will work.
        }
    }

    function parm_input_box(pname, selparm, comm) {

        var commcell = (comm == "") ? ""              // I just KNOW this is gonna be trouble...
            : "      <td class=parmlist_parmcomm>" + comm + "<\/td>\n";

        // pname is parm e.g. "SYNTHESIS" w/value pval e.g. "OFF"
        var rval =
            "      <td class=parmlist_parmname>" + pname + "<\/td>\n" +
            "      <td class=parmlist_inputcol>\n" +
                   selparm +
            "      <\/td>\n"+
                   commcell;
        return rval;
    }        

    function Build2( // For building a box containing an array of hashes.
        parmname,        // E.g. "INST_OP_LIST"
        list,            // E.g. {"LD",ST","ADD","SUB"}
        mutability)       // "mutable" or "immutable"
    {
        // BUG/TODO HA! Note: arg "parmname" is never used...!

        var rtl = recurse_to_leafs("",list);

        var TMPDBG=0
        ; if (TMPDBG) { alert("rtl=\n" + rtl.join("\n")); }
        list = rtl;

        var pltclass = (mutability == "immutable") ?
	    'class="parmlist_table_imm" ' :
            'class="parmlist_table" '     ;

        var id   = (mutability == "mutable") ? " id=parmbox" : " id=immparmbox";

        ////  var modpath = ModuleNavigator.curpathstring(); // e.g. "top.dut.regs"
        //    var modpath = parmname;
        //    var name = ' name="' + modpath + '"';
        //    name = ' name="top"';
        var name=""; // I need a name??

	var form_id = "sublist" + SublistMgmt.CurDepth();
        var id = " id=" + form_id;
        var rval = "<form " + id + name + ">\n";
        rval +=    "  <table " + pltclass + ">\n";
        
        // list = e.g. [ DATA_MEM_OPS.0.name = METALOAD,   DATA_MEM_OPS.0.tiecode = 4,
        //               DATA_MEM_OPS.1.name = METASTORE,  DATA_MEM_OPS.1.tiecode = 36,
        //               DATA_MEM_OPS.2.name = SYNCLOAD,   DATA_MEM_OPS.2.tiecode = 2...]

        var prev_arrname = "";

        for (var i in list) {

            var parmpair = list[i];
            var pname = parmpair.replace(/ = .*/,""); // regexp; get rid of everything after =
            var pval  = parmpair.replace(/.* = /,""); // regexp; get rid of everything before =

            // alert("found parmpair '" + parmpair + "'\nfound pname '" + pname + "'\nfound pval '" + pval + "'");
            
            var comm ="", range="";
            var ititle   ="";

            var selparm  = use_input(pname, pval, ititle, mutability, range);
            var newrow = parm_input_box(pname, selparm, "");

            var need_sep = false;            // Put a separator hline between array element groups.
            var aeb = "      <td><\/td>\n";  // Default is "no buttons";

            // If it's an array, include buttons to add and subtract array items.

            // Want to extract lowest-level array name e.g.
            // "TOP_HASH.0.colorname.3.cval" => "TOP_HASH.0.colorname.3"

            // var match = /s(amp)le/i.exec("Sample text") // regexp
            // match then contains ["Sample","amp"]        // regexp

            // pname might look like e.g. "0.colorname" or "foo.4.cval"; want to 
            // strip off everything after array index to make e.g. "0" or "foo.4";
            // add_array_edit_buttons() will add pathname to make e.g.
            // "HASHNAME.0" or "HASHNAME.foo.4"

            // So add a dot and match against ".0.colorname" or ".foo.4.cval"
            var match  = /(.*[.][0-9]+)[.].*/.exec("." + pname);
            if ( (mutability == "mutable") && (match)) {

                // Found a mutable array; can add array edit buttons.  Remember to
                // remove the dot from the name, e.g.:
                // "0.colorname" => ".0.colorname" => ".0" => "0"
                // "foo.4.cval" => ".foo.4.cval" => ".foo.4" => "foo.4"

                var arrname = match[1].replace(/./, "");

                // Don't add buttons if array name is exactly equal to previous array name,
                // i.e. only one set of add/sub buttons per array element.

                //alert("arrname:  '" + arrname + "'\nprev_arr: '" + prev_arrname + "'");

                if (arrname != prev_arrname) {
                    if (prev_arrname != "") { need_sep = true; }  // Add a separator row.

                    prev_arrname = arrname;

                    // alert("Adding buttons to array '" + arrname);
                    aeb = add_array_edit_button(arrname);
                    //alert("newrow:\n" + newrow + "\n----------------------\n" + aeb);
                }
            }
            newrow += aeb;
            newrow += "    <\/tr>\n";
            if (need_sep) {
                rval += "    <tr><td colspan=3>-------------------<\/td><\/tr>\n";
            }
            rval += newrow;
        }
        rval += "<\/table><\/form>\n"; //alert(rval);
        return(rval);
    }

  function add_array_edit_button(pname) {

      if (DBG9) { alert("okay now adding array edit buttons..."); }

      var psource = " src=" + HOME_URL + "/images/plusbutton.png";
      var msource = " src=" + HOME_URL + "/images/minusbutton.png";

      var item_name = SublistMgmt.PathName() + "." + pname; // E.g. "DATA_MEM_OPS.13"

      var pclick = " onclick=\"ArrayEdit.clone()\"";

      // UGH!  Is there no easy way to make this any more readable!!!  Hate the quotes!!!
      // E.g. ' onclick="ArrayEdit.del('DATA_MEM_OPS.13','cloneme')"'
      var mclick = " onclick=\"ArrayEdit.edit("
          + "'" + item_name + "'"               // 'DATA_MEM_OPS.13'
          + ", 'deleteme')\"";

      var pclick = " onclick=\"ArrayEdit.edit("
          + "'" + item_name + "'"               // 'DATA_MEM_OPS.13'
          + ", 'cloneme')\"";

      // alert("mclick= " + mclick + "\npclick = " + pclick)

      var rval = "      <td class=ae_button_cell>"+
          "<img class=ae_button" + psource + pclick + " />"+
          "<img class=ae_button" + msource + mclick + " />"+
          "<\/td>\n";

      if (DBG9) { alert("PBF-AAEB0:\n" + rval); }
      return rval;
  }

  function click_to_expand(pname, sublistno, comm) {
    // Parm is a list; make a button for pop-up submenu.

    var commcell = (comm == "") ?
        "" : "      <td class=parmlist_parmcomm>" + comm + "<\/td>\n";

    var ce_div = "<div class=expandlistbox id=subparmlist" + sublistno + ">(click to expand)<\/div>\n";

    return ("      <td class=parmlist_parmname>" + pname + "<\/td>\n" +
            "      <td class=expandlist>\n" +
            "          " + ce_div + 
            "      <\/td>\n" +
            // "      <td class=parmlist_parmcomm>" + comm + "<\/td>\n"
            commcell + 
            "");
  }

    function parm(mparent, mutability, pname, pval) {

        // Comment and range info.
        var comm="", range="";
        if (mutability == "immutable") {
            comm  = mparent.ImmutableComments? mparent.ImmutableComments[pname] : "";
            range = mparent.ImmutableRange?    mparent.ImmutableRange[pname]    : "";
        }
        else {
            comm  = mparent.Comments? mparent.Comments[pname] : "";
            range = mparent.Range?    mparent.Range[pname]    : "";
        }
        if (range == undefined) { range = "no range info"; }
        
        // "ititle" is floatbox with range and comment information about the parm
        var ititle = comm + " :: " + range;
        ititle = "title='" + ititle + "' ";  // Why was this turned off?
        
        // If there's a list (range of specific values) associated with a parameter,
        // and if the parameter is user-changeable (mutable), use a "select" box.
        // Otherwise use a simple text entry box (read-only for immutable parms).
        //
        // BUG/TODO instead of (list != "") could use regexp list =~ /.+/
        var list=build_list_from_range(range);

        var selparm;
        var selectable = (list != "") && (mutability == "mutable");

        if (selectable) {
            // Use a drop-down menu to *select* among a small set of available choices.
            selparm = use_select(pname, pval, ititle, list);
        }
        else {
            // Use a text-input box to get value from user.
            selparm = use_input(pname, pval, ititle, mutability, range);
        }
        var rval = parm_input_box(pname, selparm, comm);
        return(rval);
    }

    function build_list_from_range(range) {

        // E.g. range=       returnval =
        // -----------       ----------------------------------
        // "0,10,100"        "0 10 20 30 40 50 60 70 80 90 100"
        // "1,10,100"        "1 11 21 31 41 51 61 71 81 91"
        // "on off"          "on off"
        // "1,10"            "1 2 3 4 5 6 7 8 9 10"
        // ",,,"             ""
        // "1,,"             ""
        
        if (range == "no range info") { return ""; }
        
        var list = "";

      //if (range.match(/^\d*,\d*,\d*$/)) { // regexp
        // Sometimes range = e.g. '0x0,,'
       
        if (range.match(/^[^,]*,[^,]*,[^,]*$/)) { // regexp

            var LDBG = (DBG9 == 9) ? 1 : 0;
            
            // E.g. range= "0,100,10" or "1,," or ",,," or "0xFFFF,,"
            
            if (LDBG) { alert("found range '" + range + "'"); }

            var ra = range.split(","); // "0,100,10" => ['0','100','10']

            if (LDBG) { alert("range = " + range + 
                              "\nparseInt(ra[0]) = " + parseInt(ra[0]) + 
                              "\nparseInt(ra[1]) = " + parseInt(ra[1]) + 
                              "\nparseInt(ra[2]) = " + parseInt(ra[2]) ); }

            // Give up if min or max are undefined; (can't build a list).

//            var min, max, step;
//            if (ra[0] == "") { return ""; } else { min  = parseInt(ra[0]); }
//            if (ra[1] == "") { return ""; } else { max  = parseInt(ra[1]); }
//            if (ra[2] == "") { step =  1; } else { step = parseInt(ra[2]); }

            var min = parseInt(ra[0]); 
            var max = parseInt(ra[1]);
            var step = (ra[2] == "") ? 1 : parseInt(ra[2]); // Default == 1

            if (isNaN(min) || isNaN(max) || isNaN(step)) { return ""; }

            if (LDBG) { alert("found min  '" + min  + "'"); }
            if (LDBG) { alert("found max  '" + max  + "'"); }
            if (LDBG) { alert("found step '" + step + "'"); }

            var nchoices = parseInt((max-min)/step) + 1;
                
            list = min;
            if (nchoices > 50) { list = ""; } // Too much!!  Give up.
            else if (nchoices > 1) {
                for (var i=min+step; i<=max; i+=step) {
                    list = list + " " + i;
                }
            }
            // E.g. now list = "0 10 20 30 40 50 60 70 80 90"
        }
        else if (range.match(/\S+/)) { list = range; } // E.g. "on off maybe" (regexp)

//      alert("Built list: '" + list + "'" + "\nfrom range: '" + range + "'");
        return (list + "");                            // Ensures that return value is a string?
    }

    function add_radix_button(pname, visibility) {

        // For selectable boxes, button_props means button is invisible.
        // Still need button, however, or things don't line up.

        var button_props = (visibility == "visible") ?
            " onclick=\"toggle_radix('" + pname + "')\" id=pr_active" :  // show the change-radix button.
            " style=\"visibility:hidden\"";                              // hide the change-radix button.

        var rval = "<button class=parmlist_radix form=nobody " + button_props + ">R<\/button>\n";
        return rval;
    }

    function use_input(pname, pval, ititle, mutability, range)  {
        var iclass = (mutability == "immutable") ?
            "class=parmlist_input_imm readonly "  :
            "class=parmlist_input "               ;

        var radix_button_visibility = "invisible";

        // If parm val is a number, add a button to toggle hex <=> dec
        var isNumber = (pval.match(/^[0-9]+$/) || pval.match(/^0x[0-9a-fA-F]+$/)); // regexp
        if (isNumber) {
            radix_button_visibility = "visible";    // Activate the change-radix button
            
            // If number is > 256, represent it as hex (I've got a bad feeling about this...!)
            pval = parseInt(pval);  // Changes to decimal number instead of e.g. possibly-hex string.
            if (pval > 256) { pval = "0x" + (pval.toString(16)).toUpperCase(); } // E.g. "511" => "1FF"
        }

        var itype  = " type='text' ";
        var iid    = " id=" + pname;
        var ivalue = " value='" + pval;
        var oc_args = "'" + pname + "','" + range + "'";
        var onchange = "onchange=\"ParmBoxForm.checkrange(" + oc_args + ")\" ";

        var rval = "        <input " + onchange + iclass + ititle + itype + iid + ivalue + "'/>\n"
            + add_radix_button(pname, radix_button_visibility);

        //alert("rval = \n" + rval);
        return rval;
    }

    function checkrange(pname, range) {
        var pval = document.getElementById(pname).value;

        //alert("value of " + pname + " is " + pval + " and range is " + range);

        // Check to see if somebody changed a non-hashlist parm; make a note of it.
        // Parm is from a hashlist if pname starts with a number, e.g. pname = "0.colorval"
        if (! pname.match(/^[0-9]/)) { ParmBoxForm.CheckChanges(); }
//      else { alert("Oh it's a hashlist; I won't do CheckChanges then."); }

        // For now, just check min and max.
        if (range.match(/^[^,]*,[^,]*,[^,]*$/)) { // regexp

            var LDBG = (DBG9 == 9) ? 1 : 0;
            
            // E.g. range= "0,100,10" or "1,," or ",,," or "0xFFFF,,"
            
            if (LDBG) { alert("found range '" + range + "'"); }

            var ra = range.split(","); // "0,100,10" => ['0','100','10']
        
            var min = parseInt(ra[0]);
            var max = parseInt(ra[1]);

            if (LDBG) { alert("\nmin = " + min + "\nmax = " + max + "\npval = " + pval); }

            if (! isNaN(min)) {
                if (pval < min) { alert("WARNING: Entered value '" + pval + " for " +
                                        pname + "' less than allowed min '" + min); }
            }
            if (! isNaN(max)) {
                if (pval > max) { alert("WARNING: Entered value '" + pval + " for " +
                                        pname + "' greater than allowed max '" + max); }
            }
        }
    }

    function use_select(pname, pval, title, options_string) {
        // TODO/BUG in actuality, quote marks in a comment (below) will probably break things badly.
        // E.g. title = "title='your choices are "foofy" or "boo"'
        // E.g. options_string  = "foofy boo"

        var iclass = "class=parmlist_input ";
        var itype  = " type='text' ";
        var iid    = " id=" + pname;

        // Want to take note when a parm changes.
        var onchange = "onchange=\"ParmBoxForm.CheckChanges();\" ";

        var select1 = "        <select " + onchange + iclass + title + itype + iid + ">\n";
        var select2 = "        <\/select>\n";

        if (DBG9) { alert("splitting options string '" + options_string + "'"); }

        // Split "options_string" into component parts.
        var option_list = options_string.split(" ");    // E.g. "1 2 3" => ("1","2","3")

        // Want options list w/pval already selected e.g.
        // "          <option>RED<\/option>\n"
        // "          <option>GREEN<\/option>\n"
        // "          <option>BLUE<\/option>\n"
        // "          <option selected="selected">POIPLE<\/option>\n"

        var options_html = "";
        var unselected   = "<option>";
        var selected     = "<option selected='selected'>";
        for (var i in option_list) {
            var opt = (option_list[i] == pval) ?  "<option selected='selected'>" : "<option>";
            options_html += ("          " + opt + option_list[i] + "<\/option>\n");
        }
        var rval = select1 + options_html + select2
            + add_radix_button(pname, "invisible");

//        if (DBG9) { alert("now rval = \n" + rval); }
        return rval;
    }

    function CheckChanges() {
        if (SublistMgmt.CurDepth() == 0) {
            // Somebody changed a parm at level 0; make a note of it.
            // (levels higher than zero (hashlists) take care of themselves.
            if (DBG9) { alert("onchange triggered a pending parmchange"); }
            PENDING_PARMCHANGE = true;  
        }
    }

}

// Global sorta, I guess.  Only used in the one place below for an "onclick"
function toggle_radix(pname) {
    var DBG9=0;
    function ldbg(s) { if (DBG9) { alert(s); } }

    var pval = document.getElementById(pname).value;

    ldbg('Toggle dec/hex the radix of ' + pname + ' = ' + pval);

    var isdec = pval.match(/^[0-9]+$/);          // regexp
    var isbin = pval.match(/^0b[10]+$/);         // regexp
    var ishex = pval.match(/^0x[0-9a-fA-F]+$/);  // regexp

    if      (isbin) { ldbg(pval + " isbin"); }
    else if (ishex) { ldbg(pval + " ishex"); }
    else if (isdec) { ldbg(pval + " isdec"); }
    else            { alert("not a number"); }

    if (isbin) { // alert("bin => hex");
      alert("No current support for binary!");
        return;
    }

    // parseInt 1) makes sure pval is a number and not a string and
    // 2) converts to decimal if it's hex.
    var pval_dec = parseInt(pval); // E.g. "0x1fF" => "511" or "511" => "511"
    ldbg('As a decimal number: ' + pval);

    if (ishex) {
        ldbg("hex " + pval + "=> dec " + pval_dec);
        pval = pval_dec;
    }
    else if (isdec) {
        var pval_hex = "0x" + (pval_dec.toString(16)).toUpperCase(); // E.g. "511" => "1FF"
        ldbg("dec " + pval + "=> hex " + pval_hex);
        pval = pval_hex;
    }
    document.getElementById(pname).value = pval;
}

//--></script>
