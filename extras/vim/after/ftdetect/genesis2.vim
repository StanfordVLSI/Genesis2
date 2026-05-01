" Use `set filetype=` (force) and run from after/ftdetect so we win against
" plugins like verilog_systemverilog whose ftdetect maps *.vp to verilog and
" uses `au!` to clear earlier autocmds.
au! BufRead,BufNewFile *.vp  set filetype=genesis2
au! BufRead,BufNewFile *.svp set filetype=genesis2
au! BufRead,BufNewFile *.vph set filetype=genesis2
