<script type="text/javascript"><!--
ModuleNavigatorHistory = new function () {

  this.RecordHistory = RecordHistory; // Record an event for the history timeline.
  this.BackHistory   = BackHistory;   // Move backward along history timeline.
  this.ForeHistory   = ForeHistory;   // Move forward along history timeline.

  var RECORD_HISTORY = 1; // If set, means we should keep track of history;
                          // If unset, means we are reading history.
  var history = new Array();
  var histlevel = 0;
  var nhists   = 0;

  function RecordHistory(dir, module) {  // E.g. RecordHistory("dn", "dut") or ("up", "top")

    if (RECORD_HISTORY) {
      // "dn.dut" => moved DOWN to submodule "dut"; "up.top" => moved UP to parent module "top"
      history[histlevel++] = dir + "." + module.InstanceName;
      nhists = histlevel;
    }
    RECORD_HISTORY = 1;
    if (DBG) ShowHistory();
  }

  function ShowHistory() { // E.g. ShowHistory() prints "0. dn.top<br>1. dn.dut<br>"
    var str = "ModuleNavigatorHistory.ShowHistory():\n";
    for (var i = 0; i < nhists; i++) {
      if (i == (histlevel-1)) { str += "*"} // else { str += "_"; }
      str = str + i + " " + history[i] + "\n";
    }
    alert(str);
  }

  function BackHistory() {
    if (DBG) { alert("backs we goes"); alert("current hist level is " + histlevel); }

    if (histlevel <= 1) {
      alert("ERROR Can't go back no mo.\n(So why is there a BACK button?)\n"); return;
    }
    // E.g. action = "dn.dut" means we moved DOWN to submodule "dut"
    // action = "up.top" means we moved UP to parent module "top"
    var action    = history[--histlevel]; if (DBG) alert("unwinding action " + action);
    var direction = action.substr(0,2);   if (DBG) alert("direction was " + direction);

    if (direction == "dn") Move("up"); // Unwind => it's opposite day!
    if (direction == "up") Move("dn");
  }

  function ForeHistory() {
    if (DBG) { alert("fores we goes"); alert("current hist level is " + histlevel); }

    if (histlevel >= nhists) {
      alert("ERROR Can't go fore no mo.\n(So why is there a FORE button?)\n"); return;
    }
    var action    = history[histlevel++]; if (DBG) alert("replaying action " + action);
    var direction = action.substr(0,2);   if (DBG) alert("direction will be " + direction);

    Move(direction);
  }

  function Move(dir) {
    RECORD_HISTORY = 0; // Next action REPLAYS history, doesn't add to it.

    if (dir == "up") ModuleNavigator.UpModule();
    else {
      var targ = history[histlevel-1].substr(3);
      ModuleNavigator.DownModule(targ);
    }
  }
}

//--></script>
