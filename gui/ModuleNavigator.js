<script type="text/javascript"><!--

ModuleNavigator = new function () {

  var DBG9 = 0;

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.UpModule      = UpModule;    // Pop out to enclosing module.  
  this.DownModule    = DownModule;  // DownModule("dut") => Push into submodule "dut"
  this.OpenTopModule = DownModule;  // OpenTopModule("top") == DownModule("top")
  this.OpenSubmodule = DownModule; 
  this.GotoModule    = GotoModule;  // GotoModule("top.DUT") => push into "cgtop" then "DUT"

  this.GetSubmodule = GetSubmodule;

  this.curpathstring = curpathstring;

  ///////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                       //
  ///////////////////////////////////////////////////////////////////////

  var path = new Array();     // path[0] = top;   path[1] = top.subInstances.dut; etc.
  var curpathnum = 1;
  var curmodule = "";

  // E.g. curpathstring() might return "top.dut.regfile"
  function curpathstring() {
    var rval = path[0].InstanceName;
    for (var i = -1; i >= curpathnum; i--) {
      rval = rval + "." + path[i].InstanceName;
    }
    return rval;
  }

  function UpModule() {
    if (IsTopModule()) {
      alert("No way up from here, we're at the top.  (So why is there an UP button!??)"); // TODO?
      return;
    }

    if (check_parmchanges() == "abort") { return; }

    if (DBG9) alert("ups we goes! leaving " + curpathstring() + " curpathnum = " + curpathnum);

    m = path[++curpathnum];
    ModuleNavigatorHistory.RecordHistory("up", m); DrawNewModule(m);
  }

  function DownModule(modname) {
      if (check_parmchanges() == "abort") { return; }

      if (DBG9) {
          alert("hello i am downmodule" +
                "\ni have been asked to find modname " + modname +
                "\nand guess what cgtop.BaseModuleName = " + cgtop.BaseModuleName);
      }

      //////////////////////////////////////////////////////////////////////////////
      //var m = cgtop; if (modname != "top") { m = GetSubmodule(modname); }

      // BUG/TODO oh this is horrible, horrible.
      // Will probably break if:
      //  - any module other than top has the name "top"
      //  - any module other than top has the same name as the top
      //    module (e.g. two modules in the hierarchy named (top_FMA))
      //
      // Latest FloatingPointGen breaks in updatedesign.pl
      // if don't have (modname == cgtop.BaseModuleName) test
      // because cgtop.BaseModuleName != "top"
      //
      // It breaks in opendesign.pl if don't have (modname == "top") test
      // because opendesign always tries to open toplevel module as "top"
      //
      var m;
      if      (modname == "top")                { m = cgtop; } // For opendesign.pl
      else if (modname == cgtop.BaseModuleName) { m = cgtop; } // E.g. "top_FMA"
      else                                      { m = GetSubmodule(modname); }
      //////////////////////////////////////////////////////////////////////////////

      if (DBG9) if (m != cgtop) alert("going down. leaving " + curpathstring());

      path[--curpathnum] = m;
      ModuleNavigatorHistory.RecordHistory("dn", m); DrawNewModule(m);
  }

  // GotoModule("top.DUT") => push into "cgtop" then "DUT"
  function GotoModule(path) {

    // Always start at the top!
    var skiptop = false;
    while (! IsTopModule()) { skiptop = true; UpModule(); }

    // split the string on dot boundaries like so: "top.DUT" => {"top", "DUT"}
    var path_array = path.split(".");    // E.g. "top.DUT" => {"top", "DUT"}
    if (skiptop) { path_array.shift(); } // "skiptop" means we're already at "top"
    for (var i in path_array) {
      var p = path_array[i];
      if (DBG9) {alert("GotoModule says: " + p);}
      DownModule(p);
    }
  }

  function IsTopModule() { return (curpathnum>=0); }

  function DrawNewModule(m) {
    curmodule = m;                          // Update curmodule.
    if (DBG9) alert("entering " + curpathstring());
    Draw.Screen(m);
  }

  //GetSubmodule("dut") looks for a submodule "dut" within the currently-open module
  function GetSubmodule(submodname) {
    if (typeof curmodule.SubInstances == undefined) { alert("ERROR oops no more submodules"); return; }

    if (0) alert("Looking for submod " + submodname);
    for (si in curmodule.SubInstances) {
      if (submodname == si) {
        if (0) alert("GetSubmodule found " + curmodule.SubInstances[si].InstanceName);
	return curmodule.SubInstances[si];
      }
    }
    alert("ERROR could not find submod " + submodname);
  }

    function check_parmchanges() {

        // Don't do it!!!  If there is an open hashlist popup.
        if (SublistMgmt.CurDepth() != 0) {
            alert("You appear to have unprocessed changes at this level;\n" +
                  "please 'Submit' or 'Cancel' changes before navigating away...")
            return "abort";
        }

        // No need to check for pending parm changes if already found one w/"onchange"
        // (and/or could get rid of "onchange" scripts as redundant/unnecessary)
        // (NO! still need them for <select>)
        if (! PENDING_PARMCHANGE) { 

            var LDBG = 0;
            var e = document.getElementById("parmbox"); // e is form element containing input boxes
            if (!e) { return; }                         // No form => no new changes from form

            // Step through all text thingies in parm form to see if something changed...
            for (var i=0; (e[i] && (! PENDING_PARMCHANGE)); i++) {

                // Only checking <input> (text) tags; <select> tags are handled by "onchange" scripts.
                if (e[i].type == "text") {
                    if (LDBG) { alert(i + " is a text thingy\nand its name is " + e[i].id); }
                    
                    if (e[i].defaultValue != e[i].value) {
                        if (LDBG) { alert("hey guess what this one changed"); }
                        PENDING_PARMCHANGE = true;
                    }
                }
                else { if (LDBG) { alert(i + " is not a text thingy"); } }
            }
        }
        if (! PENDING_PARMCHANGE) { return; }     // Move along, nothing to see here.

        // Get confirmation!!!  If there are outstanding changes to be processed.

        var msg = "Oops.  Looks like you may have changed a parameter and forgot to 'Submit'."
            + "  Do you still want to continue to the next page (changes will be lost)?"
        
        var answer = confirm(msg);
        if (answer == false) { return "abort"; } // User said "Cancel"!
        
        // User said "OK".  Better double check!
        var answer2 = confirm("Your pending changes will be lost!");
        if (! answer2) { return "abort"; }       // User changed his mind.
        
        // Could go ahead and submit changes speculatively, but no;
        // 1) takes a long time and 2) maybe user wants to dump changes.
        //Button_CancelSubmit.SubmitFunc();
    }
}
//--></script>
