<script type="text/javascript"><!--

Button_CancelSubmit = new function() {

  // NOTE CancelSubmit buttons only appear for sublists (hash or array)

  this.Submit = Submit;
  this.Cancel = Cancel;

    this.SubmitFunc = SubmitFunc;

  // Pushing a Cancel or Submit button activates CancelFunc or SubmitFunc

  function Submit(id) { Button.Register(id, "white2gray", SubmitFunc); }
  function Cancel(id) { Button.Register(id, "white2gray", CancelFunc); }

  function SubmitFunc(e) {

      // NOTE CancelSubmit buttons only appear for sublists (hash or array)

      var path = SublistMgmt.PathName() + ".";      // E.g. "SPECIAL_DATA_MEM_OPS.13"
      if (DBG) { alert("path = " + path); }

      var form_id = "sublist" + SublistMgmt.CurDepth();      // E.g. "sublist4"
      var form = document.getElementById(form_id).elements;

      var modpath = ModuleNavigator.curpathstring();    // E.g. "top.DUT.p0"
//    alert("MODPATH = " + modpath);

      // Subsequent parms are the module parameters e.g. "ASSERTION=ON&MODE=VERIF&...TILE_ID=0"
      var parms = "";
      for (var i = 0; i < form.length; i++) {
	  var id = path + form[i].id;               // E.g. "SPECIAL_DATA_MEM_OPS.13.tiecode"
	  var value = form[i].value;                // E.g. "40"
	  parms += "&" + id + "=" + value;          // E.g. "&SPECIAL_DATA_MEM_OPS.13.tiecode=40"

	  // Change value associated w/parm so gui will remember when form is opened again later.
	  ChangeParameter(modpath, id, value);

      }
      if (DBG) { alert(parms); }
      SUBPARMS = SUBPARMS + parms; // BUG/TODO: really?  Using a global to pass subparms??

      CancelFunc(e); // This makes the submenu go away.
  }

  // This makes the popup submenu go away.
  function CancelFunc(e) {
    var i = SublistMgmt.PopDown();
    PopUp.Disappear("submenu" + i);
  }

  function ChangeParameter(modpath, parmname, value) {
      // Given a module pathname "modpath" e.g. "top.DUT.p0"
      // and a COMPLEX parameter name "parmname" e.g. "SPECIAL_DATA_MEM_OPS.5.tiecode"
      // and a new parm value "value" e.g. "4a", fix it such that
      // cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[5].tiecode = "4a"

      // NOTE CancelSubmit buttons only appear for sublists (hash or array)

      // Eg: Gonna set (top.DUT.drh0).(INITIAL_STATE_TRANSLATION_MAP.4.map_type) to "lut2"
      // Or: Gonna set (top).(TOP_HASH.0.colorname) to "white"
      if (DBG) { alert("Gonna set (" + modpath + ").(" + parmname + ") to \"" + value + "\""); }

      var mp_array = modpath.split("."); // E.g. "top.DUT.p0" => {"top","DUT","p0"}

      // Array length 1 means path is simply "top"; otherwise gotta chase down subinstances.
      var obj_ptr = cgtop;
      if (mp_array.length > 1) { // Gotta chase down subinstances.
          obj_ptr = cgtop["SubInstances"][mp_array[1]];  // E.g. cgtop["SubInstances"]["DUT"]
          for (var mpi = 2; mpi < mp_array.length; mpi++) {
	      obj_ptr = obj_ptr["SubInstances"][mp_array[mpi]];
          }
      }

      obj_ptr = obj_ptr["Parameters"]; 
      // Now obj_ptr = e.g. cgtop["SubInstances"]["DUT"]["SubInstances"]["p0"]["Parameters"]

      var id_array = parmname.split("."); // E.g. "SPECIAL.5.tiecode" => ("SPECIAL","5","tiecode")
      for (var idi = 0; idi < (id_array.length - 1); idi++) {
	  obj_ptr = obj_ptr[id_array[idi]];
      }

      // Now obj_ptr = e.g.
      // cgtop["SubInstances"]["DUT"]["SubInstances"]["p0"]["Parameters"]["SPECIAL"]["5"]

      //alert("Penultimate answer! " + obj_ptr[id_array[id_array.length-1]]);

      obj_ptr[id_array[id_array.length-1]] = value;
      // E.g. cgtop["SubInstances"]["DUT"]["SubInstances"]["p0"]["Parameters"]["SPECIAL"]["5"]["tiecode"] = "SYNC"

      //alert("Final answer! "       + obj_ptr[id_array[id_array.length-1]]);
  }

}

//--></script>
