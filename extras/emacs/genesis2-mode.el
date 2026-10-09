;;; genesis2-mode.el --- Major mode for Genesis2 .vp/.svp/.vph templates -*- lexical-binding: t; -*-

;; Author: Genesis2 contributors
;; Keywords: languages, verilog, perl
;; Package-Requires: ((emacs "26.1") (mmm-mode "0.5.9"))
;;
;; This file mirrors `extras/vim/syntax/genesis2.vim'.


(require 'verilog-mode)
(require 'mmm-mode)
(require 'mmm-auto)

(defgroup genesis2 nil
  "Major mode for Genesis2 Perl-templated Verilog files."
  :group 'languages
  :prefix "genesis2-")

(defface genesis2-delim-face
  '((t :inherit font-lock-preprocessor-face))
  "Face for the Genesis2 region delimiters: `//;' and the bracketing backticks."
  :group 'genesis2)

(defface genesis2-sentinel-face
  '((t :inherit font-lock-comment-face :weight bold))
  "Face for comment-only Perl lines (`//; # ...')."
  :group 'genesis2)

(defconst genesis2--verilog-backtick-directives
  '("timescale" "default_nettype" "include"
    "ifdef" "if" "ifndef" "else" "endif")
  "Verilog `directive keywords excluded from inline-Perl region matching.")

(defconst genesis2--font-lock-keywords
  `(("^[ \t]*//;[ \t]*#.*$" . 'genesis2-sentinel-face)
    ("//;\\(?:[^#]\\|$\\)" 0 'genesis2-delim-face t)
    ("`" . 'genesis2-delim-face))
  "Additional font-lock keywords for `genesis2-mode'.")

;;;###autoload
(define-derived-mode genesis2-mode verilog-mode "Genesis2"
  "Major mode for Genesis2 Perl-templated Verilog/SystemVerilog files."
  (font-lock-add-keywords nil genesis2--font-lock-keywords))

;;;###autoload
(progn
  (add-to-list 'auto-mode-alist '("\\.vp\\'"  . genesis2-mode))
  (add-to-list 'auto-mode-alist '("\\.svp\\'" . genesis2-mode))
  (add-to-list 'auto-mode-alist '("\\.vph\\'" . genesis2-mode)))

;; Emacs regex has no lookahead; exclusions are done via :front-verify.

(defun genesis2--perl-line-verify ()
  "Return non-nil unless the matched `//;' is a `//; # ...' comment line."
  (save-excursion
    (goto-char (match-end 0))
    (not (looking-at-p "[ \t]*#"))))

(defun genesis2--perl-inline-verify ()
  "Return non-nil unless the matched backtick opens a Verilog directive."
  (save-excursion
    (goto-char (match-end 0))
    (not (looking-at-p
          (concat "\\(?:"
                  (mapconcat #'regexp-quote
                             genesis2--verilog-backtick-directives "\\|")
                  "\\)\\>")))))

(mmm-add-classes
 '((genesis2-perl-line
    :submode perl-mode
    :face mmm-code-submode-face
    :front "//;"
    :front-verify genesis2--perl-line-verify
    :back  "$"
    :include-front nil
    :include-back nil)
   (genesis2-perl-inline
    :submode perl-mode
    :face mmm-code-submode-face
    :front "\\(?:^\\|[^\\\\]\\)\\(`\\)"
    :front-match 1
    :front-verify genesis2--perl-inline-verify
    :back  "\\(?:^\\|[^\\\\]\\)\\(`\\)"
    :back-match 1
    :include-front nil
    :include-back nil)))

(mmm-add-mode-ext-class 'genesis2-mode nil 'genesis2-perl-line)
(mmm-add-mode-ext-class 'genesis2-mode nil 'genesis2-perl-inline)

(provide 'genesis2-mode)

;;; genesis2-mode.el ends here
