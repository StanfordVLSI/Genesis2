<script type="text/javascript">
<!--

PopUp = new function () {

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.Appear = Appear;
  this.Disappear = Disappear;
  this.Visible = PopUpVisible;

  ///////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                       //
  ///////////////////////////////////////////////////////////////////////

  // SUBTODO no longer need popup "visible" marker---keep or dump it?
  // TODO/SUBTODO/BUG I'm pretty sure PopUpVisible is no longer used;
  // thus no longer need a bunch of stuff...?  Verify and implement
  var PopUpVisible = 0; // TRUE (1) if menu currently visible on-screen.

  function PopUpVisible() { return PopUpVisible; }

  function Appear(e, menu) {  // Makes popup menu appear on screen.

    var formbox = Browser.MouseTarget(e);
    var f = formbox;

    var bcr = f.getBoundingClientRect();     // Also see getClientRects, WebKit TODO
//  list_attributes(bcr);

    // Want popup TL at bcr.top+4, bvr.left+4

//    alert("bcr = " + f.getBoundingClientRect());
//    alert("osl = " + f.offsetLeft);
//    alert("ost = " + f.offsetTop);

//    list_attributes(formbox);

    // Position the menu near top-left corner of the current window.
    //SetMenuLocation(e, menu, 15, 15, "absolute");

    // Position the menu just a little ways SE of the mouse click.
    // This guarantees a "mouseout" event from current position
    // before entering the new menu.
    // SetMenuLocation(e, menu, 1, 1, "relative");
//    alert("left,top = " + (bcr.left+4) + "," + (bcr.top+4));
      
    SetMenuLocation(e, menu, bcr.left-10, bcr.top-4, "absolute");

    document.getElementById(menu).style.display = "";
    PopUpVisible = 1;
    return(false);
  }

  // Only called from one place: Button_CancelSubmit.CancelFunc()
  // Makes popup menu disappear from screen.
  function Disappear(menu) {

//    alert("Drizzle, drazzle, druzzle, drome." + 
//          "\nTime for zis vun to come home: " + menu);

    document.getElementById(menu).style.display = "none";
    PopUpVisible = 0;       // SUBTODO: fix odd relationship between PopUpVisible and curdepth
  }

  ////////////////////////////////////////////////////////////////////////
  // Set x and y position for ULH corner of the given menu according to
  // whether the browser is Firefox (ns6) or IE.  If pos = "relative"
  // set x and y relative to the current cursor position.  If "absolute"
  // set x and y relative to TL corner of the enclosing window.

  function SetMenuLocation(e, menu, x, y, pos) {

    if (pos == "absolute") { Browser.SetXY_absolute(menu, x, y   ); }
    else                   { Browser.SetXY_relative(menu, x, y, e); }
  }

  // Does this belong here or elsewhere?
  function ConditionalDefaultMenu(e) { 

    // Called from event "oncontextmenu"
    // Browsers often load the right mouse button with annoying default menus.
    // Thus we block it when our own menu is visible.

    if (PopUpVisible) { return false; }
    return true;
  }
}
//-->
</script>
