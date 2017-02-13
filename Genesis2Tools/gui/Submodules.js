<script type="text/javascript"><!--

Submodules = new function () {

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.Draw            = Draw;

  this.GetSubInstances = GetSubInstances;
  this.SubmodName      = SubmodName;    // Used by Button_Submod.GetModName(e)
  this.PowerOn         = PowerOn;

  ////////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                        //
  ////////////////////////////////////////////////////////////////////////

  var modname = new Array();
  var HowManySubInstances;

  // Return the name of the i-th submodule.
  function SubmodName(i) { return modname[i]; }

  function Draw(m) {                    // i.e. "DrawSubmodules," get it?

    //ModuleBox_ArrayDimensions.TestRC();

    var SubInstances = new Array();
    GetSubInstances(m, SubInstances);
    HowManySubInstances = SubInstances.length;

    var nsubmods = HowManySubInstances;

    if(DBG) alert("Found a total of " + nsubmods + " sub-instances");

    //return "Want two rows of two submods each.";
    var nrows = ModuleBox_ArrayDimensions.HowManyRows(nsubmods);
    var ncols = ModuleBox_ArrayDimensions.HowManyColumns(nsubmods);

    var submodno = 0;
    var rval = "<tr><td style='vertical-align:top'><table width=100%>";

    for (var r=1; r<=nrows; r++) {
      rval = rval + "<tr align=center>\n";

      for (var c=1; c<=ncols; c++) {
	var submod_name = SubInstances[submodno];

	if (submodno >= nsubmods) {
	  rval = rval + "  <td class=nosubmod><\/td>\n";
	} else {

	  var submod = ModuleNavigator.GetSubmodule(submod_name);
	  var props = ModuleProperties.Get(submod);

          /* Put a little breakable thin-space after every underbar */
          /* using (keyword) regexp regular expression */
          var name4display = submod_name.replace(/_/g, "_&thinsp;"); 

	  rval += "  <td class=submod title='" + props
	       +  "' id=submod" + submodno + ">" + name4display + "<\/td>\n";
	  modname[submodno] = submod_name;
	  submodno++;
	}
      }
      rval = rval + "<\/tr>";
    }
    return rval + "<\/table><\/td><\/tr>";;
  }

  function GetSubInstances(m, arr) {

    //alert("I am " + m.InstanceName + " and my sub-instances are:");
    for (att in m.SubInstances) {
      //alert(m.SubInstances[att].InstanceName);
      arr.push(m.SubInstances[att].InstanceName);
    }
  }

  function PowerOn(m) {

    if (DBG) alert("ModuleBox.PowerOn");

    // Activate active elements: submodules and "up" button"

    for (var i = 0; i < HowManySubInstances; i++) {
      Button_Submod.Activate("submod" + i);
    }

    Button_UpBackForth.Activate("upbutton");
    Button_UpBackForth.Activate("backbutton");
    Button_UpBackForth.Activate("forebutton");
  }
}

//--></script>
