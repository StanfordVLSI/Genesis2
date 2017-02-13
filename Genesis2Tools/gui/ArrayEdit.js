<script type="text/javascript"><!--

DBG=0;
DBG9=0;

ArrayEdit = new function() {

    this.edit = function(item, command) {  // command = "deleteme" or "cloneme"

        // E.g. if (item == "SPECIAL_DATA_MEM_OPS.0") and (curmodpath="top.DUT.p0") then
        //   SUBPARMS += "&SPECIAL_DATA_MEM_OPS.0=%.cloneme"
        //   arrayname = cgtop.SubInstances.DUT.SubInstances.p0.Parameters.["SPECIAL_DATA_MEM_OPS"]
        //   item_num = 0

        if (DBG) { alert("ArrayEdit.edit " + command + " item: " + item); }

        SUBPARMS += "&" + item + "=%." + command;     // E.g. "&SPECIAL_DATA_MEM_OPS.0=%.cloneme"
        var ai = find_arrayitem(item);
        if (command == "cloneme") {
            clone_array_item(ai.arrayname, ai.item_num);
        }
        else if (command == "deleteme") {
            delete_array_item(ai.arrayname, ai.item_num);
        }
        else {
            alert("ERROR ArrayEdit.edit() received unknown command\n");
        }
        SubparmBox.RebuildPopUp(); // Rebuild currently-open popup containing modified array.
    }
        
    function find_arrayitem(item) {

        // Given e.g. modpath = "top.DUT.p0", the following code turns e.g. "SPECIAL_DATA_MEM_OPS.0"
        // into 'cgtop.SubInstances.DUT.SubInstances.p0.Parameters.["SPECIAL_DATA_MEM_OPS"]["0"]'

        // "parmbox" name is module path e.g. "top.DUT.p0"
        var modpath = document.getElementById("parmbox").name;
        var subinstnames = modpath.split(".");  // E.g. ("top","DUT","p0")
        subinstnames.shift(); // Don't need first element "top" (cgtop)

        if (DBG9) { for (var i in subinstnames) { alert("s= " + subinstnames[i]); } }

        // Want e.g. "cgtop.SubInstances.DUT.SubInstances.p0"
        var arrayname = "cgtop";
        for (var i in subinstnames) {
            var s = subinstnames[i];
            arrayname += ".SubInstances."+s;  // E.g. 
        }
        // Now arrayname should be e.g. '"cgtop.SubInstances.DUT.SubInstances.p0"
        if (DBG9) { alert("okay now arrayname = " + arrayname); } 

        // Want e.g. 'cgtop.SubInstances.DUT.SubInstances.p0.Parameters.["SPECIAL_DATA_MEM_OPS"]["0"]'
        arrayname += ".Parameters";
        var item_parts = item.split("."); // E.g. ("SPECIAL_DATA_MEM_OPS", "0")

        var nparts = item_parts.length;

        var item_num = item_parts[nparts-1]; // E.g. "0"

        for (var i=0; i<(nparts-1); i++) {
            var ip = item_parts[i];
            arrayname += '["' + ip + '"]';
        }
        // Now arrayname =? 'cgtop.SubInstances.DUT.SubInstances.p0.Parameters.["SPECIAL_DATA_MEM_OPS"]["0"]'
        return {arrayname:arrayname,item_num:item_num};
    }

    function delete_array_item(arrayname, item_num) {

        // If arrayname = e.g. 'cgtop.SubInstances.p0.Parameters.["SPECIAL_DATA_MEM_OPS"]["0"]'
        // and item_num = 0, can access e.g. name field by e.g.
        // var name = eval('cgtop.SubInstances.p0.Parameters["SPECIAL_DATA_MEM_OPS"]["0"].name');

        if (DBG9) { debug_before_and_after("before:"); }

        // SHIFT!!  Delete item #item_num, and shift all successive array items back by one.

        var ip = item_num; ip++; ip--; // Establish ip as an integer (instead of a string)?

        // E.g. for i = ip to <end> do { arr[i] = arr[i++]; }
        while (! (eval(arrayname+"[" + (ip+1) + "]")==undefined)) {
            var js = arrayname + "[" + ip + "] = " + arrayname + "[" + (ip+1) + "];"
                ;
            //if (DBG) { alert(js); }
            eval(js);
            ip++;
        }
        
        // E.g. "delete cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[31]"
        var js = "delete " + arrayname + "[" + ip + "];"
            ;
        if (DBG) { alert(js); }
        eval(js);

        if (DBG9) { debug_before_and_after("after:"); }
    }

    function debug_before_and_after(which) { // which = "before:" or "after:"
        alert(which +
              "\narray element 0 = " + cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[0].name + 
              "\narray element 1 = " + cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[1].name
              );
    }

    // To use: var new = deepcopy(old); (should this be in utils?)
    function deepcopy(old_obj) {
        var new_obj = new_obj || {};
        for (var i in old_obj) {
            if (typeof(old_obj[i]) === 'object') {
                new_obj[i] = (old_obj[i].constructor === Array) ? [] : {};
                new_obj[i] = deepcopy(old_obj[i]);
            } else new_obj[i] = old_obj[i];}
        return new_obj;
    }

    // E.g. arrayname =
    // 'cgtop.SubInstances.DUT.SubInstances.drh0.Parameters["INITIAL_STATE_TRANSLATION_MAP"]'
    function clone_array_item(arrayname, item_num) {

        var last_item = item_num;
        while (! (eval(arrayname+"[" + last_item + "]")==undefined)) { last_item++; }

        // alert("\nlast_item = " + last_item + "\nitem_num  = " + item_num  );

        for (var ip = last_item; ip > item_num; ip--) {

            //var js = arrayname + "[" + ip + "] = " + arrayname + "[" + (ip-1) + "];";
            // E.g. arrayname[4] = arrayname[3]; // BAD!  Creates pointers if array of objects.


            var js = arrayname + "[" + ip + "] = deepcopy(" + arrayname + "[" + (ip-1) + "]);";
            // E.g. arrayname[4] = deepcopy(arrayname[3]);

            if (DBG) { alert(js); }
            eval(js);
        }
    }
}

//if (item_num == 4) {
//    alert(arrayname);
//
//    alert("so now top.DUT.drh0.INITIAL_STATE_TRANSLATION_MAP.3.map_type = " +
//          cgtop["SubInstances"]["DUT"]["SubInstances"]["drh0"]["Parameters"]
//          ["INITIAL_STATE_TRANSLATION_MAP"]["3"]["map_type"]
//          +
//          "\n\nand top.DUT.drh0.INITIAL_STATE_TRANSLATION_MAP.4.map_type = " +
//          cgtop["SubInstances"]["DUT"]["SubInstances"]["drh0"]["Parameters"]
//          ["INITIAL_STATE_TRANSLATION_MAP"]["4"]["map_type"]
//          );
//
//}

//--></script>
