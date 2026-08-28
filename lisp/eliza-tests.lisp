;;;; eliza-tests.lisp -- smoke tests for lisp/eliza.lisp
;;;;
;;;; Run:  sbcl --script lisp/eliza-tests.lisp
;;;; Exits non-zero on the first failure, so CI catches regressions.
;;;;
;;;; These assert only deterministic behaviour. Response selection is random,
;;;; so we check the matcher, the reader, and the shape of what RESPOND
;;;; returns -- never which of a rule's responses came back.

(defparameter cl-user::*eliza-autostart* nil)   ; load as a library, no REPL

(load (merge-pathnames "eliza.lisp" *load-truename*))

(in-package :eliza)

(defparameter *failures* 0)

(defun check (name expected actual)
  (if (equal expected actual)
      (format t "  ok   ~A~%" name)
      (progn
        (incf *failures*)
        (format t "  FAIL ~A~%       expected: ~S~%       actual:   ~S~%"
                name expected actual))))

(defun check-true (name actual)
  (if actual
      (format t "  ok   ~A~%" name)
      (progn
        (incf *failures*)
        (format t "  FAIL ~A (got NIL)~%" name))))

(format t "~&eliza smoke tests~%")

;;; Reader: punctuation stripped, contractions expanded, symbols interned.
(check "read-input strips punctuation"
       '(i am sad) (read-input "I am sad."))
(check "read-input expands i'm"
       '(i am sad) (read-input "I'm sad!"))
(check "read-input expands can't"
       '(i cannot sleep) (read-input "I can't sleep"))
(check "read-input expands don't"
       '(i do not know) (read-input "I don't know?"))

;;; Pattern matcher: segment variables bind the right spans.
(let ((b (pat-match '((?* ?x) i want (?* ?y)) '(i want a dog))))
  (check-true "pat-match succeeds on 'i want'" (not (eq b +fail+)))
  (check "?x binds the empty prefix" nil (binding-val (get-binding '?x b)))
  (check "?y binds the tail" '(a dog) (binding-val (get-binding '?y b))))

(let ((b (pat-match '((?* ?x) i want (?* ?y)) '(well i want a dog))))
  (check "?x binds a non-empty prefix"
         '(well) (binding-val (get-binding '?x b))))

(check-true "pat-match fails when the literal is absent"
            (eq +fail+ (pat-match '((?* ?x) i want (?* ?y)) '(hello there))))

;;; Viewpoint switch runs over bound values, not the whole pattern.
(check "switch-viewpoint flips my -> your"
       '((?y your job)) (switch-viewpoint '((?y . (my job)))))

;;; RESPOND returns a FLAT list of symbols -- this is the bug that segment
;;; bindings caused before FLATTEN was added.
(let ((r (respond (read-input "I want a new job"))))
  (check-true "respond returns something" r)
  (check-true "respond output is flat" (every #'symbolp r))
  (check-true "respond splices the binding in"
              (search '(a new job) r :test #'eq)))

;;; The catch-all rule guarantees every input gets an answer.
(check-true "unmatched input still gets a response"
            (respond (read-input "xyzzy plugh frobozz")))

;;; SAY must not error on any response (punctuation logic touches FIRST).
(check-true "say handles a response without erroring"
            (progn (with-output-to-string (*standard-output*)
                     (say (respond (read-input "hello"))))
                   t))

(format t "~&~[all tests passed~:;~:*~D test(s) FAILED~]~%" *failures*)
(when (plusp *failures*)
  (sb-ext:exit :code 1))
