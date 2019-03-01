;;; goto-line-preview.el --- Preview line when executing `goto-line` command.                     -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Shen, Jen-Chieh
;; Created date 2019-03-01 14:53:00

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Description: Preview line when executing `goto-line` command.
;; Keyword: line navigation
;; Version: 0.0.1
;; Package-Requires: ((emacs "25"))
;; URL: https://github.com/jcs090218/wiki-this

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Preview line when executing `goto-line` command.
;;

;;; Code:


(defgroup goto-line-preview nil
  "Preview line when executing `goto-line` command."
  :prefix "goto-line-preview-"
  :group 'convenience
  :group 'tools
  :link '(url-link :tag "Repository" "https://github.com/jcs090218/goto-line-preview"))


(defvar goto-line-preview-active nil
  "Flag to check if goto line command active?")

(defvar goto-line-preview-prev-buffer nil
  "Record down the previous buffer before we do `goto-line-preview-goto-line' command.")

(defvar goto-line-preview-prev-line-num nil
  "Record down the previous line number before we do `goto-line-preview-goto-line' command.")


(defun goto-line-preview-do-preview ()
  "Do the goto line preview action."
  (save-selected-window
    (when goto-line-preview-prev-buffer
      (let ((line-num-str "")
            (line-num -1))
        (setq line-num-str (thing-at-point 'word))

        (switch-to-buffer goto-line-preview-prev-buffer)

        (if line-num-str
            (progn
              (setq line-num (string-to-number line-num-str))
              (when (numberp line-num)
                (goto-line-preview-do line-num)))
          (goto-line-preview-do goto-line-preview-prev-line-num))))))

(defun goto-line-preview-do (line-num)
  "Do goto line.
LINE-NUM : Target line number to navigate to."
  (save-selected-window
    (switch-to-buffer goto-line-preview-prev-buffer)
    (with-no-warnings
      (goto-line line-num))
    (call-interactively #'recenter)))


;;;###autoload
(defun goto-line-preview-internal (line-num)
  "Preview goto line internal.
LINE-NUM : Target line number to navigate to."
  (interactive "nGoto line: "))

;;;###autoload
(defun goto-line-preview-goto-line ()
  "Preview goto line.
LINE-NUM : Target line number to navigate to."
  (interactive)
  (setq goto-line-preview-active t)
  (setq goto-line-preview-prev-buffer (buffer-name))
  (setq goto-line-preview-prev-line-num (string-to-number (format-mode-line "%l")))
  (call-interactively #'goto-line-preview-internal))


(add-hook 'minibuffer-setup-hook
          (lambda ()
            (add-hook 'post-command-hook #'goto-line-preview-minibuffer-post-command-hook nil t)))

(defun goto-line-preview-minibuffer-post-command-hook ()
  "Minibuffer post command hook."
  (when goto-line-preview-active
    (goto-line-preview-do-preview)))

(add-hook 'minibuffer-exit-hook
          (lambda ()
            (setq goto-line-preview-active nil)))


(provide 'goto-line-preview)
;;; goto-line-preview.el ends here
