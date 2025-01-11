<script type="text/javascript"><!--

Button_Submod = new function() {

  this.Activate = Activate;

  function Activate(id) {
    Button.Register(id, "white2gray", MouseDownOnSubmod);

    // Trap the context menu, so it doesn't block rightclick thingy.
    var e = document.getElementById(id);
    e.oncontextmenu = TrapContextMenu;    // Should this be (always) part of Button.Register()?
  }

  function MouseDownOnSubmod(e) {
    var b = Browser.WhichButton(e);
    if (b == "left" ) { PushIntoSubmod(e);       } // left button
    else              { ShowModuleProperties(e); } // right button

    return false;                                  // Nobody else gets to process this event.
  }

  function GetModName(e) {
    // Find and return name of module that the mouse clicked on.

    var selectedMod = Browser.MouseTarget(e).id;         // E.g. "submod15"
    var selModNum   = selectedMod.substr(6);             // E.g. "submod15" => "15"
    var selModName  = Submodules.SubmodName(selModNum);  // E.g. "DUT" or "icache"

    var DBG=0;
    if (DBG) alert("Button_Submod.GetModName: I am " + selectedMod + ".");
    if (DBG) alert("My uniq submod number is " + selModNum);
    if (DBG) alert("I am " + selModName);

    return selModName;
  }


  function PushIntoSubmod(e) {
    // Push into the submodule (left-)clicked on by mouse.

    var selModName = GetModName(e);
    ModuleNavigator.OpenSubmodule(selModName);
  }

  function ShowModuleProperties(e) {
    // In an alert box, show props associated with submodule (right-)clicked on by mouse.

//    alert("hey rightclick");  // TODO show module properties...

    var selModName = GetModName(e);
    var m          = ModuleNavigator.GetSubmodule(selModName);
    var props      = ModuleProperties.Get(m);

    alert(props);
  }

  function TrapContextMenu(e) { return false; } // Prevent context menu from appearing.
}

//--></script>
