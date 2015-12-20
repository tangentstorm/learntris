defmodule Elixtris do
  # A learntris implementation in elixir, by michal j wallace (http://tangentstorm.com)
  #
  # type Cmd = state -> state
  # 's0' refers to the game state at start of the function

  def empty_row, do: '. . . . . . . . . .'
  def initial_state do
    %{ matrix: for _ <- 0..21 do empty_row end,
       score: 0,
       numLines: 0,
       tetramino: ['. . . . ', 'c c c c ', '. . . . ', '. . . . ']}
  end

  # print :: Cmd
  # print the state of the matrix

  def print(s0) do
    for line <- s0.matrix, do: IO.puts line
    s0
  end

  # print_tetramino :: Cmd
  # print the state of the active tetramino

  def print_tetramino(s0) do
    Enum.map(s0.tetramino, &IO.puts/1)
    s0
  end

  # given :: Cmd
  # reads the matrix from stdin

  def given(s0) do
    %{ s0 | matrix: for _ <- 0..21 do IO.gets("") |> String.rstrip |> String.to_char_list end }
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
           'p' -> print s0
           'g' -> given s0
           'c' -> initial_state
           's' -> step s0
           '?' -> buf = query s0, buf; s0
           't' -> print_tetramino s0
           'O' -> %{s0 | tetramino: ['y y ', 'y y ']}
           'Z' -> %{s0 | tetramino: ['r r . ', '. r r ', '. . . ']}
           'S' -> %{s0 | tetramino: ['. g g ', 'g g . ', '. . . ']}
           'J' -> %{s0 | tetramino: ['b . . ', 'b b b ', '. . . ']}
           'L' -> %{s0 | tetramino: ['. . o ', 'o o o ', '. . . ']}
           'T' -> %{s0 | tetramino: ['. m . ', 'm m m ', '. . . ']}
           _   -> s0 # no change
         end
    unless [ch]=='q', do: io s1, buf
  end

  # main :: ()->()  create initial state and launch io loop
  def main(), do: io initial_state, ''

end
Elixtris.main
