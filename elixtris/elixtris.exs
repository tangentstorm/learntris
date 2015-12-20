defmodule Elixtris do
  # A learntris implementation in elixir, by michal j wallace (http://tangentstorm.com)
  #
  # type Cmd = state -> state
  # 's0' refers to the game state at start of the function

  # print :: Cmd
  # print the state of the matrix

  def print(s0) do
    { matrix, score, numLines } = s0
    for line <- matrix, do: IO.puts line
    s0
  end


  def empty_row, do: '. . . . . . . . . .'
  def initial_state do
    { for _ <- 0..21 do empty_row end, 0, 0 }
  end

  # given :: Cmd
  # reads the matrix from stdin

  def given({ m, s, n }) do
    { for _ <- 0..21 do IO.gets("") |> String.rstrip |> String.to_char_list end, s, n }
  end

  # query :: state, [char] -> [char]
  def query(s0, [ch|buf]) do
    { m, n, s } = s0
    case [ch] do
      'n' -> IO.puts n
      's' -> IO.puts s
      _ -> raise "invalid character after '?': " ++ ch
    end
    buf
  end

  # step :: Cmd
  def step(s0) do
    { m0, s, n } = s0
    m1 = for row <- m0 do
      # clear empty rows and update the score and number of cleared rows
      if List.to_string(row) |> String.contains?(".")
        do n = n + 1; s = s + 1; row
        else empty_row
      end
    end
    { m1, s, n }
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
