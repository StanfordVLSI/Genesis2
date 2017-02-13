<script type="text/javascript"><!--

// Secret buttons.
var NEW_ARR_EDIT_MODE = 1; // a: Better way of editing arrays of parms.
var SHOWCOMMENTS      = 1; // c: Show comments or no.
var DBG               = 0; // d: Turn printf's (alerts) on or off.

var COMMENTRULE; // COMMENTRULE points to the style rule for ".parmlist_parmcomm"

var PENDING_PARMCHANGE = false;

var obj = new Object();
obj.foo = "foo";

var SUBPARMS = ""; // BUG/TODO it'll do 'til something better comes along.

function init() {

  function getCookie(c_name) {
    var i,nam,val,cookie_parts=document.cookie.split(";");
    for (i=0;i<cookie_parts.length;i++) {
        nam = cookie_parts[i].substr(0,cookie_parts[i].indexOf("=")); // E.g. name=="DEBUG"?
        val = cookie_parts[i].substr(cookie_parts[i].indexOf("=")+1);
        nam = nam.replace(/^\s+|\s+$/g,""); // regexp regular expression
        if (nam==c_name) { return unescape(val); }
    }
  }
  NEW_ARR_EDIT_MODE = (getCookie("NEW_ARR_EDIT_MODE") == "OFF")? 0 : 1; // a default ON
  SHOWCOMMENTS      = (getCookie("COMMENTS")          == "OFF")? 0 : 1; // c default ON
  DBG               = (getCookie("DEBUG")             == "ON")?  1 : 0; // d default OFF

  if (DBG) {
      alert("\nNEW_ARR_EDIT_MODE= " + getCookie("NEW_ARR_EDIT_MODE") + " (" + NEW_ARR_EDIT_MODE + ")" +
            "\nCOMMENTS= "          + getCookie("COMMENTS")          + " (" + SHOWCOMMENTS      + ")" +
            "\nDEBUG= "             + getCookie("DEBUG")             + " (" + DBG               + ")" );
  }

  var rules = document.styleSheets[0].cssRules?
  document.styleSheets[0].cssRules :
  document.styleSheets[0].rules;
  for (var i = 0; i < rules.length; i++) {
      var st = rules[i].selectorText;
      if (0) alert(st);
      if (st == ".parmlist_parmcomm") { COMMENTRULE = rules[i]; break; }
      // COMMENTRULE points to the style rule for ".parmlist_parmcomm"
  }

  Browser.Set(); // BROWSER = "ie" or "ns6"

    Button_Debug.Init();

  //  var ans = prompt("Debug info (y or n)?", "no");
  //
  //  if (ans == undefined) { DBG = 0; }
  //  else {
  //    if (ans.substr(0,1).toLowerCase() == "n") { DBG = 0; }
  //    if (ans.substr(0,1).toLowerCase() == "y") { DBG = 1; }
  //  }

  //ModuleNavigator.OpenTopModule("top");
  //ModuleNavigator.GotoModule("top.DUT");
  ModuleNavigator.GotoModule(CURRENT_BOOKMARK); // e.g. "top.DUT"

//  build_module("top");

//  ModuleNavigator.RestorePath();  
//  build_module("top.dut");
//  ModuleNavigator.RestorePath();  

//  ModuleNavigator.OpenSubmodule("dut");
//  ModuleNavigator.OpenSubmodule("template");

//  alert(" firstname is " + document.getElementById("firstname").value);
}

//function debug(s) {
//  if (DBG) { alert(s); }
//}

function list_attributes(o) { // List an object's attributes.
  var list = "";
  for (att in o) {

    if (DBG) { alert("att parm " + att + " = " + o[att]); }
    //list = list + "att parm " + att + " = " + o[att] + "\n\n";
    //document.writeln("att parm " + att + " = " + o[att]);
    //document.writeln("");
    //document.writeln("");
    //alert("att parm " + att + " is type " + typeof(o[att]));
  }

//  document.write(list);
//  alert (list) ;

}

//--></script>
