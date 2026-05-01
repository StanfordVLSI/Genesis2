" Vim syntax file
" Language: Genesis2 Perl template (.vp / .svp / .vph)
" Verilog/SystemVerilog base with embedded Perl on `//;` lines and inside
" backtick-delimited inline expressions.

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" Base: SystemVerilog if available, else plain Verilog.
if !empty(globpath(&runtimepath, 'syntax/verilog_systemverilog.vim'))
    ru! syntax/verilog_systemverilog.vim
    set ft=verilog_systemverilog
else
    ru! syntax/verilog.vim
    set ft=verilog
endif
unlet! b:current_syntax

" Embedded Perl. Some perl.vim builds bail early if b:current_syntax is set;
" make sure it isn't before we include.
unlet! b:current_syntax
syn include @perlTop syntax/perl.vim
unlet! b:current_syntax

" //; # ... -- comment-only Perl lines (block-closing sentinels like
" `# end if`, `# endif`, `# end foreach`). Highlighted as comments but bold so
" they stand out as structural markers.
syn match genesis2Sentinel +//;\s*#.*$+ containedin=ALL

" //;<rest> -- the rest of the line is Perl (excluding the sentinel form
" above, which is matched separately).
syn region genesis2Line matchgroup=genesis2Delim
    \ start=+//;\(\s*#\)\@!+ end=+$+
    \ keepend containedin=ALL contains=@perlTop

" `expr` -- inline Perl expression.
"   * \\\@<! is "not preceded by a backslash" so a literal-backtick escape
"     (\`) does not open or close the region.
"   * \@! after the start backtick excludes Verilog `directive keywords so
"     they are not mis-parsed as opening a Perl region.
syn region genesis2Inline matchgroup=genesis2Delim
    \ start=#\\\@<!`\(timescale\|default_nettype\|include\|ifdef\|if\|ifndef\|else\|endif\)\@!#
    \ end=#\\\@<!`#
    \ keepend containedin=ALL contains=@perlTop oneline

hi link genesis2Delim PreProc

" Make embedded Perl visually distinct from Verilog (which uses Statement).
hi genesis2PlKeyword  cterm=bold gui=bold ctermfg=magenta guifg=magenta
hi genesis2PlVar      cterm=NONE gui=NONE ctermfg=cyan  guifg=cyan
hi genesis2PlString   cterm=NONE gui=NONE ctermfg=green guifg=green
hi genesis2PlFunction cterm=bold gui=bold

" Keywords / control flow / built-in statements.
hi link perlStatement         genesis2PlKeyword
hi link perlStatementControl  genesis2PlKeyword
hi link perlStatementFlow     genesis2PlKeyword
hi link perlStatementInclude  genesis2PlKeyword
hi link perlStatementPackage  genesis2PlKeyword
hi link perlStatementScalar   genesis2PlKeyword
hi link perlStatementList     genesis2PlKeyword
hi link perlStatementHash     genesis2PlKeyword
hi link perlStatementProc     genesis2PlKeyword
hi link perlStatementMisc     genesis2PlKeyword
hi link perlStatementIOfunc   genesis2PlKeyword
hi link perlStatementFiles    genesis2PlKeyword
hi link perlStatementNumeric  genesis2PlKeyword
hi link perlStatementRegexp   genesis2PlKeyword
hi link perlStatementStorage  genesis2PlKeyword
hi link perlConditional       genesis2PlKeyword
hi link perlRepeat            genesis2PlKeyword
hi link perlOperator          genesis2PlKeyword
hi link perlControl           genesis2PlKeyword
hi link perlInclude           genesis2PlKeyword
hi link perlStorageClass      genesis2PlKeyword
hi link perlType              genesis2PlKeyword

" Variables.
hi link perlVarPlain          genesis2PlVar
hi link perlVarPlain2         genesis2PlVar
hi link perlVarBlock          genesis2PlVar
hi link perlVarMember         genesis2PlVar
hi link perlVarSimpleMember   genesis2PlVar
hi link perlIdentifier        genesis2PlVar
hi link perlSpecialDollar     genesis2PlVar

" Strings / numbers.
hi link perlString            genesis2PlString
hi link perlStringUnexpanded  genesis2PlString
hi link perlQQ                genesis2PlString
hi link perlNumber            Number
hi link perlFloat             Float

" Subs / functions.
hi link perlFunction          genesis2PlFunction
hi link perlSubName           genesis2PlFunction
hi link perlMethod            genesis2PlFunction

" Sentinel highlight: same foreground as Comment, but bold. We can't use
" `:hi link` (it would clobber the bold attribute), so resolve Comment's
" colours at load time and apply them explicitly.
let s:_cterm_fg = synIDattr(synIDtrans(hlID('Comment')), 'fg', 'cterm')
let s:_gui_fg   = synIDattr(synIDtrans(hlID('Comment')), 'fg', 'gui')
exe 'hi genesis2Sentinel cterm=bold gui=bold'
    \ . (!empty(s:_cterm_fg) ? ' ctermfg=' . s:_cterm_fg : '')
    \ . (!empty(s:_gui_fg)   ? ' guifg='   . s:_gui_fg   : '')
unlet s:_cterm_fg s:_gui_fg

let b:current_syntax = "genesis2"

" vim: set ts=4 sw=4:
