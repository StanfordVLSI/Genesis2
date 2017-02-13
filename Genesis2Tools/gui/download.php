<script type="text/javascript"><!--
 var isvisible = new Array;
  function toggle_section(button, section, label) {
    //alert("pressed db");

    // BUG/TODO this is an awful hack!
    curview_link = document.getElementById("CVL").innerHTML; // awful awful awful
    document.getElementById("ELINK").innerHTML  = curview_link;

    if (isvisible[button]) {
      // Hide indicated section, change button to "show"
      document.getElementById(section).style.display = "none";
      document.getElementById(button).value= "+ Show " + label;
    } else {
      // Show indicated section, change button to "hide"
      document.getElementById(section).style.display = "block"; // "Block" unblocks...!?
      document.getElementById(button).value= "+ Hide " + label;
    }
    isvisible[button] = ! isvisible[button];
  }
//--></script>

<table class=mid_stack_button><tr><td>

<input style="width:300px;text-align:left"
  type="button"
  id="download_button"
  onclick="toggle_section('download_button','download_and_embed_options','download and embed options')"
  value="+ Show download and embed options"
>
<br>

<div id="download_and_embed_options" style="display:none">

  <table>
  <tr><td style="width:40px"></td><td>
  <button type="button" onclick="document.getElementById('ELINK').select()">
    Embeddable link for current design view
  </button>
  <br>
  </td></tr>

  <tr><td></td><td>
  <textarea rows="2" cols="80" readonly="readonly" id="ELINK">
     to be filled in by "toggle_section()"
  </textarea>
  <br><br>
  </td></tr>

  <tr><td></td><td>
  <button type="button" 
    onclick='
    var h=document.getElementById("layout").offsetHeight;
    var s="<iframe width=100% height="+h+" scrolling=yes src="
          + document.getElementById("CVL").innerHTML + ">";
    document.getElementById("IFRAME").innerHTML = s;
    document.getElementById("IFRAME").select()
  '
  >
    Embeddable iframe for current design view (click to generate in box below)
  </button>
  <br>
  </td></tr>

  <tr><td></td><td>
  <textarea rows="2" cols="80" readonly="readonly" id="IFRAME"></textarea>
  </td></tr>
  </table>

</div>
</td></tr></table>
