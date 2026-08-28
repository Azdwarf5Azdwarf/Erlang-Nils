;;;; eliza.lisp -- the main [help] script for mini_ai
;;;;
;;;; A Common Lisp ELIZA, after Joseph Weizenbaum's 1966 DOCTOR script.
;;;; Pattern matcher is the classic segment-variable design (Norvig, PAIP ch. 5).
;;;;
;;;; Run it:
;;;;     sbcl --script lisp/eliza.lisp
;;;; or from a REPL:
;;;;     (load "lisp/eliza.lisp")
;;;;     (help)          ; <- main entry point
;;;;
;;;; No API key, no network. This is the local fallback for mini_ai_server.

(defpackage :eliza
  (:use :common-lisp)
  (:export #:help #:eliza #:respond #:*rules*))

(in-package :eliza)

;;; ------------------------------------------------------------------
;;; Pattern matching
;;;
;;; A pattern is a list of words, single variables (?x), and segment
;;; variables ((?* ?x)) that match zero or more words.
;;;     ((?* ?x) i want (?* ?y))  matches  (i really want a dog)
;;;     with ?x = (i really), ?y = (a dog)
;;; ------------------------------------------------------------------

(defparameter +fail+ nil
  "Indicates a failed match.")

(defparameter +no-bindings+ '((t . t))
  "A successful match with no variables bound.")

(defun variable-p (x)
  (and (symbolp x)
       (> (length (symbol-name x)) 1)
       (char= (char (symbol-name x) 0) #\?)))

(defun get-binding (var bindings) (assoc var bindings))
(defun binding-val (binding) (cdr binding))

(defun extend-bindings (var val bindings)
  (cons (cons var val)
        (if (eq bindings +no-bindings+) nil bindings)))

(defun match-variable (var input bindings)
  "Bind VAR to INPUT, unless VAR is already bound to something else."
  (let ((binding (get-binding var bindings)))
    (cond ((null binding) (extend-bindings var input bindings))
          ((equal input (binding-val binding)) bindings)
          (t +fail+))))

(defun segment-pattern-p (pattern)
  (and (consp pattern)
       (consp (first pattern))
       (eq (first (first pattern)) '?*)))

(declaim (ftype function segment-match))   ; mutually recursive with PAT-MATCH

(defun pat-match (pattern input &optional (bindings +no-bindings+))
  "Match PATTERN against INPUT, returning bindings or +FAIL+."
  (cond ((eq bindings +fail+) +fail+)
        ((variable-p pattern) (match-variable pattern input bindings))
        ((eql pattern input) bindings)
        ((segment-pattern-p pattern) (segment-match pattern input bindings))
        ((and (consp pattern) (consp input))
         (pat-match (rest pattern) (rest input)
                    (pat-match (first pattern) (first input) bindings)))
        (t +fail+)))

(defun segment-match (pattern input bindings &optional (start 0))
  "Match (?* ?var) against the shortest prefix that lets the rest match."
  (let ((var (second (first pattern)))
        (pat (rest pattern)))
    (if (null pat)
        (match-variable var input bindings)
        (let ((pos (position (first pat) input :start start :test #'equal)))
          (if (null pos)
              +fail+
              (let ((b2 (pat-match pat (subseq input pos)
                                   (match-variable var (subseq input 0 pos)
                                                   bindings))))
                ;; If the rest failed, try a longer prefix for ?var.
                (if (eq b2 +fail+)
                    (segment-match pattern input bindings (1+ pos))
                    b2)))))))

;;; ------------------------------------------------------------------
;;; Reading what the human typed
;;; ------------------------------------------------------------------

(defparameter *contractions*
  '(("i'm" . "i am") ("you're" . "you are") ("we're" . "we are")
    ("they're" . "they are") ("it's" . "it is") ("that's" . "that is")
    ("can't" . "cannot") ("won't" . "will not") ("don't" . "do not")
    ("doesn't" . "does not") ("didn't" . "did not") ("isn't" . "is not")
    ("aren't" . "are not") ("wasn't" . "was not") ("haven't" . "have not")
    ("hasn't" . "has not") ("wouldn't" . "would not")
    ("shouldn't" . "should not") ("couldn't" . "could not")
    ("i've" . "i have") ("i'd" . "i would") ("i'll" . "i will")
    ("you've" . "you have") ("let's" . "let us"))
  "Expanded before matching so patterns never need apostrophes.")

(defun split-words (string)
  (let ((words '()) (start nil))
    (dotimes (i (length string))
      (let ((c (char string i)))
        (if (or (alphanumericp c) (char= c #\'))
            (unless start (setf start i))
            (when start (push (subseq string start i) words) (setf start nil)))))
    (when start (push (subseq string start) words))
    (nreverse words)))

(defun expand-contraction (word)
  (let ((hit (assoc word *contractions* :test #'string-equal)))
    (if hit (split-words (cdr hit)) (list word))))

(defun read-input (line)
  "Turn a typed LINE into a list of symbols: \"I'm sad.\" -> (I AM SAD)"
  (mapcar (lambda (w) (intern (string-upcase w) :eliza))
          (mapcan #'expand-contraction (split-words (string-downcase line)))))

;;; ------------------------------------------------------------------
;;; Answering
;;; ------------------------------------------------------------------

(defparameter *viewpoint*
  '((i . you) (you . i) (me . you) (my . your) (your . my)
    (mine . yours) (yours . mine) (am . are) (myself . yourself)
    (yourself . myself) (we . you) (us . you) (our . your) (ours . yours))
  "Pronoun flip, so \"I hate my job\" comes back as \"your job\".")

(defun switch-viewpoint (bindings)
  (mapcar (lambda (b) (cons (car b) (sublis *viewpoint* (cdr b))))
          bindings))

(defparameter *rules*
  '((((?* ?x) hello (?* ?y))
     (how do you do please state your problem)
     (hi what seems to be your problem))

    (((?* ?x) help (?* ?y))
     (what kind of help are you looking for)
     (tell me what is wrong and we will look at it together)
     (say more about what you need help with))

    (((?* ?x) computer (?* ?y))
     (do computers worry you)
     (what do you think about machines)
     (why do you mention computers)
     (what do you think machines have to do with your problem))

    (((?* ?x) name (?* ?y))
     (i am not interested in names)
     (names do not matter here please go on))

    (((?* ?x) sorry (?* ?y))
     (please do not apologize)
     (apologies are not necessary)
     (what feelings do you have when you apologize))

    (((?* ?x) i remember (?* ?y))
     (do you often think of ?y)
     (does thinking of ?y bring anything else to mind)
     (why do you remember ?y just now)
     (what in the present situation reminds you of ?y))

    (((?* ?x) do you remember (?* ?y))
     (did you think i would forget ?y)
     (why do you think i should recall ?y now)
     (what about ?y))

    (((?* ?x) if (?* ?y))
     (do you really think it is likely that ?y)
     (do you wish that ?y)
     (what do you think about ?y)
     (really if ?y))

    (((?* ?x) i dreamt (?* ?y))
     (really ?y)
     (have you ever fantasized ?y while you were awake)
     (have you ever dreamt ?y before))

    (((?* ?x) i want (?* ?y))
     (what would it mean if you got ?y)
     (why do you want ?y)
     (suppose you got ?y soon)
     (what would you do if you had ?y))

    (((?* ?x) i am glad (?* ?y))
     (how have i helped you to be ?y)
     (what makes you happy just now)
     (can you explain why you are suddenly ?y))

    (((?* ?x) i am sad (?* ?y))
     (i am sorry to hear you are depressed)
     (i am sure it is not pleasant to be sad)
     (what has made you sad))

    (((?* ?x) i am (?* ?y))
     (is it because you are ?y that you came to me)
     (how long have you been ?y)
     (do you believe it is normal to be ?y)
     (do you enjoy being ?y))

    (((?* ?x) are you (?* ?y))
     (why are you interested in whether i am ?y or not)
     (would you prefer if i were not ?y)
     (perhaps i am ?y in your fantasies))

    (((?* ?x) i cannot (?* ?y))
     (how do you know you cannot ?y)
     (have you tried)
     (perhaps you could ?y now)
     (do you really want to be able to ?y))

    (((?* ?x) i feel (?* ?y))
     (do you often feel ?y)
     (what other feelings do you have)
     (when do you usually feel ?y))

    (((?* ?x) i felt (?* ?y))
     (what other feelings do you have)
     (do you still feel ?y)
     (why do you think you felt ?y))

    (((?* ?x) i (?* ?y) you (?* ?z))
     (perhaps in your fantasy we ?y each other)
     (why do you think you ?y me))

    (((?* ?x) you (?* ?y) me (?* ?z))
     (why do you think i ?y you)
     (you like to think i ?y you does not you))

    (((?* ?x) because (?* ?y))
     (is that the real reason)
     (what other reason might there be)
     (does that reason seem to explain anything else))

    (((?* ?x) were you (?* ?y))
     (perhaps i was ?y)
     (what do you think)
     (what if i had been ?y))

    (((?* ?x) i was (?* ?y))
     (were you really)
     (perhaps i already knew you were ?y)
     (why do you tell me you were ?y now))

    (((?* ?x) always (?* ?y))
     (can you think of a specific example)
     (when)
     (what incident are you thinking of)
     (really always))

    (((?* ?x) never (?* ?y))
     (never at all)
     (are you sure it is never ?y)
     (what would have to change for it not to be never))

    (((?* ?x) perhaps (?* ?y))
     (you do not seem quite certain)
     (why the uncertain tone)
     (do you not know))

    (((?* ?x) everyone (?* ?y))
     (surely not everyone)
     (can you think of anyone in particular)
     (who for example)
     (you are thinking of a special person))

    (((?* ?x) no one (?* ?y))
     (surely someone)
     (who do you have in mind)
     (that seems like a strong claim))

    (((?* ?x) mother (?* ?y))
     (tell me more about your family)
     (who else in your family ?y)
     (what does that bring to mind))

    (((?* ?x) father (?* ?y))
     (tell me more about your family)
     (does he influence you strongly)
     (what else comes to mind when you think of your father))

    (((?* ?x) friend (?* ?y))
     (tell me about your friends)
     (do your friends worry you)
     (why do you bring up the subject of friends))

    (((?* ?x) work (?* ?y))
     (tell me more about your work)
     (how do you feel about your work)
     (does your work relate to why you came here))

    (((?* ?x) yes (?* ?y))
     (you seem quite positive)
     (you are sure)
     (i understand))

    (((?* ?x) no (?* ?y))
     (why not)
     (you are being a bit negative)
     (are you saying no just to be negative))

    (((?* ?x) why do not you (?* ?y))
     (should you ?y yourself)
     (do you believe i do not ?y)
     (perhaps i will ?y in good time))

    (((?* ?x) why cannot i (?* ?y))
     (do you think you should be able to ?y)
     (do you want to be able to ?y)
     (do you believe this will help you to ?y))

    (((?* ?x) is it (?* ?y))
     (do you think it is ?y)
     (perhaps it is ?y what do you think)
     (if it were ?y what would you do))

    (((?* ?x) how (?* ?y))
     (how do you suppose)
     (perhaps you can answer your own question)
     (what is it you are really asking))

    (((?* ?x) what (?* ?y))
     (why do you ask)
     (does that question interest you)
     (what answer would please you most)
     (what comes to mind when you ask that))

    (((?* ?x) it is (?* ?y))
     (you seem very certain)
     (if i told you that it probably is not ?y what would you feel))

    (((?* ?x))
     (very interesting)
     (i am not sure i understand you fully)
     (what does that suggest to you)
     (please continue)
     (go on)
     (do you feel strongly about discussing such things)))
  "Weizenbaum-style DOCTOR rules: (pattern response...). First match wins,
response chosen at random.")

(defun rule-pattern (rule) (first rule))
(defun rule-responses (rule) (rest rule))

(defun random-elt (sequence)
  (elt sequence (random (length sequence))))

(defun flatten (tree)
  "Segment variables bind to lists, so a filled-in response nests. Undo that."
  (cond ((null tree) nil)
        ((atom tree) (list tree))
        (t (mapcan #'flatten (copy-list tree)))))

(defun respond (input)
  "INPUT is a list of symbols; return a list of symbols to say back."
  (some (lambda (rule)
          (let ((result (pat-match (rule-pattern rule) input)))
            (unless (eq result +fail+)
              (flatten (sublis (switch-viewpoint result)
                               (random-elt (rule-responses rule)))))))
        *rules*))

;;; ------------------------------------------------------------------
;;; Printing and the loop
;;; ------------------------------------------------------------------

(defparameter *question-openers*
  '(what why how who when where do does did are is was were can could
    would should have has perhaps really)
  "If the reply starts with one of these it gets a question mark.")

(defun say (words)
  (let ((text (format nil "~{~A~^ ~}"
                      (mapcar (lambda (w) (string-downcase (symbol-name w)))
                              words)))
        (mark (if (member (first words) *question-openers*
                          :test #'string-equal)
                  #\? #\.)))
    (when (plusp (length text))
      (setf (char text 0) (char-upcase (char text 0))))
    (format t "ELIZA: ~A~A~%" text mark)))

(defparameter *quit-words* '("quit" "exit" "bye" "goodbye" "stop"))

(defun banner ()
  (format t "~&ELIZA -- mini_ai [help]~%")
  (format t "Talk to it in plain sentences. Type 'bye' to leave.~%~%")
  (format t "ELIZA: Hello. What is on your mind?~%"))

(defun help ()
  "Main entry point: start an ELIZA session on standard input."
  (banner)
  (loop
    (format t "~&YOU:   ")
    (finish-output)
    (let ((line (read-line *standard-input* nil nil)))
      (cond
        ((null line) (format t "~&ELIZA: Goodbye.~%") (return))
        ((member (string-trim " .!?" (string-downcase line))
                 *quit-words* :test #'string=)
         (format t "ELIZA: Goodbye. Please come back again.~%")
         (return))
        (t (let ((input (read-input line)))
             (if (null input)
                 (say '(please say something))
                 (say (respond input)))))))))

(defun eliza ()
  "Alias for HELP."
  (help))

;;; Make the entry points reachable without the package prefix.
(import '(eliza:help eliza:eliza eliza:respond) :common-lisp-user)

;;; Loading this file starts a session -- it is the [help] script.
;;; To load it as a library instead (tests, embedding), do this first:
;;;     (defparameter cl-user::*eliza-autostart* nil)
(defvar cl-user::*eliza-autostart* t)
(when cl-user::*eliza-autostart*
  (help))
