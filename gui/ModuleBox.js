<script type="text/javascript"><!--

ModuleBox = new function () {

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.Draw       = DrawModuleBox;

  ////////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                        //
  ////////////////////////////////////////////////////////////////////////

  function DrawModuleBox(m) {

    var floatbox = ModuleProperties.Get(m);

    var mods_table =
      "<table class=module id=module title='" + floatbox + "'>\n" +

      WriteModTitle(m) +           // Draw title of module.
      Submodules.Draw(m) +         // Draw rows of submodules.
      "\n<\/table>";

    var DBG=0; if (DBG) alert(mods_table);

    return mods_table;
  }

  function WriteModTitle(m) {  // E.g. "Module 'top'" + UP button on same row.
    var indent   = "  ";
    var modtitle = "<td width=100% height=0% style='text-align:left'><b>" +
      ModuleNavigator.curpathstring() + "<\/b><\/td>";

    var modname =
      indent + "<tr><td height=27px style='vertical-align:top'>\n" +
      indent + "  <table><tr>\n" +
      indent + "    " + modtitle + "\n" +
      indent + "    <td class=button id=backbutton>&nbsp;&lt;&nbsp;<\/td>\n" + 
      indent + "    <td class=button id=forebutton>&nbsp;&gt;&nbsp;<\/td>\n" + 
      indent + "    <td class=button id=upbutton>&nbsp;UP&nbsp;<\/td>\n" + 
      indent + "  <\/tr><\/table>\n" +
      indent + "<\/td><\/tr>\n";

    return modname;
  }
}

//--></script>
