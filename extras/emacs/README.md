# Emacs support for `.vp` / `.svp` / `.vph`

`genesis2-mode` — a major mode for Genesis2 Perl-templated
Verilog/SystemVerilog files. Derives from `verilog-mode`; uses
`mmm-mode` to layer real `perl-mode` on the embedded-Perl regions.

## Install

```sh
mkdir -p ~/.emacs.d/lisp/mmm
curl -sSL https://melpa.org/packages/mmm-mode-20240222.428.tar \
    | tar -x --strip-components=1 -C ~/.emacs.d/lisp/mmm
cp genesis2-mode.el ~/.emacs.d/
```

Add to `~/.emacs.d/init.el`:

```elisp
(add-to-list 'load-path "~/.emacs.d/lisp/mmm")
(require 'mmm-mode)
(load "~/.emacs.d/genesis2-mode")
(setq mmm-submode-decoration-level 0)
(setq mmm-global-mode 'maybe)
```
