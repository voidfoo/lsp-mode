;;; lsp-typespec.el --- Typespec Client settings -*- lexical-binding: t; -*-

;; Copyright (C) 2024  jeremy.ymeng@gmail.com

;; Author: Jeremy Meng  <jeremy.ymeng@gmail.com>
;; Keywords: languages,tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; lsp-typespec client

;;; Code:

(require 'lsp-mode)
(require 'lsp-semantic-tokens)

(defgroup lsp-typespec nil
  "LSP support for Typespec."
  :link '(url-link "https://github.com/jeremymeng/typespec-lsp")
  :group 'lsp-mode
  :tag "Lsp Typespec")

(defcustom lsp-typespec-custom-server-command nil
  "The typespec-lisp server command."
  :group 'lsp-typespec
  :risky t
  :type '(repeat string))

(lsp-dependency
 'typespec-lsp
 '(:npm :package "@typespec/compiler"
        :path "tsp-server")
 '(:system "tsp-server"))

(defun lsp-typespec--server-executable-path ()
  "Return the typespec-lsp server command."
  (or (executable-find "tsp-server")
      (lsp-package-path 'tsp-server)))

(lsp-register-client
 (make-lsp-client
  :semantic-tokens-faces-overrides '(:types (("docCommentTag" . font-lock-keyword-comment)
                                             ("event" . default)))
  :new-connection (lsp-stdio-connection)
  :major-modes '(typespec-mode)
  :server-id 'typespec-lsp))

(lsp-consistency-check lsp-typespec)

(defun lsp-typespec-semantic-tokens-refresh (&rest _)
  "Force refresh semantic tokens."
  (when-let ((workspace (and lsp-semantic-tokens-enable
                             (lsp-find-workspace 'typespec-lsp (buffer-file-name)))))
    (--each (lsp--workspace-buffers workspace)
      (when (lsp-buffer-live-p it)
        (lsp-with-current-buffer it
                                 (lsp-semantic-tokens--enable))))))

(with-eval-after-load 'typespec
  (when lsp-semantic-tokens-enable
    ;; refresh tokens
    (add-hook 'typespec-mode-hook #'lsp-typespec-semantic-tokens-refresh)))

(provide 'lsp-typespec)
;;; lsp-typespec.el ends here
