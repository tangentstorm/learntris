defmodule Elixtris do
  # A learntris implementation in elixir, by michal j wallace (http://tangentstorm.com)
  #
  # type Cmd = state -> state
  # 's0' refers to the game state at start of the function

  def initial_state do
    %{ matrix: for _ <- 0..21 do empty_row end,
       score: 0,
       numLines: 0,
       tx: 0, ty: 0,
       tetramino: ['....', 'cccc', '....', '....'] }
  end

  # -- helper routines ---

  def empty_row, do: '..........'

  # respace :: str -> str  -- add a space after each character.
  def respace(''), do: ''
  def respace([h|t]), do: [h|[32|respace t]]

  # blend: str,str,int->str  -- overwrite bg str with fg at position.
  def blend(fg, bg) do
    Enum.join(for {f,b} <-Enum.zip(fg,bg) do [if [f]=='.' do b else f end] end)
  end

  # stamp/3 :: chr, chr, int -> chr
  def stamp(fg, bg, x) do
    len = Enum.count fg
    Enum.join([Enum.take(bg,x),
               blend(fg, Enum.slice(bg, x..(x+len))),
               Enum.drop(bg, x+len)])
    |> String.to_char_list
  end

  # stamp/4 :: (grid, grid, int,int)->grid -- stamp fg onto bg at (x,y) (2d version)
  def stamp(fg, bg, x, y) do
    Enum.concat [Enum.take(bg, y),
                for {f, b} <- Enum.zip(fg, Enum.drop(bg, y)) do
                  (stamp f, b, x)
                end,
                Enum.drop(bg, y+Enum.count fg)]
  end

  # clockwise rotation is the reverse of the transpose for a 2d list
  # (the reverse here happens implictly in the accumulator)
  def clockwise(grid) do
    init = for _ <- List.first(grid) do [] end
    Enum.reduce grid, init, fn (row, cols) ->
      for {col, val} <- Enum.zip(cols, row), do: [val|col]
    end
  end

  # print :: grid -> ()
  def print(grid) do
    for row <- grid, do: row |> respace |> IO.puts
  end

  # given :: Cmd
  # reads the matrix from stdin
  def given(s0) do
    %{ s0 | matrix:
              for _ <- 0..21 do
                IO.gets("")
                |> String.replace(" ", "")
                |> String.rstrip
                |> String.to_char_list
              end }
  end

  # query :: state, [char] -> [char]
  def query(s0, [ch|buf]) do
    case [ch] do
      'n' -> IO.puts s0.numLines
      's' -> IO.puts s0.score
      _ -> raise "invalid character after '?': " ++ ch
    end
    buf
  end

  def upcase(grid) do
    for row <- grid do row |> List.to_string |> String.upcase |> String.to_char_list end
  end

  # step :: Cmd
  # Clears out full rows and updates the score and line count registers.
  def step(s0) do
    { m1, s1, n1 } = Enum.reduce(s0.matrix, {[], s0.score, s0.numLines},
      fn(row, {rows, s, n}) ->
        if List.to_string(row) |> String.contains?(".")
          do {[row|rows], s, n}
          else {[empty_row|rows], s+100, n+1}
        end
      end)
    %{ s0 | matrix: Enum.reverse(m1), score: s1, numLines: n1 }
  end

  # io :: state, input-buffer -> ()
  # Handles command dispatch.

  def io(s0, '') do
    io s0, (IO.gets('') |> String.to_char_list) # refill the command buffer
  end

  def io(s0, [ch|buf]) do
    s1 = case [ch] do
           'p' -> print s0.matrix; s0
           'g' -> given s0
           'c' -> initial_state
           's' -> step s0
           '?' -> buf = query s0, buf; s0
           't' -> print s0.tetramino; s0
           'O' -> %{s0 | tetramino: ['yy', 'yy'], tx: 4,  ty: 0 }
           'Z' -> %{s0 | tetramino: ['rr.', '.rr', '...'], tx: 3, ty: 0 }
           'S' -> %{s0 | tetramino: ['.gg', 'gg.', '...'], tx: 3, ty: 0 }
           'J' -> %{s0 | tetramino: ['b..', 'bbb', '...'], tx: 3, ty: 0 }
           'L' -> %{s0 | tetramino: ['..o', 'ooo', '...'], tx: 3, ty: 0 }
           'T' -> %{s0 | tetramino: ['.m.', 'mmm', '...'], tx: 3, ty: 0 }
           'I' -> %{s0 | tetramino: ['....', 'cccc', '....', '....'], tx: 3, ty: 0 }
           ')' -> %{s0 | tetramino: clockwise s0.tetramino }
           ';' -> IO.puts ''; s0
           'P' -> print (stamp (upcase s0.tetramino), s0.matrix, s0.tx, s0.ty); s0
           _   -> s0 # no change
         end
    unless [ch]=='q', do: io s1, buf
  end

  # main :: ()->()  create initial state and launch io loop
  def main(), do: io initial_state, ''

end
Elixtris.main
