defmodule FallblattCore.Segment do
  defstruct position: nil,
            flaps: nil,
            letters: nil,
            address: nil,
            offset: nil

  @type t :: %__MODULE__{
          position: non_neg_integer(),
          address: non_neg_integer(),
          flaps: non_neg_integer(),
          letters: %{color() => letter_list()}
        }
  @type color :: atom()
  @type flap_position :: non_neg_integer()
  @type letter_list :: %{char() => flap_position()}
  @type by_position :: %{non_neg_integer() => t()}

  defmacro defsegment(opts) do
    position = Keyword.fetch!(opts, :position)
    letters = Keyword.fetch!(opts, :letters)
    address = Keyword.fetch!(opts, :address)
    offset = Keyword.get(opts, :offset, 0)
    flaps = Keyword.get(opts, :flaps, 52)

    quote do
      @segments %unquote(__MODULE__){
        position: unquote(position),
        # Assert that all letter maps have the right size
        letters:
          unquote(letters)
          |> Enum.map(fn {color, {unquote(flaps), letters}} -> {color, letters} end)
          |> Enum.into(%{}),
        address: unquote(address),
        offset: unquote(offset),
        flaps: unquote(flaps)
      }
    end
  end

  @doc """
    Fallblatt encoding for defining the letters,
    returns a map with the letter and the position in the letter drum.
    Spaces are ommited.
    Returns a tuple of length and map
    ~FB" ab c" -returns-> {5, %{?a => 1, ?b => 2, ?c => 4}}
  """
  @spec sigil_FB(binary(), []) :: {non_neg_integer(), letter_list()}
  def sigil_FB(binary, []) do
    binary
    |> to_charlist()
    |> Enum.with_index()
    # Drop all spaces
    |> Enum.reject(&match?({?\s, _}, &1))
    |> Enum.into(%{})
    |> then(&{String.length(binary), &1})
  end

  # Extend the rem/2 function to handle negative dividend
  defp mod(dividend, divisor) when dividend < 0, do: mod(dividend + divisor, divisor)
  defp mod(dividend, divisor), do: rem(dividend, divisor)

  @doc """
    Looks up the position of a flap within a segment while accounting for the offset
    Example:
    %Segment{..., offset: 0}, {:white, ?A} -> 20
    %Segment{..., offset: 1}, {:white, ?A} -> 21
  """
  @spec lookup(t(), {color(), char()}) :: nil | non_neg_integer()
  def lookup(%__MODULE__{flaps: flaps, letters: letters, offset: offset}, {color, char}) do
    with %{} = map <- Map.get(letters, color) do
      case Map.get(map, char) do
        pos when is_integer(pos) -> mod(pos + offset, flaps)
        nil -> nil
      end
    else
      nil -> nil
    end
  end
end
