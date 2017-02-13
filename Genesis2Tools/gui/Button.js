<script type="text/javascript"><!--

Button = new function() {

//  this.White2Gray = White2GrayButton;
//  this.White2Gray = White2Gray;
  this.Register = Register;

//  function White2GrayButton(id, func) {
  function Register(id, colors, func) {
    var e = document.getElementById(id);
    if (colors == "white2gray") {
      e.onmouseover = TurnGray;   // fgcolor
      e.onmouseout  = TurnWhite;  // bgcolor
    }                             // else ERROR?
    e.onmousedown = func;
  }

//  function White2Gray(e) {
//    e.onmouseover = TurnGray;
//    e.onmouseout  = TurnWhite;
//  }

  // Note: "Gray" is lighter than "LightGray."
  function TurnGray(e)      { ChangeColor(e, "#efefef"   ); } // Box turns gray.
  function TurnWhite(e)     { ChangeColor(e, "#ffffff"   ); } // Box turns white.
  function TurnLightGray(e) { ChangeColor(e, "lightgray"); } // Box turns light gray.
  function TurnPink(e)      { ChangeColor(e, "#ffdddd"   ); } // Box turns pink.

  function ChangeColor(e, color) {
    Browser.MouseTarget(e).style.backgroundColor = color;
  }
}

//--></script>
