defmodule Elixtris do
  # A learntris implementation in elixir, by michal j wallace (http://tangentstorm.com)
  #
  # type Cmd = state -> state
  # 's0' refers to the game state at start of the function

  # print :: Cmd
  # print the state of the matrix

  def print(s0) do
    { matrix } = s0
    for line <- matrix, do: IO.puts line
    s0
  end

  def initial_state do
    { for _ <- 0..21 do '. . . . . . . . . .' end }
  end

  # given :: Cmd
  # reads the matrix from stdin

  def given(_) do
    { for _ <- 0..21 do IO.gets("") |> String.rstrip end }
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
           _   -> s0 # no change
         end
    unless [ch]=='q', do: io s1, buf
  end

  # main :: ()->()  create initial state and launch io loop
  def main(), do: io initial_state, ''

end
Elixtris.main
