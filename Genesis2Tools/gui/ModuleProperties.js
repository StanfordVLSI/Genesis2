<script type="text/javascript"><!--

ModuleProperties = new function () {

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.Get = Get;

  ////////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                        //
  ////////////////////////////////////////////////////////////////////////

  function Get(m) {                            // i.e. GetModuleProperties

    // Find properties associated w/module m; return a readable string.

    var props = "BaseModuleName:\""    + m.BaseModuleName   + "\";\n";
    props +=    " InstanceName:\""     + m.InstanceName     + "\";\n";
    props +=    " UniqueModuleName:\"" + m.UniqueModuleName + "\";\n";

    if (m.CloneOf != undefined) {
      props += " CloneOf:\""           + m.CloneOf.InstancePath + "\";\n";
    }

    if (m.SubInstances == undefined) {
      props += " No SubInstances";
    }
    else {
      var SubInstances = new Array();             // Is this the best way to do this???
      Submodules.GetSubInstances(m, SubInstances);

      props += " SubInstances:" + SubInstances[0];

      for (var i = 1; i < SubInstances.length; i++) {
	props += "," + SubInstances[i];
      }
    }
    return props;
  }
}

//--></script>


