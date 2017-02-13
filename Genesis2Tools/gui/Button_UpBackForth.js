<script type="text/javascript"><!--

Button_UpBackForth = new function() {

  this.Activate = Activate;

  function Activate(id) {
    if (DBG) alert("Button_UpBackForth.Activate: id is " + id);

    if (id == "upbutton")
      Button.Register(id, "white2gray", PopOutOfSubmod);

    else if (id == "backbutton")
      Button.Register(id, "white2gray", BackHist);

    else if (id == "forebutton")
      Button.Register(id, "white2gray", ForeHist);
  }

  function PopOutOfSubmod(e) { ModuleNavigator.UpModule();           }
  function BackHist      (e) { ModuleNavigatorHistory.BackHistory(); }
  function ForeHist      (e) { ModuleNavigatorHistory.ForeHistory(); }
}

//Button_Back = new function() {
//
//  this.Activate = Activate;
//
//  function Activate(id) {
//
//    var DBG=1;
//    if (DBG) alert("Button_Back.Activate: id is " + id);
//
//    Button.Register(id, "white2gray", BackHist);
//  }
//  function BackHist(e) {
//    ModuleNavigator.BackHistory();
//  }
//}
//
//Button_Fore = new function() {
//
//  this.Activate = Activate;
//
//  function Activate(id) {
//
//    var DBG=1;
//    if (DBG) alert("Button_Fore.Activate: id is " + id);
//
//    Button.Register(id, "white2gray", ForeHist);
//  }
//  function ForeHist(e) {
//    ModuleNavigator.ForeHistory();
//  }
//}

//--></script>
