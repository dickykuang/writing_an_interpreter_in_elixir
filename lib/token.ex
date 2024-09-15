defmodule WritingAnInterpreterInElixir.Token do
  alias WritingAnInterpreterInElixir.Lexer
  @type token_type :: atom()

  @type t :: %__MODULE__{
          type: token_type(),
          literal: String.t()
        }
  defstruct [:type, :literal]

  @spec from_lexer(Lexer.t()) :: __MODULE__.t()
  # ASCII for '='
  def from_lexer(%Lexer{ch: ?=} = lexer) do
    {token, updated_lexer} =
      case Lexer.peek_char(lexer) do
        ?= ->
          {%__MODULE__{
             literal: "==",
             type: :eq
           }, Lexer.read_char(lexer)}

        _ ->
          {%__MODULE__{
             literal: "=",
             type: :assign
           }, lexer}
      end

    {token, Lexer.read_char(updated_lexer)}
  end

  # ASCII for ';'
  def from_lexer(%Lexer{ch: ?;} = lexer) do
    token = %__MODULE__{
      literal: ";",
      type: :semicolon
    }

    {token, Lexer.read_char(lexer)}
  end

  # ASCII for '('
  def from_lexer(%Lexer{ch: ?(} = lexer) do
    token = %__MODULE__{
      literal: "(",
      type: :lparen
    }

    {token, Lexer.read_char(lexer)}
  end

  # ASCII for ')'
  def from_lexer(%Lexer{ch: ?)} = lexer) do
    token = %__MODULE__{
      literal: ")",
      type: :rparen
    }

    {token, Lexer.read_char(lexer)}
  end

  # ASCII for ','
  def from_lexer(%Lexer{ch: ?,} = lexer) do
    token = %__MODULE__{
      literal: ",",
      type: :comma
    }

    {token, Lexer.read_char(lexer)}
  end

  # ASCII for '+'
  def from_lexer(%Lexer{ch: ?+} = lexer) do
    token = %__MODULE__{
      literal: "+",
      type: :plus
    }

    {token, Lexer.read_char(lexer)}
  end

  # ASCII for '{'
  def from_lexer(%Lexer{ch: ?{} = lexer) do
    token = %__MODULE__{
      literal: "{",
      type: :lbrace
    }

    {token, Lexer.read_char(lexer)}
  end

  # ASCII for '}'
  def from_lexer(%Lexer{ch: ?}} = lexer) do
    token = %__MODULE__{
      literal: "}",
      type: :rbrace
    }

    {token, Lexer.read_char(lexer)}
  end

  def from_lexer(%Lexer{ch: ?-} = lexer) do
    token = %__MODULE__{
      literal: "-",
      type: :minus
    }

    {token, Lexer.read_char(lexer)}
  end

  def from_lexer(%Lexer{ch: ?!} = lexer) do
    {token, updated_lexer} =
      case Lexer.peek_char(lexer) do
        ?= ->
          {%__MODULE__{
             literal: "!=",
             type: :not_eq
           }, Lexer.read_char(lexer)}

        _ ->
          {%__MODULE__{
             literal: "!",
             type: :bang
           }, lexer}
      end

    {token, Lexer.read_char(updated_lexer)}
  end

  def from_lexer(%Lexer{ch: ?/} = lexer) do
    token = %__MODULE__{
      literal: "/",
      type: :slash
    }

    {token, Lexer.read_char(lexer)}
  end

  def from_lexer(%Lexer{ch: ?*} = lexer) do
    token = %__MODULE__{
      literal: "*",
      type: :asterisk
    }

    {token, Lexer.read_char(lexer)}
  end

  def from_lexer(%Lexer{ch: ?<} = lexer) do
    token = %__MODULE__{
      literal: "<",
      type: :lt
    }

    {token, Lexer.read_char(lexer)}
  end

  def from_lexer(%Lexer{ch: ?>} = lexer) do
    token = %__MODULE__{
      literal: ">",
      type: :gt
    }

    {token, Lexer.read_char(lexer)}
  end

  # when ch is a space, tab, newline or return character, skip
  def from_lexer(%Lexer{ch: ch} = lexer) when ch in [?\s, ?\t, ?\n, ?\r] do
    new_lexer = Lexer.read_char(lexer)
    {nil, new_lexer}
  end

  # when ch is a digit
  def from_lexer(%Lexer{ch: ch} = lexer) when ch in ?0..?9 do
    {number, new_lexer} = read_number(lexer)

    token = %__MODULE__{
      literal: number,
      type: :int
    }

    {token, new_lexer}
  end

  # when ch is a letter
  def from_lexer(%Lexer{ch: ch} = lexer) when ch in ?a..?z or ch in ?A..?Z or ch == ?_ do
    {identifier, new_lexer} = read_identifier(lexer)

    token = %__MODULE__{
      literal: identifier,
      type: token_type_by_identifier(identifier)
    }

    {token, new_lexer}
  end

  def from_lexer(%Lexer{ch: 0} = lexer) do
    token = %__MODULE__{
      literal: "",
      type: :eof
    }

    {token, Lexer.read_char(lexer)}
  end

  def from_lexer(%Lexer{ch: ch} = lexer) do
    token = %__MODULE__{
      literal: <<ch>>,
      type: :illegal
    }

    {token, Lexer.read_char(lexer)}
  end

  defp read_identifier(lexer) do
    read_identifier(lexer, [])
  end

  defp read_identifier(%Lexer{ch: ch} = lexer, acc)
       when ch in ?a..?z or ch in ?A..?Z or ch == ?_ do
    read_identifier(Lexer.read_char(lexer), [ch | acc])
  end

  defp read_identifier(lexer, acc) do
    identifier = acc |> Enum.reverse() |> List.to_string()
    {identifier, lexer}
  end

  defp read_number(lexer) do
    read_number(lexer, [])
  end

  defp read_number(%Lexer{ch: ch} = lexer, acc) when ch in ?0..?9 do
    read_number(Lexer.read_char(lexer), [ch | acc])
  end

  defp read_number(lexer, acc) do
    identifier = acc |> Enum.reverse() |> List.to_string()
    {identifier, lexer}
  end

  defp token_type_by_identifier(identifier) do
    case %{
           "let" => :let,
           "fn" => :function,
           "true" => true,
           "false" => false,
           "if" => :if,
           "else" => :else,
           "return" => :return
         }
         |> Map.get(identifier) do
      nil -> :ident
      type -> type
    end
  end

  def print(%__MODULE__{} = token) do
    IO.puts("Type: {#{token.type}, Literal: #{token.literal}")
  end
end
