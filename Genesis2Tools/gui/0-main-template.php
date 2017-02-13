<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!-- This breaks, with the loose.dtd (below); why? -->
<!-- DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> -->

<HEAD>
  <TITLE>Interactive Genesis</TITLE>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
  <link rel="shortcut icon" href="http://www-vlsi.stanford.edu/genesis/favicon.ico">

<script type="text/javascript"><!--

  var DBG=0;
  var CURRENT_DESIGN_FILENAME = "CURRENT_DESIGN_FILENAME_HERE";
  if (DBG) { alert("Current design = " + CURRENT_DESIGN_FILENAME); }

  var NEW_DESIGN_BASENAME = "NEW_DESIGN_BASENAME_HERE";
  if (DBG) { alert("New design = " + NEW_DESIGN_BASENAME); }

  var CURRENT_BOOKMARK = "CURRENT_BOOKMARK_HERE";
  if (DBG) { alert("Current place = " + CURRENT_BOOKMARK); }

  var CGI_URL = "CGI_URL_HERE";                       // E.g. "/cgi-bin/genesis"
  if (DBG) { alert("URL for cgi dir = " + CGI_URL); }

  var HOME_URL = "HOME_URL_HERE";                      // E.g. "/genesis"
  if (DBG) { alert("URL for gui = " + HOME_URL); }

//--></script>

  <!-- ==================- STYLE FILES ========================================= -->
  <?php include "style.htm";          ?><!-- Style info                          -->

  <!-- ==================- GLOBAL JAVASCRIPT VARS AND FUNCS ======================= -->
  <!-- php include "designs/design-sample.js"; ?--><!-- Chip config data structures -->
  <?php include "CURDESIGN_HERE";              ?>  <!-- Chip config data structures -->

  <!-- ==================- JAVASCRIPT FUNCTIONS =================================== -->
  <?php include "init.js";            ?><!-- Open a view into the top-level module  -->
  <?php include "Browser.js";         ?><!-- Browser-specific utilities             -->
  <?php include "Button_Debug.js";    ?><!-- Debug button                           -->

  <!-- ?php include "Button_UGTX.js"; --><!-- "Use-and-Generate-Tiny-XML" button     -->

  <?php include "PopUp.js";           ?><!-- Popup menu for subparm lists           -->
  <?php include "Misc.js";            ?><!-- Download button (et al.?)              -->

  <?php include "ModuleNavigator.js"; ?><!-- Utilities for navigating among modules -->
  <?php include "ModuleNavigatorHistory.js"; ?><!-- "Back" and "Forth"              -->

  <?php include "Draw.js";            ?><!-- Draw a module, submod, parm boxes      -->

  <?php include "ModuleBox.js";       ?><!-- Support for drawing modbox and submods -->
  <?php include "ModuleBox_ArrayDimensions.js";
                                      ?><!-- Turn a linear array into a box.        -->

  <?php include "ModuleProperties.js"; ?><!-- Support for drawing modprops boxes    -->
  <?php include "Submodules.js";       ?><!-- Support for drawing submods etc.      -->


  <?php include "ParmBox.js";         ?><!-- Support for drawing parm box + forms   -->
  <?php include "ParmBoxForm.js";     ?><!-- Draw form for choosing parameter values-->
  <?php include "ArrayEdit.js";       ?><!-- Edit array contents                    -->

  <?php include "SubparmBox.js";      ?><!-- Expand subparameter lists...           -->
  <?php include "Sublists.js";        ?><!-- Expand subparameter lists...           -->
  <?php include "SublistMgmt.js";     ?><!-- Expand subparameter lists...           -->



  <!-- ==================- JAVASCRIPT FUNCTIONS: BUTTONS=========================== -->
  <?php include "Button.js";               ?><!-- Make a button of indicated color  -->
  <?php include "Button_Submod.js";        ?><!-- Push into a submodule             -->
  <?php include "Button_UpBackForth.js";   ?><!-- Pop up to higher level module etc.-->
  <?php include "Button_SubparmList.js";   ?><!-- To expand a subparm list          -->
  <?php include "Button_SubmitChanges.js"; ?><!-- To activate user-specified changes-->
  <?php include "Button_CancelSubmit.js";  ?><!-- To dispatch subparm submenu       -->

</HEAD>

<BODY onload="init()">
  <!--==========================================================================-->
  <div id=mainbody></div>   <!-- Placeholder for javascript-generated html -->

  <!--==========================================================================-->
  <!-- DON'T DELETE THESE!  YOU IDIOT! =========================================-->
  <div id='subparms1'></div>     <!-- Placeholder for sublist popup menu =======-->
  <div id='subparms2'></div>     <!-- Placeholder for sublist popup menu =======-->
  <div id='subparms3'></div>     <!-- Placeholder for sublist popup menu =======-->
  <div id='subparms4'></div>     <!-- Placeholder for sublist popup menu =======-->
  <div id='subparms5'></div>     <!-- Placeholder for sublist popup menu =======-->
  <div id='subparms6'></div>     <!-- Placeholder for sublist popup menu =======-->
  <div id='subparms7'></div>     <!-- Placeholder for sublist popup menu =======-->
  <div id='subparms8'></div>     <!-- Placeholder for sublist popup menu =======-->
  <div id='subparms9'></div>     <!-- Placeholder for sublist popup menu =======-->

<!-- Placeholder for CLI copy 'n' paste -->
<div id="copynpaste" style="display:none">
  <table style="float:right; border:1px solid black; border-collapse:collapse; background-color:red">
    <tr>
      <td style="text-align:center">
        <button type="button" onclick="document.getElementById('copynpastebox').select()">
          Select and copy the command below; then paste to linux command line.
        </button>
      </td>
    </tr>
    <tr>
      <td>
        <textarea rows="2" cols="80" readonly="readonly" id="copynpastebox">
           to be filled in by "toggle_section()"
        </textarea>
      </td>
    </tr>
  </table>
  <!-- "clear" keeps the text (newlines) from floating next to table above -->
  <div style="clear:both"><br><br></div>
</div>

<!-- OPTIONAL GUI_EXTRAS.PHP GOES HERE -->

<!-- Download tar file =========================================================-->
<table class=top_stack_button><tr><td>
  <input
    type="button" id="downloadbutton" onclick="Misc.Download()"
    value='Click here to download current design (.v, .xml, .tar files etc.) (must first "Submit changes")'
  >
</td></tr></table>
<!--=============================================================================-->

<!-- optional CMP demo instructions        -->
<!-- cmpdemo --><?php include "cmpdemo.php" ?>

  <!-- this is an awful way to pass information...!? -->
  <div id="CVL" style="display:none">CURVIEW_LINK_HERE</div>
  <?php include "download.php" ?><!-- Download and embed options -->

  <div id=debugging></div>  <!-- Placeholder for debug information -->

<table class=mid_stack_button><tr><td>
  <input type="button" id="dbgbutton">
</td></tr></table>

<table
  style="border:1px solid black;border-top:hidden;background-color:#e7d19a"
><tr><td>
<input style="text-align:left"
  type="button"
  id="help_button"
  onclick="toggle_section('help_button','help','help')"
  value="+ Help"
>

<div id="help" style="display:none; font-size:small">
  <b>How to use:</b>
  <ul>
    <li>Use "UP," back ("&lt;") and forward ("&gt;") buttons to
        navigate the design and change its parameters.
    <li>Left-click a submodule to push down into it; use UP to pop back to the parent module.
    <li>iPhone / iPad users: double-tap module to make it fill the screen.
    <li>Right-click or float over a module to see its properties and submodules.
  </ul>
</div>
</td></tr></table>

  <p>Current design base is <b>CURRENT_DESIGN_FILENAME_HERE</b>
  <br>Design name going forward is <b>NEW_DESIGN_BASENAME_HERE</b>

  <p>
  Report a bug/suggestion/feedback via
  <a href="http://aegir.stanford.edu/bugzilla/enter_bug.cgi?product=ChipGenerator">bugzilla</a>
  or 
  <a href="mailto:chipgenerator@gmail.com?subject=GUI_feedback_or_bug">           e-mail.  </a>

  <p><a href="https://www-vlsi.stanford.edu/mediawiki/index.php/CG/GUI_To-Do_List">To-do list.</a></p>

  <!-- HTML compliance -->
  <a href="http://validator.w3.org/check?uri=referer">
    <img src="http://www.w3.org/Icons/valid-html401" alt="Valid HTML 4.01 Transitional">
    <!-- width=44 -->
    <!-- height="31" width="88" -->
  </a>

</BODY>
