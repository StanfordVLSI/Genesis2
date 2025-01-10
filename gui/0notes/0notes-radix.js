//build a function cycle_radix(string) that does this:
//
//  1. detext whether string is dec, hex or binary
//  2. convert to next in sequence dec=>hex=>binary


<html><body>

<input id=imp value='0x1fF' />
<button onclick="myFunction2()">Try it</button>

<script type="text/javascript">

function cycle_radix(n) { //var DBG9=0;
  function ldbg(s) { if (DBG9) { alert(s); } }

    var isdec = n.match(/^[0-9]+$/);
    var isbin = n.match(/^0b[10]+$/);
    var ishex = n.match(/^0x[0-9a-fA-F]+$/);

    if      (isbin) { ldbg(n + " isbin"); }
    else if (ishex) { ldbg(n + " ishex"); }
    else if (isdec) { ldbg(n + " isdec"); }
    else            { alert("not a number"); }

    if (isbin) { // alert("bin => hex");
      alert("No current support for binary!");
    }
    else if (ishex) { ldbg("hex => dec");
      var n = n.replace(/^../,""); // E.g. "0x1fF" => "1fF" (regexp)
        ldbg(n);

        n = parseInt(n, 16); // E.g. "1fF" => "511"
        ldbg(n);

        return n;
    }
    else if (isdec) { ldbg("dec => hex");
        n = parseInt(n);   // must be a string, right?
        n = n.toString(16); // E.g. "511" => "1ff"
        ldbg(n);
        return "0x" + n;
    }
    else { return n; }
}

function myFunction2() {
var n = document.getElementById("imp").value;
//cycle_radix(n);
document.getElementById("imp").value = cycle_radix(n);
}


</script>

</body>
</html>
