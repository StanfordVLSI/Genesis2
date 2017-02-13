<script type="text/javascript"><!--

var DBG9 = 0;

Button_SubparmList = new function() {

  this.Activate    = Activate;
  this.ActivateAll = ActivateAll;

  function Activate(id) {
    Button.Register(id, "white2gray", MouseDownOnSubparmList);
  }

  function MouseDownOnSubparmList(e) {

    var selectedList = Browser.MouseTarget(e).id;      // E.g. "subparmlist15"
    if (DBG) alert("Entering Button_SubparmList.MouseDownOnSubparmList for " + selectedList);

    var selListNum = selectedList.substr(11);          // E.g. "subparmlist15" => "15"
    if (DBG9) alert("My unique list number is " + selListNum);

    // Need to know depth of target sublist (i.e. sublist = depth 1, subsublist = depth 2 etc.)
    // If target depth != current depth, refuse to go further

    if (! SublistMgmt.ButtonInCorrectScope(selListNum)) {
      alert("NO! first close existing popup."); return true;  // Complain and exit to caller.
    }

    // Build a popup with e.g. "<div id='submenu15' ...>" (if selListNum==15)
    var smbox = SubparmBox.BuildPopUp(selListNum);

    show_popup(smbox, selListNum);
    ActivateAll("subparm" + selListNum);          // Activate buttons in sublist pop-up

    PopUp.Appear(e, "submenu" + selListNum);      // E.g. "submenu15"
  }

  // Only called from Build() function, above.
  function show_popup(smbox, selListNum) {
    // build submenu "menu" e.g. <div id="submenu13" ...
    // (then:  PopUp.Appear(e, "submenu13");)

    var smid    = "submenu" + selListNum;                   // E.g. "submenu15"
    var smstyle = "' style='position:absolute; display:none; top:0px; left:0px; z-index:10000;'";
    var menu = "<div class=popup id='" + smid + smstyle + ">\n" + smbox + "<\/div>";
    if (DBG) alert(menu);

    // Attach the new popup to the main document (see 0-main-template.php)
    // by way of existing placeholders "subparms1" through "subparms9"

    // Support for subsubmenus, subsubsubmenus etc.
    var d = SublistMgmt.CurDepth(); //alert("current depth is " + d);

    // SUBTODO/BUG is this too much of a hack?
    if (d > 9) { alert("OOPS ERROR can only have parms nested at most nine deep"); }
    if (d < 1) { alert("OOPS ERROR how did we get depth less than 1!?"); }
    document.getElementById("subparms" + d).innerHTML = menu;
  }


  function ActivateAll(window) {

    // Called when we draw a new box that (potentially) has "click to expand"
    // sublist buttons i.e. called at each screen-redraw (window=="main")
    // level change and whenever a new submenu pops up (window=="popup")

    // window=="main" means begin processing w/sublist 0.
    // window=="subparm<i>" means begin processing w/sublist at current depth.

    // alert("powering on...found " + sublist.length + " subparm lists");


    // If window is a sublist, activate its Submit and Cancel buttons.

    if (window != "main") {
        var subparm = window;                           // E.g. "subparm15"

        Button_CancelSubmit.Submit("submit" + subparm); // E.g. "submitsubparm15"
        Button_CancelSubmit.Cancel("cancel" + subparm); // E.g. "cancelsubparm15"
    }




    var dbgmsg = "";
    var begin = (window == "main") ? 0 : SublistMgmt.FirstSublist();

    for (var i = begin; i < Sublists.HowManySublists(); i++) {

      if (DBG) dbgmsg += "activate subparmlist #" + i + "\n";
      Activate("subparmlist" + i);
    }
    if (DBG) if (dbgmsg) alert(dbgmsg);

    Button_SubmitChanges.Activate("changebutton");
  }
}
//--></script>
