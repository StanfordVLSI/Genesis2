<script type="text/javascript"><!--

Sublists = new function () {

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.GetNextSublistno = GetNextSublistno;
  this.HowManySublists  = HowManySublists;
  this.SublistName      = SublistName;

  this.ClearSublists   = ClearSublists;
  this.SubparmForm     = SubparmForm;
  this.SubparmForm2    = SubparmForm2;
  this.Truncate        = Truncate;
  this.RegisterSublist = RegisterSublist;

  ////////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                        //
  ////////////////////////////////////////////////////////////////////////
    
  var sublistno = 0;             function GetNextSublistno() { return sublistno; }

  var sublist = new Array();     function HowManySublists() { return sublist.length; }
  var mutable = new Array();
  var sublistname = new Array(); function SublistName(i) { return sublistname[i]; }

  function ClearSublists() {
    sublistno = 0;
    sublist = []; mutable = []; sublistname = [];
    SublistMgmt.Clear(); // was Clear(); 
  }

  function SubparmForm2(i) {
      var rval2 = ParmBoxForm.Build2(sublistname[i], sublist[i], mutable[i]);
      return rval2;
  }

  function SubparmForm(i) {
      //alert("Building " + mutable[i] + " subparmbox number " + i);
      return ParmBoxForm.Build("sublist", sublist[i], mutable[i]);
  }

  function Truncate(max) {
    // Cut sublists array back to index "max"

    var dbgmsg = "Truncate(): sublistno is currently " + sublistno;
    var dbgmsg = "Truncate():";
    while (sublistno > max) {
      sublistno--; sublist.pop();
      if (DBG) dbgmsg += "\npop and decrement sublist; now sublistno = " + sublistno;
    }
    if (DBG) alert(dbgmsg);
  }

  function RegisterSublist(name, list, m) {

    // Remember array "list" as a sublist and assign it a unique number "i";
    // Also remember its name and whether or not it's read-only (immutable)

    // E.g. 'registering "5" as mutable sublist number 19'
    if (DBG) { alert("registering \"" + name + "\" as " + m + " sublist number " + sublistno); }

    //if (name == "3" || name == "4") {
    //    var msg = ""; var pname;
    //    for (pname in list) { msg = msg + "\n  " + pname + " = " + list[pname]; }
    //    alert("list \"" + name + "\" looks like this:\n" + msg);
    //}

    var i = sublistno++;

    sublist[i]     = list; // E.g. {"LD",ST","ADD","SUB"}
    sublistname[i] = name; // E.g. "INST_OP_LIST"
    mutable[i]     = m;    // "mutable" or "immutable"

    return i;
  }
}

//--></script>
