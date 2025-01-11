<script type="text/javascript"><!--

Button_Debug = new function() {

  this.Init = Init;

  var turnon =  "Debug is OFF.  Click here to turn on debugging.";
  var turnoff =  "Debug is ON.  Click here to turn off debugging.";

  function Init() {
    document.getElementById("dbgbutton" ).value = DBG? turnoff : turnon;
    document.getElementById("dbgbutton" ).onclick = ToggleDebug;
  }

  function ToggleDebug(e) {
    if (DBG==0) {
      DBG = 1; document.getElementById("dbgbutton" ).value = turnoff;
    }
    else if (DBG==1) {
      DBG = 0; document.getElementById("dbgbutton" ).value = turnon;
    }
  }
}

//--></script>
