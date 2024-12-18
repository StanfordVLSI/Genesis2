<script type="text/javascript"><!--

///////////////////////////////////////////////////////////////////
// System-dependent stuff (should move to 0-template eventually).

Misc = new function() {

  this.Download = Download;

  function Download() {

    /////////////////////////////////////////////////////////////////////////
    // CGI_URL                 = e.g. "/cgi-bin/genesis"
    // CURRENT_DESIGN_FILENAME = e.g. "../designs/tgt0/demo-110328-154450.js"
    // if (DBG) { alert("Current design = " + CURRENT_DESIGN_FILENAME); }

    /////////////////////////////////////////////////////////////////////////////////////
    // Call wrapper e.g. "/cgi-bin/ig/buildtarball.pl?curdesign=../designs/wallace&DBG=0"

    var parms = "curdesign=" + encodeURIComponent(CURRENT_DESIGN_FILENAME) + "&DBG=" + DBG;
    var update = CGI_URL + "/buildtarball.pl?" + parms;

    if (DBG) { alert("Misc.js: Bye-bye!  We're off to the land of " + update); }
    window.location = update;
  }
}

//--></script>

