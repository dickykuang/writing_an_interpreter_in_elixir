defmodule WritingAnInterpreterInElixir.REPL do
  alias WritingAnInterpreterInElixir.Lexer
  alias WritingAnInterpreterInElixir.Token
  @prompt ">> "

  def start do
    IO.puts("Welcome to the Monkey REPL. Type 'exit' to quit.")
    loop()
  end

  defp loop do
    input = IO.gets(@prompt)

    case String.trim(input) do
      "exit" ->
        IO.puts("Goodbye!")

      line ->
        lexer = Lexer.new(line)
        tokenize(lexer)
        loop()
    end
  end

  defp tokenize(lexer) do
    case Lexer.next_token(lexer) do
      {lexer, %Token{type: :illegal}} ->
        lexer

      {lexer, %Token{type: :eof}} ->
        lexer

      {lexer, %Token{} = token} ->
        Token.print(token)
        tokenize(lexer)
    end
  end
end
