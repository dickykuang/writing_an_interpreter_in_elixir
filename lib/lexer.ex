defmodule WritingAnInterpreterInElixir.Lexer do
  alias WritingAnInterpreterInElixir.Token

  @type t :: %__MODULE__{
          input: String.t(),
          position: non_neg_integer(),
          read_position: non_neg_integer(),
          ch: String.t() | nil | 0,
          input_length: non_neg_integer()
        }
  defstruct [:input, :ch, input_length: 0, position: 0, read_position: 0]

  @type input :: String.t()
  @doc """
  Creates a new Lexer struct

  ## Examples

      iex> WritingAnInterpreterInElixir.Lexer.new("{*}")
      %WritingAnInterpreterInElixir.Lexer{
        input: ~c"{*}",
        position: 0,
        read_position: 1,
        input_length: 3,
        ch: 123
      }

  """
  @spec new(input()) :: __MODULE__.t()
  def new(input) do
    char_list = String.to_charlist(input)

    %__MODULE__{input: char_list, input_length: length(char_list)}
    |> read_char()
  end

  @spec next_token(__MODULE__.t()) :: {Token.t(), __MODULE__.t()}
  def next_token(lexer) do
    case Token.from_lexer(lexer) do
      {nil, updated_lexer} ->
        next_token(updated_lexer)

      {lexer, token} ->
        {token, lexer}
    end
  end

  @spec read_char(__MODULE__.t()) :: __MODULE__.t()
  def read_char(%__MODULE__{read_position: read_position, input_length: input_length} = lexer)
      when read_position >= input_length do
    lexer
    |> set_ch()
    |> set_position(lexer.read_position)
    |> set_read_position(lexer.read_position + 1)
  end

  def read_char(%__MODULE__{} = lexer) do
    lexer
    |> set_ch(lexer.read_position)
    |> set_position(lexer.read_position)
    |> set_read_position(lexer.read_position + 1)
  end

  def peek_char(%__MODULE__{read_position: read_position, input_length: input_length} = _lexer)
      when read_position >= input_length do
    0
  end

  def peek_char(%__MODULE__{} = lexer) do
    Enum.at(lexer.input, lexer.read_position)
  end

  defp set_ch(%__MODULE__{} = lexer) do
    %{lexer | ch: 0}
  end

  defp set_ch(%__MODULE__{} = lexer, position) do
    %{lexer | ch: Enum.at(lexer.input, position)}
  end

  defp set_position(%__MODULE__{} = lexer, position) do
    %{lexer | position: position}
  end

  defp set_read_position(%__MODULE__{} = lexer, read_position) do
    %{lexer | read_position: read_position}
  end
end
