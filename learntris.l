# learntris implementation in picolisp
# copyright (c) 2013 by michal j wallace.
# this code is available under the MIT/X11 license.
# http://github.com/learnprogramming/learntris/

# -- the input queue -------------------------------------------

(de *Q)  # input queue
(de *ch  "") # current char

(de ls>q (Ls) # copy items in list to global queue
   (apply fifo Ls '*Q)) # then it returns the list

(de q? () (fifo '*Q)) # next value in the queue, or nil

(de +ch () # same as 'q? but also cache result in *ch
   (setq *ch (q?)) *ch)

# -- the matrix ------------------------------------------------
# "matrix" is the official term for the 22 * 10 grid of cells.

(de *M) # matrix

(de cmd-c () # clear the matrix
   (setq *M ())
   (do 22
      (setq *M (append *M '(". . . . . . . . . ."))) ) )

(de cmd-g () # given the following matrix...
   (setq *M ())
   (do 22
      (setq *M (append *M (list (line)))) ) )

(de cmd-p () # print the matrix
   (mapc prinl *M) )


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

(de full? (Line)
   (not (member "." Line)) )

(de step! ()
   (setq *M (filter '((x) (not (full? x))) *M))
   (while (< (length *M) 22)
      (%add '"n" 1) (%add '"s" 100)
      (setq *M (insert 0 *M '(". . . . . . . . . ."))) ) )

(de cmd-s () # step the interpreter
   (step!) )


# -- tetraminos -------------------------------------------------

(put 'Tet 'I
   '(( - - - - )
     ( c c c c )
     ( - - - - )
     ( - - - - )))

(put 'Tet 'O
   '(( y y )
     ( y y )))

(put 'Tet 'Z
   '(( r r - )
     ( - r r )
     ( - - - )))

(put 'Tet 'S
   '(( - g g )
     ( g g - )
     ( - - - )))

(put 'Tet 'J
   '(( b - - )
     ( b b b )
     ( - - - )))

(put 'Tet 'L
   '(( - - o )
     ( o o o )
     ( - - - )))

(put 'Tet 'T
   '(( - m - )
     ( m m m )
     ( - - - )))

(de sym->char (Sym)
   (if (= Sym '-) "." (sym Sym)) )

(de row->str (Row)
   (glue " " (mapcar sym->char Row)))


(de cmd-t () # show current tetramino
   (mapc prinl
      (mapcar row->str (current-shape)) ) )

(de set-shape (QuotedChar)
   (put 'Tet '= (get 'Tet QuotedChar)) )

(de current-shape ()
   (get 'Tet '=) )


# -- grid rotations --------------------------------------------
#
# "pic" is the 2d list format used above
#
# ex: '((- m -)
#       (m m m)
#       (- - -))
#
# "xyv" is a list of (x y value) triples:
#
# ex: '((0 0 -) (1 0 m) (2 0 -)
#       (0 1 m) (1 1 m) (2 1 m)
#       (0 2 -) (1 2 -) (2 2 -))

(de row->xyv (Row Y W)
   (make
      (setq X -1)
      (for Val Row
         (link (list (inc 'X) Y Val)) ) ) )

(de pic->xyvs (Pic)
   (make 
      (setq Y -1)
      (for Row Pic
         (chain (row->xyv Row (inc 'Y))) ) ) )

(de sort-by-yx (XYVs) # sort by y, then by x
   (by cadr sort (by car sort XYVs)))
(de xyv->yxv (XYV)
   (apply '((X Y V) (list Y X V)) XYV))
(de group-by-y (XYVs) # [(X Y V)] -> [(Y [(X V)])]
   (group (mapcar 'xyv->yxv XYVs) ))
(de xyvs->pic (XYVs)
   (make
      (let (Groups (group-by-y (sort-by-yx XYVs)))
         (for Row Groups
            # cdr to strip Y, map cadr to extract vals
            (link (mapcar cadr (cdr Row))) ) ) ) )


(de maprows (F Rows) (mapcar '((Row) (apply F Row)) Rows))

(de anticlock (Pic) # -> Pic'
   (let (W (length (car Pic)))
      (xyvs->pic
         (maprows
            '((X Y V) (list Y (- W X 1) V))
            (pic->xyvs Pic) ) ) ) )

(de clockwise (Pic) # kind of just a hack for now, but it'll do :)
   (anticlock (anticlock (anticlock Pic))) )

(de cmd-rotate-clockwise ()
   (put 'Tet '= (clockwise (current-shape))))
(de cmd-rotate-anticlock ()
   (put 'Tet '= (anticlock (current-shape))))

(de print-eval ARGS # prints each argument, followed by the result of evaluating it
   (for q ARGS
      (println '-> q)
      (println (eval q)) ) )

(de test-rotation ()
   (set-shape 'T)
   (print-eval
      (current-shape)
      (setq DATA (pic->xyvs (current-shape)))
      (xyvs->pic DATA)
      (sort-by-yx (pic->xyvs (current-shape)))
      (group-by-y (sort-by-yx (pic->xyvs (current-shape))))
      (clockwise (current-shape)) ) )

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
      (";" (prinl ""))

      (")" (cmd-rotate-clockwise))
      ("(" (cmd-rotate-anticlock))

      ("I" (set-shape 'I))
      ("O" (set-shape 'O))
      ("Z" (set-shape 'Z))
      ("S" (set-shape 'S))
      ("J" (set-shape 'J))
      ("L" (set-shape 'L))
      ("T" (set-shape 'T))
 ) )

(de main ()
   (set-shape 'T)
   (cmd-c)
   (while (ls>q (line))
      (while (q?)
         (dispatch @) ) ) )
