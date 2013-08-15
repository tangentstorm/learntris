# learntris implementation in picolisp

(de print-matrix ()
   (for Row 22
      (prinl ". . . . . . . . . .")))

(de dispatch (Ch)
   (case Ch
      ("p" (print-matrix))
      ("q" (bye))))

(de main ()
   (while (str (line))
      (mapcar dispatch (str @))))
