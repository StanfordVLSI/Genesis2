<script type="text/javascript"><!--

//    Button_SubmitChanges.Activate("changebutton");


Button_SubmitChanges = new function() {

  this.Activate = Activate;

  function Activate(id) { // id = "changebutton" always
    document.getElementById(id).onclick = submit_changes;
  }

  function submit_changes(e) {
	
      // If curdepth nonzero, there's an open "list-of-hashes" popup that
      // someone forgot to close maybe.  So we call SubmitFunc() directly.
      
      if (SublistMgmt.CurDepth() != 0) { Button_CancelSubmit.SubmitFunc(); }

      // I doubt this will ever happen...
      while (SublistMgmt.CurDepth() > 0) {
          alert("...and now curdepth is " + SublistMgmt.CurDepth());
          alert("WARNING!  Whoa!  It happened!!  See Button_SubmitChanges.js");
          Button_CancelSubmit.SubmitFunc();
      }

      // Build parm string e.g.
      // "curdesign=abc%2Fdef.js&modpath=top&ASSERT=ON&MODE=VERIF&...TILE_ID=0"
      // which would expand to: [
      //     "curdesign='abc/def.js'",      "cgtop.Parameters.ASSERT=ON",
      //     "cgtop.Parameters.MODE=VERIF", "cgtop.Parameters.TILE_ID=0" ]

    // First parm is new design name "clyde" or "ofer"
    var parms = "newdesign=" + encodeURIComponent(NEW_DESIGN_BASENAME);

    // Second parm is current design filename "../designs/tgt0/tgt0-baseline.js"
    parms += "&curdesign=" + encodeURIComponent(CURRENT_DESIGN_FILENAME);

    ////////////////////////////////////////////////////////////////////////
    //    if (e == undefined) {
    //        alert("oops undefined parmbox.  will attempt a recovery.");
    //
    //        var formname = "top";
    //        parms += "&modpath=" + formname;
    //        parms += "&DBG=" + DBG;
    //        var update = CGI_URL + "/updatedesign.pl?" + parms;
    //        window.location = update;
    //        return(0);
    //    }
    ////////////////////////////////////////////////////////////////////////

    // If parmbox undefined, try again from the top.
    if (document.getElementById("parmbox") == undefined) {
        attempt_recovery(parms); return(0);
    }

    // Third parm is module path e.g. "top.dut.regs"
    var formname = document.getElementById("parmbox").name;
    parms += "&modpath=" + formname;

    // Fourth parm is whether to debug
    parms += "&DBG=" + DBG;

    var form = document.getElementById("parmbox").elements;

    // Subsequent parms are the module parameters e.g. "ASSERTION=ON&MODE=VERIF&...TILE_ID=0"
    for (var i = 0; i < form.length; i++) {

        // Form includes <input>s, <select>s and <button>s depending on browser
        // (e.g. Safari/IE include <button>s but Chrome doesn't)
        // Also: form[i].value valid for <select>s on Chrome and Safari
        // but not IE, therefore must use selectIndex
        // Note: want <input>s and <select>s but not (radix-change) <button>s

        // (Can you believe it used to be as simple as this one single line?)
        // parms += "&" + form[i].id + "=" + form[i].value;

        if (DBG) {
            alert("form " + i + '; id = "' + form[i].id + '; value = "' + form[i].value
                  + '"; selectedIndex="' + form[i].selectedIndex + '"'
                  + '"; tagName="' + form[i].tagName + '"'
                  + '"; type="' + form[i].type + '"'
                 );
        }
        if (form[i].tagName == "INPUT") {
            parms += "&" + form[i].id + "=" + form[i].value;
        }
        else if (form[i].tagName == "SELECT") {
            fis = form[i].selectedIndex;
            parms += "&" + form[i].id + "=" + form[i].options[fis].text;
        }
        else {
            // Ignore all others, esp. BUTTON (for radix etc.)
            if (DBG) { alert("Ignoring form " + i); } // Because safari gets confused and thinks buttons are forms...!
        }
    }

    if (SUBPARMS != "") {
	if (DBG) { alert("SUBPARMS = " + SUBPARMS); } // E.g. "&SPECIAL_DATA_MEM_OPS.13.tiecode=40&..."
    }
    parms += SUBPARMS;

    //    var design = CURRENT_DESIGN_FILENAME;
    //    alert('base design name is "' + design + '"'); // E.g. "tgt0-baseline-clyde"

    // Now call cgi script, which will come back with output filename as part of new design base.

    // CGI_URL = e.g. "/cgi-bin/genesis"

    var update = CGI_URL + "/updatedesign.pl?" + parms;

    if (CGI_URL == "STANDALONE") {

        //////////////////////////////////////////////////////////////////////
        //Give the user a command-line string to copy 'n' paste.

        var cli_update = "guisada '" + parms + "'";                        // Build a command.
        document.getElementById("copynpastebox").innerHTML  = cli_update;  // Put it in a box.
        document.getElementById("copynpaste").style.display = "";    // This makes it visible.
        //for positioning, see Browser.js, search for "SetXY"
        return(0);
    }

    //if (DBG) { alert("Bye-bye!  We're off to the land of " + update); }

    ////////////////////////////////////////////////////////////////////////
    // Here we could do an intermediate window.location updated to some file
    // please_wait.htm that looks something like:
    //
    // Please be patient, this can take a couple of minutes,<br>\n
    // especially if the design is large.<br>\n<br>\n
    // 
    // forward-to: CGI_URL + "/tmp_tinymode.pl?" + parms;
    ////////////////////////////////////////////////////////////////////////

    window.location = update;
    return(0);

    var outputfilename = "OUTPUT_FILE_NAME";
    alert("output went to " + outputfilename);
	
//    var s0 = "p.parm0 is equal to " + document.getElementById("p.parm0").value;
//    alert(s0);

    var s = "FOO!  Submit changes to output file " + outputfilename + "!!\n\n";

    s = s + "call cgi script with changes e.g. \n";
    s = s + "cgtop.Parameters.MAX_CYCLES=100000";
    s = s + "&cgtop.SubInstances.dut.SubInstances.pad2des_ifc.Base_Module_Name=template_ifc\n\n";
    s = s + "update design outputfilename.js using sed etc.";
    s = s + "rerun genesis and create a new outputfilename.js";
    s = s + "transfer control to updated design.";

    alert(s);
  }

  function attempt_recovery(parms) {
      alert("oops undefined parmbox.  will attempt a recovery.");
      parms += "&modpath=top";
      parms += "&DBG=" + DBG;
      var update = CGI_URL + "/updatedesign.pl?" + parms;
      window.location = update;
      return(0);
  }
}

//--></script>

