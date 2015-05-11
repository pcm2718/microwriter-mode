;;;; TODO Might be useful overall to steal more ideas from
;;;; key-chord.el .

(defvar microwriter-mode-delay 0.5
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
         (mapcar (lambda (x) `((sets-equal ,condvar ',(first x)) ,(second x)))
                 body))
    ;; ,(mapcar (lambda (x) (list (list 'sets-equal condvar (first x)) (second x))) body)
    ;; TODO Fix this to be more general.
    '((t ""))))

;; TODO Trigger the timer event only on key release?
(defun microwriter-mode-key-handler (keysym)
  (interactive)
  (add-to-list 'microwriter-mode-pressed-keys keysym)
  (when (sit-for microwriter-mode-delay 'no-redisplay)
      ;; (print-elements-of-list microwriter-mode-pressed-keys)
    ;; TODO Rewrite this to use a macro later.
    (insert
     (case-sets-equal microwriter-mode-pressed-keys
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
                      ((thumb ring pinky) "y")
                      ((thumb middle pinky) "z")
                      ((thumb) " ")
                      ((index middle ring) ".")
                      ((index middle pinky) "-")
                      ((index ring pinky) ",")
                      ((thumb index middle pinky "'"))))
     ;; (cond
     ;;  ((sets-equal microwriter-mode-pressed-keys '(index middle)) "a")
     ;;  (t "")))
    (setq microwriter-mode-pressed-keys '())))

;;;###autoload
(define-minor-mode microwriter-mode
  "A mode emulating the Microwriter chording keyboard."
  :lighter " Microwriter"
  :keymap (let ((map (make-sparse-keymap)))
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

(provide 'microwriter-mode)
