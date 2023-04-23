defmodule Cardashian.Card do
  @enforce_keys [:suit, :face]

  @default_suits [
    clubs: "♠",
    diamonds: "️♦️",
    hearts: "♥️",
    spades: "♣"
  ]

  defstruct [:id, :deck_id, :suit, :face, :symbol, visibility: :back]

  def new(attrs) do
    __MODULE__
    |> struct!(attrs)
    |> Map.put(:id, :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower))
    |> Map.put(:symbol, Keyword.get(@default_suits, attrs[:suit]))
  end

  def flip(%__MODULE__{visibility: :back} = card), do: struct(card, visibility: :front)
  def flip(%__MODULE__{visibility: :front} = card), do: struct(card, visibility: :back)
end

defimpl Inspect, for: Cardashian.Card do
  import Inspect.Algebra

  def inspect(card, _opts) do
    concat([
      "#Card<",
      to_string(card.id),
      ": ",
      to_string(card.symbol),
      to_string(card.face),
      ">"
    ])
  end
end
