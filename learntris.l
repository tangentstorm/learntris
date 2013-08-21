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


# -- routines to read and print a grid  ------------------------

(de sym->char (Sym)
   (if (= Sym '-) "." (sym Sym)) )

(de row->str (Row)
   (glue " " (mapcar sym->char Row)) )

(de show-grid (Grid)
   (mapc prinl (mapcar row->str Grid)) )

(de str->row (Str)
   (make
      (for Ch (chop Str)
         (cond
            ((= Ch " "))                # skip spaces
            ((= Ch ".") (link '-))      # dots -> dashes
            (T (link (any Ch))) ) ) ) ) # letters become symbols

# -- the matrix ------------------------------------------------
# "matrix" is the official term for the 22 * 10 grid of cells.

(de *M) # matrix

(de cmd-c () # clear the matrix
   (setq *M (make (do 22 (link '( - - - - - - - - - - ))))) )

(de cmd-g () # given the following matrix...
   (setq *M (make (do 22 (link (str->row (line)))))))

(de cmd-p () # print the matrix
   (show-grid *M) )

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
   (not (member '- Line)) )

(de step! ()
   (setq *M (filter '((x) (not (full? x))) *M))
   (while (< (length *M) 22)
      (%add '"n" 1) (%add '"s" 100)
      (setq *M (insert 0 *M '( - - - - - - - - - - ))) ) )

(de cmd-s () # step the interpreter
   (step!) )


# -- tetraminos -------------------------------------------------

(de *X 0) (de *Y 0) # coordinates of the falling piece

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

(de cmd-t () # show current tetramino
   (show-grid (current-shape)))

(de xy: (X Y)
   (setq *X X)
   (setq *Y Y))

(de set-shape (QuotedChar)
   (put 'Tet '= (get 'Tet QuotedChar))
   (apply xy: # spawn positions for each shape:
      (case QuotedChar
         ("I" (3 0))
         ("O" (4 0))
         ("L" (3 0))
         ("J" (3 0))
         ("S" (3 0))
         ("Z" (3 0))
         ("T" (3 0)) ) ) )

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

# TODO: maprows->for-rows ?
# turns out the function is usually pretty long and Rows
# is usually just a variable name, so it reads better with
# rows coming first. hence find-rows:
(de find-rows (Rows F) (filter '((Row) (apply F Row)) Rows))

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


# -- combined display  -----------------------------------------

(de same-xy (CellA CellB)
   (and
      (= (car  CellB) (car CellA))
      (= (cadr CellA) (cadr CellB)) ) )

(de xyv-with-v (XYV V) # -> new xyv with old xy and new v
   (list (car XYV) (cadr XYV) V))

(de xyv-get-v (XYV) (caddr XYV))

(de xyvs-translate (DX DY XYVs)
   (maprows '((X Y V) (list (+ X DX) (+ Y DY) V))
      XYVs ) )

(de xyvs-upcase (XYVs)
   (maprows '((X Y V) (list X Y (any (uppc V))))
      XYVs ) )

(de nil? (X) (= X NIL))

(de xyvs-solids (G) (find-rows G '((X Y V) (<> V '-))))

(de xyvs->bounds (G) # filter with xyvs-solids first if you don't want empty spaces
   (use (X0 X1 Y0 Y1)
      # extract the first data point as our reference
      (setq X0 (setq X1 (caar G)))
      (setq Y0 (setq Y1 (cadar G)))
      (maprows
         '((X Y V)
           (when (< X X0) (setq X0 X))
           (when (< Y Y0) (setq Y0 Y))
           (when (> X X1) (setq X1 X))
           (when (> Y Y1) (setq Y1 Y)) )
         G)
      (list X0 Y0 X1 Y1) ) )

(de xyvs-clip (bounds xyvs)
   (let (X0 (pop 'bounds)
         Y0 (pop 'bounds)
         X1 (pop 'bounds)
         Y1 (pop 'bounds))
      (find-rows xyvs
         '((X Y V) (and
                      (>= X X0) (<= X X1)
                      (>= Y Y0) (<= Y Y1) ) ) ) ) )

(de xyvs-update (DstData SrcData) # in xyv format
   (make
      (use (SrcQ Dst DstQ Src)
         (apply fifo (sort-by-yx
                        (xyvs-clip (xyvs->bounds DstData) SrcData) ) 'SrcQ )
         (apply fifo (sort-by-yx DstData) 'DstQ)
         (setq Src (fifo 'SrcQ))
         (while (setq Dst (fifo 'DstQ))
            (if (nil? Src)
               (link Dst)
               (if (same-xy Src Dst)
                  (prog
                     (link Src)
                     (setq Src (fifo 'SrcQ)) )
                  (link Dst) ) ) ) ) ) )

(de cmd-print-combined () # print the matrix with the current shape
   (show-grid
      (xyvs->pic
         (xyvs-update
            (pic->xyvs *M)
            (xyvs-translate *X *Y
               (xyvs-upcase
                  (pic->xyvs (current-shape)) ) ) ) ) ) )

# -- movement  -------------------------------------------------

(de grid-width (G)
   (apply '((X0 Y0 X1 Y1) (- X1 X0))
      (xyvs->bounds G)))

(de nudge-< ()
   (setq *X (max (- *X 1) 0)))

(de nudge-> ()
   (setq *X (min (+ *X 1)
               (- 9 (grid-width
                       (xyvs-solids
                          (pic->xyvs (current-shape)) ) ) ) ) ) )

(de nudge-v ()
   (setq *Y (min (+ *Y 1) 21)))


# -- command dispatch ------------------------------------------

(de dispatch (Ch)
   (case Ch
      ("?" (cmd-?))
      ("c" (cmd-c))
      ("g" (cmd-g))
      ("p" (cmd-p))
      ("P" (cmd-print-combined))
      ("q" (bye))
      ("s" (cmd-s))
      ("t" (cmd-t))
      ("<" (nudge-<))
      (">" (nudge->))
      ("v" (nudge-v))
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
