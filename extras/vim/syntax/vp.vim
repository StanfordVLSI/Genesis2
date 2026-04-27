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
syn match vpSentinel +//;\s*#.*$+ containedin=ALL

" //;<rest> -- the rest of the line is Perl (excluding the sentinel form
" above, which is matched separately).
syn region vpLine matchgroup=vpDelim
    \ start=+//;\(\s*#\)\@!+ end=+$+
    \ keepend containedin=ALL contains=@perlTop

" `expr` -- inline Perl expression.
"   * \\\@<! is "not preceded by a backslash" so a literal-backtick escape
"     (\`) does not open or close the region.
"   * \@! after the start backtick excludes Verilog `directive keywords so
"     they are not mis-parsed as opening a Perl region.
syn region vpInline matchgroup=vpDelim
    \ start=#\\\@<!`\(timescale\|default_nettype\|include\|ifdef\|if\|ifndef\|else\|endif\)\@!#
    \ end=#\\\@<!`#
    \ keepend containedin=ALL contains=@perlTop oneline

hi link vpDelim PreProc

" Make embedded Perl visually distinct from Verilog (which uses Statement).
hi vpPlKeyword  cterm=bold gui=bold ctermfg=magenta guifg=magenta
hi vpPlVar      cterm=NONE gui=NONE ctermfg=cyan  guifg=cyan
hi vpPlString   cterm=NONE gui=NONE ctermfg=green guifg=green
hi vpPlFunction cterm=bold gui=bold

" Keywords / control flow / built-in statements.
hi link perlStatement         vpPlKeyword
hi link perlStatementControl  vpPlKeyword
hi link perlStatementFlow     vpPlKeyword
hi link perlStatementInclude  vpPlKeyword
hi link perlStatementPackage  vpPlKeyword
hi link perlStatementScalar   vpPlKeyword
hi link perlStatementList     vpPlKeyword
hi link perlStatementHash     vpPlKeyword
hi link perlStatementProc     vpPlKeyword
hi link perlStatementMisc     vpPlKeyword
hi link perlStatementIOfunc   vpPlKeyword
hi link perlStatementFiles    vpPlKeyword
hi link perlStatementNumeric  vpPlKeyword
hi link perlStatementRegexp   vpPlKeyword
hi link perlStatementStorage  vpPlKeyword
hi link perlConditional       vpPlKeyword
hi link perlRepeat            vpPlKeyword
hi link perlOperator          vpPlKeyword
hi link perlControl           vpPlKeyword
hi link perlInclude           vpPlKeyword
hi link perlStorageClass      vpPlKeyword
hi link perlType              vpPlKeyword

" Variables.
hi link perlVarPlain          vpPlVar
hi link perlVarPlain2         vpPlVar
hi link perlVarBlock          vpPlVar
hi link perlVarMember         vpPlVar
hi link perlVarSimpleMember   vpPlVar
hi link perlIdentifier        vpPlVar
hi link perlSpecialDollar     vpPlVar

" Strings / numbers.
hi link perlString            vpPlString
hi link perlStringUnexpanded  vpPlString
hi link perlQQ                vpPlString
hi link perlNumber            Number
hi link perlFloat             Float

" Subs / functions.
hi link perlFunction          vpPlFunction
hi link perlSubName           vpPlFunction
hi link perlMethod            vpPlFunction

" Sentinel highlight: same foreground as Comment, but bold. We can't use
" `:hi link` (it would clobber the bold attribute), so resolve Comment's
" colours at load time and apply them explicitly.
let s:_cterm_fg = synIDattr(synIDtrans(hlID('Comment')), 'fg', 'cterm')
let s:_gui_fg   = synIDattr(synIDtrans(hlID('Comment')), 'fg', 'gui')
exe 'hi vpSentinel cterm=bold gui=bold'
    \ . (!empty(s:_cterm_fg) ? ' ctermfg=' . s:_cterm_fg : '')
    \ . (!empty(s:_gui_fg)   ? ' guifg='   . s:_gui_fg   : '')
unlet s:_cterm_fg s:_gui_fg

let b:current_syntax = "vp"

" vim: set ts=4 sw=4:
