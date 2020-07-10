;; ch-mode
;; Compact HTML mode
;; Copyright (C) Cay S. Horstmann 2014

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;; Installation:
;;
;; Save this file as ch-mode.el, byte compile it and put the
;; resulting ch.elc file in a directory ch-mode that is listed in
;; load-path, and load it. For example,

;; (add-to-list 'load-path (expand-file-name "/path/to/ch-mode"))
;; (load "ch-mode")

;; You need Scala version 2.10 or later, which needs Java 7 or later.
;; Make a JAR file by running
;;     scalac *.scala
;;     jar cvf ch.jar *.class
;;     rm *.class

;; Then move the ch script and ch.jar to ~/bin or another location
;; of your choice. If you don't have JAVA_HOME and SCALA_HOME set,
;; edit the ch script to set them.

;; Set the path to the ch command in the ch group (default ~/bin/ch)

;; You can change the font faces in the ch-faces group

;; The file chdoc.html explains the markup rules. 

;; The following keyboard shortcuts are provided:

;; S-RET   Insert a bracket pair, or surround region with bracket pair 
;; C-h C-b Show buffer in generic browser (provide in browse-url group)
;; C-h C-c Insert XML comment, or surround region with comment
;; C-h C-f Insert figure
;; C-h C-t Insert table
;; C-h C-r Insert cross reference
;; C-h C-p Insert pre
;; C-h C-l Insert list (ul)
;; C-h C-n Insert numbered list (ol)
;; C-h C-i Insert an ID that is derived from the text that follows
;; C-'     Surround region with curly quotes
;; C-,     Insert apostrophe
;; C--     Insert emdash

(defgroup ch nil
  "Minor mode for editing text files in Compact HTML format."
  :prefix "ch-"
  :group 'wp
  :link '(url-link "http://horstmann.com/ch"))

(defgroup ch-faces nil
  "Faces used in ch Mode"
  :group 'ch
  :group 'faces)

(defcustom ch-command "~/bin/ch"
  "The name of the ch script to run."
  :type 'string
  :group 'ch)

(defvar ch-code-face 'ch-code-face
  "Face name to use for code.")
(defvar ch-strong-face 'ch-strong-face
  "Face name to use for strong.")
(defvar ch-em-face 'ch-em-face
  "Face name to use for strong.")
(defvar ch-h1-face 'ch-h1-face
  "Face name to use for h1.")
(defvar ch-h2-face 'ch-h2-face
  "Face name to use for h2.")
(defvar ch-h3-face 'ch-h3-face
  "Face name to use for h3.")
(defvar ch-h4-face 'ch-h4-face
  "Face name to use for h4.")

(defface ch-code-face 
  '((t (:family "fixed"))) 
  "ch code face" :group 'ch-faces)
(defface ch-strong-face 
  '((t (:weight bold))) 
  "ch strong face" :group 'ch-faces)
(defface ch-em-face 
  '((t (:slant italic))) 
  "ch em face" :group 'ch-faces)
(defface ch-h1-face 
  '((t (:weight bold :height 1.4))) 
  "ch h1 face" :group 'ch-faces)
(defface ch-h2-face 
  '((t (:weight bold :height 1.25))) 
  "ch h2 face" :group 'ch-faces)
(defface ch-h3-face 
  '((t (:weight bold :height 1.15))) 
  "ch h3 face" :group 'ch-faces)
(defface ch-h4-face 
  '((t (:weight bold :height 1.08))) 
  "ch h4 face" :group 'ch-faces)

(defvar ch-font-lock-defaults nil "Value for font-lock-defaults.")

(defun ch-pre-bounds ()
  "pre bounds of point or nil if not in pre"
  (interactive)
  (save-excursion
    (let ((done nil) (beg nil) (result nil))
      (condition-case nil
          (while (not done)
            (backward-up-list 1)
            (cond ((looking-at "〈pre")
                   (setq done t)
                   (setq beg (point))
                   (forward-list)
                   (setq result (list beg (point))))))
        (error nil))
      result)))

(defun ch-eliminate-tag ()
  "eliminate current tag"
  (interactive)
  (let ((beg nil) (end nil) (taglen nil))
    (backward-up-list 1)
    (setq beg (point))
    (forward-whitespace 1)
    (setq taglen (- (point) beg 1))
    (goto-char beg)
    (forward-list)
    (setq end (point))
    (delete-backward-char 1)
    (goto-char beg)
    (delete-char taglen)
    (goto-char (- end taglen))
))



(defun ch-match-pre (last)                            
  "Match 〈pre from the point to last."               
  (interactive)
  (let ((bounds (ch-pre-bounds)))
    (cond (bounds 
           (set-match-data (list (point) (- (cadr bounds) 1)))
           (goto-char (+ (cadr bounds) 1))
           t)
          ((search-forward "〈pre" last t)
           (let ((beg (point)) (bounds (ch-pre-bounds)))         
             (cond (bounds        
                    (set-match-data (list (point) (- (cadr bounds) 1)))
                    (goto-char (+ (cadr bounds) 1))
                    t)
                   (t nil))))
          (t nil))))

(setq ch-font-lock-defaults
      '(
        (ch-match-pre 0 ch-code-face t t)
        ("〈\\(!--\\|!\\[CDATA\\[\\)?\\|\\(--\\|\\]\\]\\)?〉" . font-lock-comment-delimiter-face)
        ("〈\\([?!&][^〉]*\\)〉" . (1 font-lock-preprocessor-face))
        ("〈[a-zA-Z0-9:#_-]+〉" . font-lock-constant-face)
        ("〈h1\\([.#][a-zA-Z0-9:_-]+\\)*\\( [a-zA-Z0-9:#_-]+=\\('[^']*'\\|[^ ]+\\)\\)*\\([^〉]+\\)〉" . (4 ch-h1-face))
        ("〈h2\\([.#][a-zA-Z0-9:_-]+\\)*\\( [a-zA-Z0-9:#_-]+=\\('[^']*'\\|[^ ]+\\)\\)*\\([^〉]+\\)〉" . (4 ch-h2-face))
        ("〈h3\\([.#][a-zA-Z0-9:_-]+\\)*\\( [a-zA-Z0-9:#_-]+=\\('[^']*'\\|[^ ]+\\)\\)*\\([^〉]+\\)〉" . (4 ch-h3-face))
        ("〈h4\\([.#][a-zA-Z0-9:_-]+\\)*\\( [a-zA-Z0-9:#_-]+=\\('[^']*'\\|[^ ]+\\)\\)*\\([^〉]+\\)〉" . (4 ch-h4-face))
        ("〈\\(strong\\|b\\) \\([^〉]+\\)〉" . (2 ch-strong-face))
        ("〈\\(em\\|i\\|var\\) \\([^〉]+\\)〉" . (2 ch-em-face))
        ("〈 \\([^〉]+\\)〉" . (1 ch-code-face))
        ("〈\\([.a-zA-Z0-9:#_-]+\\)" . (1 font-lock-builtin-face))
        ("〈[.a-zA-Z0-9:#_-]+\\(\\( [a-zA-Z0-9:#_-]+=\\('[^']*'\\|[^ 〉]+\\)\\)*\\)" . (1 font-lock-type-face))
        ))

;; TODO: Factor out common code

(defun ch-surround-region-with-brackets ()
      (interactive)
        (let (pos1 pos2)
          (if (region-active-p)
              (setq pos1 (region-beginning) pos2 (region-end))
            (setq pos1 (point) pos2 (point)))
        (goto-char pos1)
        (insert "〈")
        (goto-char (+ 1 pos2))
        (insert "〉")
        (backward-char (+ 1 (- pos2 pos1)))
        (deactivate-mark)
        ))

(defun ch-surround-region-with-quotes ()
      (interactive)
        (let (pos1 pos2)
          (if (region-active-p)
              (setq pos1 (region-beginning) pos2 (region-end))
            (setq pos1 (point) pos2 (point)))
        (goto-char pos1)
        (insert "“")
        (goto-char (+ 1 pos2))
        (insert "”")
        (backward-char (+ 1 (- pos2 pos1)))
        (deactivate-mark)
        ))

(defun ch-surround-region-with-comment ()
      (interactive)
        (let (pos1 pos2)
          (if (region-active-p)
              (setq pos1 (region-beginning) pos2 (region-end))
            (setq pos1 (point) pos2 (point)))
        (goto-char pos1)
        (insert "〈!-- ")
        (goto-char (+ 5 pos2))
        (insert " --〉")
        (backward-char (+ 4 (- pos2 pos1)))
        (deactivate-mark)
        ))

(defun ch-to-id (string) 
  "Turn string into an ID, lowercase and with - instead of spaces."
  (replace-regexp-in-string "[^a-z0-9-]" "" 
   (downcase 
    (replace-regexp-in-string "\s+" "-" 
     (replace-regexp-in-string "\\`\#s+" "" 
      (replace-regexp-in-string "\s+\\'" "" string))))))

(defun ch-split ()
  (interactive)
  (let (pos1 pos2 tag)
    (setq pos1 (point))    
    (backward-up-list)
    (setq pos2 (point))
    (right-word)
    (setq tag (buffer-substring (+ pos2 1) (point)))
    (message tag)
    (goto-char pos1)
    (insert (concat "〉〈" tag " "))
    ))

(defun ch-insert-id ()
  (interactive)
        (let (pos1 pos2 idstr)
          (if (region-active-p)
              (setq pos1 (region-beginning) pos2 (region-end))
            (progn
              (setq pos1 (point))
              (up-list)
              (setq pos2 (- (point) 1))
              (goto-char pos1)
              ))

          (setq idstr (ch-to-id (buffer-substring pos1 pos2)))
          (goto-char (- pos1 1))
          (insert (concat "#" idstr))
          (kill-new idstr)
          (deactivate-mark)))

(defun ch-insert-single-quote ()
  (interactive)
  (insert "’"))

(defun ch-insert-hyphen ()
  (interactive)
  (insert "—"))

(defun ch-insert-figure (caption)
  (interactive "sCaption: \n")
  (let ((id (ch-to-id caption)))
    (insert (concat "〈a.figureref href=#" id "〉\n" "    〈div.figure#" id "\n      〈img alt='" caption "' src=images/" id ".png〉\n      〈div " caption "〉\n    〉\n"))))

(defun ch-insert-table (caption rows columns)
  (interactive "sCaption: \nsRows: \nsColumns: \n")
  (let (pos res id)
    (setq id (ch-to-id caption))
    (insert (concat "〈a.tableref href='#" id "'〉\n" "    〈table#" id "\n      〈caption "))
    (setq pos (point))
    (insert caption)
    (insert "〉\n      〈tr\n")
    (dotimes (c (string-to-number columns)) (insert "        〈th 〉\n"))
    (insert "      〉\n")
    (dotimes (r (string-to-number rows))
      (insert "      〈tr\n")
      (dotimes (c (string-to-number columns)) (insert "        〈td 〉\n"))
      (insert "      〉\n"))
    (insert "    〉\n")
    (goto-char pos)))

(defun ch-insert-doc ()
  (interactive)
  (let (pos)
    (beginning-of-buffer)
    (insert "〈html xmlns='http://www.w3.org/1999/xhtml'\n  〈head\n    〈meta http-equiv=content-type content='text/html; charset=utf-8'〉\n    〈title ")
    (setq pos (point))
    (insert "〉\n  〉\n  〈body\n  〉\n〉\n")
    (goto-char pos)))

(defun ch-insert-ref (to id)
  (interactive "sTo element: \nsID: \n")
  (insert (concat "〈a." to "ref href='#" id "'〉")))

(defun ch-show-browser ()
  "Show buffer in browser"
  (interactive)
  (browse-url-generic (concat "file://" (shell-quote-argument (replace-regexp-in-string "[.]ch" ".html" buffer-file-name)))))

(defun ch-pre ()
  (interactive)
  (let (col pos)
    (setq col (current-indentation))    
    (insert "\n")
    (indent-to col)
    (insert "〈pre")
    (insert "\n")
    (setq pos (point))
    (insert "\n〉")
    (goto-char pos)))

(defun ch-items (tag)
  (let (col pos)
    (if (not (string-match "^[[:blank:]]*$"
        (buffer-substring (line-beginning-position) (point))))
          (newline-and-indent))
    (if (not (string-match "^[[:blank:]]*$"
        (buffer-substring (point) (line-end-position))))
        (progn
          (newline-and-indent)
          (forward-line -1)
          (indent-for-tab-command)          
          ))    
    (insert tag)    
    (backward-char 1)
    (newline-and-indent)
    (insert "〈li 〉")
    (indent-for-tab-command)
    (forward-char 4)
    (setq pos (point))
    (forward-char 1)
    (newline-and-indent)
    (insert "〈li 〉")    
    (newline-and-indent)
    (insert "〈li 〉")    
    (indent-for-tab-command)
    (forward-char 5)
    (newline-and-indent)
    (goto-char pos)))

(defun ch-ul ()
  (interactive)
  (ch-items "〈ul〉"))

(defun ch-ol ()
  (interactive)
  (ch-items "〈ol〉"))

(define-derived-mode ch-mode text-mode
  (setq font-lock-defaults '(ch-font-lock-defaults))
  (setq mode-name "CH")
  (define-key ch-mode-map [(shift return)] 'ch-surround-region-with-brackets)
  (define-key ch-mode-map (kbd "C-'") 'ch-surround-region-with-quotes)
  (define-key ch-mode-map (kbd "C-,") 'ch-insert-single-quote)
  (define-key ch-mode-map (kbd "C--") 'ch-insert-hyphen)
  (define-key ch-mode-map (kbd "C-h C-s") 'ch-split)
  (define-key ch-mode-map (kbd "C-h C-p") 'ch-pre)
  (define-key ch-mode-map (kbd "C-h C-l") 'ch-ul)
  (define-key ch-mode-map (kbd "C-h C-n") 'ch-ol)
  (define-key ch-mode-map (kbd "C-h C-c") 'ch-surround-region-with-comment)
  (define-key ch-mode-map (kbd "C-h C-f") 'ch-insert-figure)
  (define-key ch-mode-map (kbd "C-h C-t") 'ch-insert-table)
  (define-key ch-mode-map (kbd "C-h C-r") 'ch-insert-ref)
  (define-key ch-mode-map (kbd "C-h C-i") 'ch-insert-id)
  (define-key ch-mode-map (kbd "C-h C-d") 'ch-insert-doc-browser)
  (define-key ch-mode-map (kbd "C-h C-b") 'ch-show-browser)
)

(setq auto-mode-alist       
      (cons '("\\.ch\\'" . ch-mode) auto-mode-alist))
(setq auto-mode-alist       
      (cons '("\\.chx\\'" . ch-mode) auto-mode-alist))

(defun font-lock-and-indent ()
  "Font lock and indent."
  (interactive)
  (font-lock-fontify-buffer)
  (newline-and-indent))

(defvar ch-indent-offset 2
  "*Indentation offset for `ch-mode'.")

(defun ch-indent-line ()
  "Indent current line for `ch-mode'."
  (interactive)
  (let ((indent-col 0) (done nil) first-col)
    (save-excursion
      (back-to-indentation)
      (setq first-col (current-column))
      (beginning-of-line)
      (condition-case nil
          (while (not done)
            (backward-up-list 1)
            (cond ((or (looking-at "〈pre") (looking-at "〈!--") (looking-at "〈!\\[CDATA\\["))
                   (setq indent-col first-col)
                   (setq done t))
                  ((looking-at "〈")
                   (setq indent-col (+ indent-col ch-indent-offset)))))
        (error nil)))
    (save-excursion
      (back-to-indentation)
      (when (and (looking-at "〉") (>= indent-col ch-indent-offset))
        (setq indent-col (- indent-col ch-indent-offset))))
    (indent-line-to indent-col)))

(add-hook 'ch-mode-hook 
          (lambda () 
;;            (setq indent-line-function 'scala-indent:indent-line)
;;            (set (make-local-variable 'indent-line-function) 'ch-indent-line)
            (set 'indent-line-function 'ch-indent-line)
            (setq tab-width 2)
            (setq word-wrap t)
            (variable-pitch-mode t)
            (local-set-key (kbd "RET") 'font-lock-and-indent)
            ))

(defun ch-file-time (filename) 
  (string-to-number 
   (format-time-string 
    "%s" 
    (nth 5 (file-attributes filename)))))

(defun ch-find-file-hook ()
  "When finding a ch file, make sure there isn't a newer HTML file"
  (if (and buffer-file-name
           (string-match "\.ch$" buffer-file-name))
      (let* ((mtime-ch (nth 5 (file-attributes (buffer-file-name))))
             (htmlfile (replace-regexp-in-string "\.ch$" ".html" buffer-file-name)))
        (if (and (file-exists-p htmlfile)            
                 (< (+ 2 (ch-file-time (buffer-file-name)))
                    (ch-file-time htmlfile)))
            (progn
              (toggle-read-only 1)
              (message (concat "Caution: " htmlfile " is newer than " (buffer-file-name))))
          ))))
(add-hook 'find-file-hook 'ch-find-file-hook)

(defun ch-after-save-hook ()
  "After saving a ch file, run the ch script"
  (if (and buffer-file-name
           (string-match "\.chx?$" buffer-file-name))
      (progn
        (setq cmd (concat ch-command " " (shell-quote-argument buffer-file-name)))
        
        (setq output (shell-command-to-string cmd))
        (if (> (length (split-string output "\n")) 2)
            (message output))
        )))
(add-hook 'after-save-hook 'ch-after-save-hook)

(provide 'ch-mode)
