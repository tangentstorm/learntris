# learntris implementation in picolisp

(def '*M ()) # matrix
(def '*Q ()) # input queue

# -- the matrix ------------------------------------------------
# "matrix" is the official term for the 22 * 10 grid of cells.

(de cmd-c () # clear the matrix
   (setq *M ())
   (for Y 22
      (setq *M (append *M '(". . . . . . . . . ."))) ) )

(de cmd-g () # given the following matrix...
   (setq *M ())
   (for Y 22
      (setq *M (append *M (list (line)))) ) )

(de cmd-p () # print the matrix
   (mapcar 'prinl *M) )


# -- the input queue -------------------------------------------

(de ls>q (ls) # copy items in list to global queue
   (mapcar '((x) (fifo '*Q x)) ls)
   ls ) # return list the list

(de q? () (fifo '*Q)) # next value in the queue, or nil


# -- command dispatch ------------------------------------------

(de dispatch (Ch)
   (case Ch
      ("c" (cmd-c))
      ("g" (cmd-g))
      ("p" (cmd-p))
      ("q" (bye)) ) )

(de main ()
   (cmd-c)
   (while (ls>q (line))
      (while (q?)
         (dispatch @) ) ) )
