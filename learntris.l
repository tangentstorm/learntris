# learntris implementation in picolisp

(de print-matrix ()
   (for Row 22
      (prinl ". . . . . . . . . .")))

(de handle (Ch)
   (case Ch
      ("p" (print-matrix))
      ("q" (bye)) ) )

(de mapstr (F Sym)
   (mapcar F (str Sym)) )

(de main ()
   (while (str (line))
      (mapstr handle @)))
