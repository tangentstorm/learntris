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
   (setq *ch (q?)) *ch)

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

(de %get (reg)
   (or (get 'R (intern reg)) 0) )

(de %set (reg val)
   (put 'R (intern reg) val) )

(de %add (reg amt)
   (%set reg (+ amt (%get reg))) )

(de cmd-? () # query a register variable
   (println (%get (+ch))) )


# -- stepping --------------------------------------------------

(de is-full (Line)
   (not (filter '((x) (= x ".")) Line)) )

(de step! ()
   (setq *M (filter '((x) (not (is-full x))) *M))
   (while (< (length *M) 22)
      (%add '"n" 1) (%add '"s" 100)
      (setq *M (insert 0 *M '(". . . . . . . . . ."))) ) )

(de cmd-s () # step the interpreter
   (step!) )


# -- tetraminos -------------------------------------------------

(put 'Tet 'I
   '(". . . ."
     "c c c c"
     ". . . ."
     ". . . ." ))

(put 'Tet 'O
   '(". y y ."
     ". y y ."
     ". . . ." ))

(put 'Tet 'Z
   '("r r ."
     ". r r"
     ". . ." ))

(put 'Tet 'S
   '(". g g"
     "g g ."
     ". . ." ))

(put 'Tet 'J
   '("b . ."
     "b b b"
     ". . ." ) )

(put 'Tet 'L
   '(". . o"
     "o o o"
     ". . ." ) )

(put 'Tet 'T
   '(". m ."
     "m m m"
     ". . ." ) )

(de cmd-t () # show current tetramino
   (mapc prinl (get 'Tet (get 'Tet '=)) ))


# -- command dispatch ------------------------------------------

(de dispatch (Ch)
   (case Ch
      ("?" (cmd-?))
      ("c" (cmd-c))
      ("g" (cmd-g))
      ("p" (cmd-p))
      ("q" (bye))
      ("s" (cmd-s))
      ("t" (cmd-t))

      ("I" (put 'Tet '= 'I))
      ("O" (put 'Tet '= 'O))
      ("Z" (put 'Tet '= 'Z))
      ("S" (put 'Tet '= 'S))
      ("J" (put 'Tet '= 'J))
      ("L" (put 'Tet '= 'L))
      ("T" (put 'Tet '= 'T))

      ) ) )

(de main ()
   (cmd-c)
   (while (ls>q (line))
      (while (q?)
         (dispatch @) ) ) )
