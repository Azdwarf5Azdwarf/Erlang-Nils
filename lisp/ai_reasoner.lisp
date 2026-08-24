(defun reason (query)
  "Symbolic AI core inspired by early AI research."
  (cond
    ((null query) nil)
    (t (list 'thought query))))
