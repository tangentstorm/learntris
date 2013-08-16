# learntris implementation in picolisp
# copyright (c) 2013 by michal j wallace.
# this code is available under the MIT/X11 license.
# http://github.com/learnprogramming/learntris/

# -- the input queue -------------------------------------------

(def '*Q ()) # input queue
(de *ch  "") # current char

(de ls>q (ls) # copy items in list to global queue
   (mapcar '((x) (fifo '*Q x)) ls)
   ls ) # return list the list
(de q? () (fifo '*Q)) # next value in the queue, or nil

(de +ch () # same as 'q? but also cache result in *ch
   (setq *ch (q?)) )

# -- the matrix ------------------------------------------------
# "matrix" is the official term for the 22 * 10 grid of cells.

(def '*M ()) # matrix

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


# -- registers -------------------------------------------------
# picolisp seems to store associative arrays in a global tree,
# indexed by two keys. The first key seems to selects the list,
# the second key selects the item. We'll use 'R as the key for
# the register list here, but since R itself is juts a symbol
# (not a list) there's no global variable to declare.*
#
# * you don't have have to declare them anyway, but I prefer to.

(de cmd-? () # query a register variable
   (println (or (get 'R (+ch)) 0) ))


# -- command dispatch ------------------------------------------

(de dispatch (Ch)
   (case Ch
      ("?" (cmd-?))
      ("c" (cmd-c))
      ("g" (cmd-g))
      ("p" (cmd-p))
      ("q" (bye)) ) )

(de main ()
   (cmd-c)
   (while (ls>q (line))
      (while (q?)
         (dispatch @) ) ) )
