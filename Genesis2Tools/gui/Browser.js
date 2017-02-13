<script type="text/javascript"><!--

var BROWSER;

Browser = new function() {

  this.Set         = SetBrowser;  // Sets BROWSER to "ie" or "ns6" etc.
  this.MouseTarget = MouseTarget; // Returns pointer to object clicked by mouse.
  this.WhichButton = WhichButton; // Returns "right" or "left" after button click.

  this.SetXY_absolute = SetXY_absolute;
  this.SetXY_relative = SetXY_relative;

  function SetBrowser() {
    var ie  = document.all; // TRUE if browser == Internet Explorer
    var ns6 = document.getElementById&&!document.all; // TRUE if Mozilla

         if (ie)  { BROWSER = "ie"; }
    else if (ns6) { BROWSER = "ns6"; }
  }

  function MouseTarget(e) {

    var ie  = (BROWSER=="ie"); var ns6 = (BROWSER=="ns6");

    if (ns6) { return e.target;                }
    else     { return window.event.srcElement; }
  }

  function WhichButton(e) {
    var ie  = (BROWSER=="ie"); var ns6 = (BROWSER=="ns6");

  //if (navigator.appName == 'Microsoft Internet Explorer'
  //if (navigator.appName == 'Netscape'
    if (ns6) {
      if (e.which == 3)         { return "right"; }    // (Netscape)
    }
    else if (event.button == 2) { return "right"; }    // (IE)
    return "left";
  }

////////////////////////////////////////////////////////////////////////
// Set x and y position for ULH corner of the given object "id"
// according to whether the browser is Firefox (ns6) or IE.
// If pos = "relative," set x and y relative to the current cursor
// position as given by mouseclick "e".  If "absolute,"
// set x and y relative to TL corner of enclosing window.

  function SetXY_absolute(id, x, y) {
    var s = document.getElementById(id).style;
    if (BROWSER == "ns6") {
      s.left      = x + document.body.scrollLeft;
      s.top       = y + document.body.scrollTop;
    } else {
      s.pixelLeft = x + document.body.scrollLeft;
      s.pixelTop  = y + document.body.scrollTop;
    }
  }

  function SetXY_relative(id, x, y, e) {
    var s = document.getElementById(id).style;
    if (BROWSER == "ns6") {
      s.left      = x + document.body.scrollLeft + e.clientX;
      s.top       = y + document.body.scrollTop  + e.clientY;
    } else {
      s.pixelLeft = x + document.body.scrollLeft + event.clientX;
      s.pixelTop  = y + document.body.scrollTop +  event.clientY;
    }
  }
}

//--></script>
