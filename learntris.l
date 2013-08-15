# learntris implementation in picolisp

# *M : the matrix (official term for the 22 * 10 grid)
(def '*M ())

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

(de dispatch (Ch)
   (case Ch
      ("c" (cmd-c))
      ("g" (cmd-g))
      ("p" (cmd-p))
      ("q" (bye)) ) )

(de main ()
   (cmd-c)
   (while (str (line))
      (mapcar dispatch (str @)) ) )
