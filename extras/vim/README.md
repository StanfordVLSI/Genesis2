# Vim support for `.vp` / `.svp` / `.vph`

Filetype detection and syntax highlighting for Genesis2 (Perl) template files.

Highlights:
- Verilog (or SystemVerilog if `syntax/verilog_systemverilog.vim` is on the
  runtime path) as the base.
- `//;`-prefixed Perl lines highlighted via embedded `@perlTop`.
- Backtick-delimited inline Perl expressions, escape-aware (`` \` ``) and
  excluding Verilog backtick directives (`` `timescale ``, `` `ifdef ``, ...).
- Comment-only Perl lines (`//; # ...`) highlighted bold so they stand out
  from regular Perl statements.

## Install

### Manual

Copy (or symlink) the two directories into your vim runtime:

```sh
mkdir -p ~/.vim/after/ftdetect ~/.vim/syntax
cp after/ftdetect/genesis2.vim ~/.vim/after/ftdetect/genesis2.vim
cp syntax/genesis2.vim          ~/.vim/syntax/genesis2.vim
```

The ftdetect lives under `after/` and uses `set filetype=genesis2` (force) so it
wins against the `verilog_systemverilog` plugin (and any other plugin) whose
ftdetect maps `*.vp` to a different filetype and uses `au!` to clear earlier
autocmds.

For Neovim, swap `~/.vim` for `~/.config/nvim`.

### Plugin manager

Point your manager at this subdirectory. With `vim-plug`:

```vim
Plug 'Genesis2', { 'rtp': 'vim.vp' }
```

(Adjust the source spec for your fork/clone location.)

## Files
- `after/ftdetect/genesis2.vim` — maps `*.vp`, `*.svp`, `*.vph` to filetype `genesis2`,
  forcing the filetype so it overrides plugins that also claim `*.vp`.
- `syntax/genesis2.vim` — syntax rules layered on top of Verilog/SystemVerilog.
