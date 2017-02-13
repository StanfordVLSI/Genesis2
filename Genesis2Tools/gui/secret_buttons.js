var cookie_vars = new Array();
cookie_vars['COMMENTS'] = true;  // ON
cookie_vars['DEBUG'   ] = false; // OFF

function toggle_cookie(varname,abbrev) {
    cookie_vars[varname] = (!cookie_vars[varname]);      // Toggle.

    var state = cookie_vars[varname] ? "ON"    : "OFF";
    alert(varname + " now " + state); // E.g. "DEBUG now OFF"
    setCookie(varname, state, 7);     // Set varname to "ON" or "OFF" for max seven days.

    // ON = black, OFF = gray
    var color = cookie_vars[varname] ? "black" : "gray";
    document.getElementById("toggle_cookie_"+varname).style.color = color;

    // Kind of a hack, I guess...
    document.getElementById("choosedesign").href = "choosedesign.pl?DEBUG="+cookie_vars['DEBUG'];
    //alert("href="+document.getElementById("choosedesign").href);
}

function setCookie(name,value,exdays) {
  var exdate=new Date();
  exdate.setDate(exdate.getDate() + exdays);
  var expiry          = "expires=" + exdate.toUTCString();
  var path            = "path=/";
  var name_value_pair = name + "=" + escape(value);

  // This hack sets the cookie under multiple paths; shouldn't need this!!??  But I do :(

  var cookie0 = name_value_pair + "; " + expiry              ; //alert("cookie0 = " + cookie0);
  document.cookie = cookie0;

  var cookie1 = name_value_pair + "; " + expiry + "; " + path; //alert("cookie1 = " + cookie1);
  document.cookie = cookie1;
}

// Initialization
for (var i in cookie_vars) { setCookie(i,cookie_vars[i] ? "ON" : "OFF", 7); }
