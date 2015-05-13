;;;; TODO Might be useful overall to steal more ideas from
;;;; key-chord.el .

;;;; TODO Use 1-6 (and others) as bucky bits, queued of course. cmd in
;;;; combination with a character should produce C-<char> . cmd in
;;;; combination with bucky bits should either set a bucky bit for the
;;;; next char, cmd itself, or maybe a mode switcher? Lots of chording
;;;; possibilities for the bucky bits. The keys above normal positions
;;;; work with the same hand arrangement. The most important thing is
;;;; to provide sane defaults for common chords and bucky bits, while
;;;; providing a systematic method for less common chords and a good
;;;; ELisp interface for expansion and customization.

;;;; TODO Would it be smart to allow multi-chord operations, for caps
;;;; and such (iterate along the modes)? Or just to encourage all
;;;; lowercase?

;;;; testing the microwriter, once more unto the breach

;;;; TODO Need to build a typing trainer for the chording keyboard.

(defvar microwriter-mode-delay 0.1
  "The maximum delay between microwriter-mode key releases.")

(make-variable-buffer-local
   (defvar microwriter-mode-pressed-keys '()
     "The keys pressed since the last character entry event."))


;; (defun print-elements-of-list (list)
;;   "Print each element of LIST on a line of its own."
;;   (while list
;;     (print (car list))
;;     (setq list (cdr list))))

(defun sets-equal (set1 set2)
  (if (equal set1 set2)
      t
    (if (member (car set1) set2)
        (sets-equal (remq (car set1) set1) (remq (car set1) set2))
      nil)))

(defmacro case-sets-equal (condvar &rest body)
  (append
   (cons 'cond
         ;; TODO Reverse the fingers-character order?
         (mapcar (lambda (x) `((sets-equal ,condvar ',(first x)) '(insert ,(second x))))
                 body))
    ;; ,(mapcar (lambda (x) (list (list 'sets-equal condvar (first x)) (second x))) body)
    ;; TODO Fix this to be more general.
    '((t ""))))

;; TODO Currently the command parser is a possible recursive
;; disaster. Write a mini-language for describing chords.
(defun microwriter-mode-get-action (keys)
  (cond
   ((sets-equal keys '(cmd)) "cmd")
   ((member 'cmd keys)
    (let ((action (microwriter-mode-get-action (remq 'cmd keys))))
      `(insert ,(capitalize (cadr action)))))
   (t (case-sets-equal keys
                       ((index middle) "a")
                       ((middle ring pinky) "b")
                       ((thumb middle) "c")
                       ((thumb index middle) "d")
                       ((index) "e")
                       ((thumb index middle ring) "f")
                       ((ring pinky) "g")
                       ((thumb pinky) "h")
                       ((thumb index) "i")
                       ((thumb ring pinky) "j")
                       ((thumb ring) "k")
                       ((thumb index pinky) "l")
                       ((index middle ring pinky) "m")
                       ((middle ring) "n")
                       ((middle) "o")
                       ((thumb index middle ring pinky) "p")
                       ((middle pinky) "q")
                       ((thumb index ring) "r")
                       ((ring) "s")
                       ((index ring) "t")
                       ((pinky) "u")
                       ((index pinky) "v")
                       ((thumb index ring pinky) "w")
                       ((thumb middle ring pinky) "x")
                       ((thumb middle ring) "y")
                       ((thumb middle pinky) "z")
                       ((thumb) " ")
                       ((index middle ring) ".")
                       ((index middle pinky) "-")
                       ((index ring pinky) ",")
                       ((thumb index middle pinky) "'")))))

;; Todo Trigger the timer event only on key release?
(defun microwriter-mode-key-handler (keysym)
  (interactive)
  (add-to-list 'microwriter-mode-pressed-keys keysym)
  (when (sit-for microwriter-mode-delay 'no-redisplay)
    ;; TODO Rewrite this to use a macro later.
    (eval (microwriter-mode-get-action microwriter-mode-pressed-keys))
    (setq microwriter-mode-pressed-keys '())))
(defvar microwriter-mode-map
  (let ((map (make-sparse-keymap)))
    ;; TODO Consider swaping cmd and thumb .
    ;; First test message:hello world.
    (define-key map (kbd "<kp-insert>")
      (lambda () (interactive) (microwriter-mode-key-handler 'cmd)))
    (define-key map (kbd "<kp-end>")
      (lambda () (interactive) (microwriter-mode-key-handler 'thumb)))
    (define-key map (kbd "<kp-home>")
      (lambda () (interactive) (microwriter-mode-key-handler 'index)))
    (define-key map (kbd "<kp-up>")
      (lambda () (interactive) (microwriter-mode-key-handler 'middle)))
    (define-key map (kbd "<kp-prior>")
      (lambda () (interactive) (microwriter-mode-key-handler 'ring)))
    (define-key map (kbd "<kp-add>")
      (lambda () (interactive) (microwriter-mode-key-handler 'pinky)))
    map))

;;;###autoload
(define-minor-mode microwriter-mode
  "A mode emulating the Microwriter chording keyboard."
  :lighter " Microwriter")

(provide 'microwriter-mode)
