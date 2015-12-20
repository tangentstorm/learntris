defmodule Elixtris do
  # A learntris implementation in elixir, by michal j wallace (http://tangentstorm.com)
  #
  # type Cmd = state -> state
  # 's0' refers to the game state at start of the function

  def empty_row, do: '. . . . . . . . . .'
  def initial_state do
    { for _ <- 0..21 do empty_row end, 0, 0 }
  end

  # print :: Cmd
  # print the state of the matrix

  def print(s0) do
    { matrix, score, numLines } = s0
    for line <- matrix, do: IO.puts line
    s0
  end

  # given :: Cmd
  # reads the matrix from stdin

  def given({ m, s, n }) do
    { for _ <- 0..21 do IO.gets("") |> String.rstrip |> String.to_char_list end, s, n }
  end

  # query :: state, [char] -> [char]
  def query(s0, [ch|buf]) do
    { m, s, n } = s0
    case [ch] do
      'n' -> IO.puts n
      's' -> IO.puts s
      _ -> raise "invalid character after '?': " ++ ch
    end
    buf
  end

  # step :: Cmd
	# Clears out full rows and updates the score and line count registers.
  def step(state0) do
    { m0, s0, n0 } = state0
    { m1, s1, n1 } = Enum.reduce m0, {[], s0, n0}, fn(row, {rows, s, n}) ->
      if List.to_string(row) |> String.contains?(".")
        do {[row|rows], s, n}
        else {[empty_row|rows], s+100, n+1}
      end
    end
    { Enum.reverse(m1), s1, n1 }
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
           _   -> s0 # no change
         end
    unless [ch]=='q', do: io s1, buf
  end

  # main :: ()->()  create initial state and launch io loop
  def main(), do: io initial_state, ''

end
Elixtris.main
