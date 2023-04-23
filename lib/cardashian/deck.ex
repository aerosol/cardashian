defmodule Cardashian.Deck do
  alias Cardashian.Card

  @suits [:hearts, :spades, :clubs, :diamonds]
  @symbols ["♥️", "♣", "♠", "️♦️"]
  @faces Enum.to_list(2..10) ++ [:jack, :queen, :king, :ace]

  @enforce_keys [:suits, :faces, :symbols]
  defstruct id: nil,
            cards: [],
            original_size: nil,
            suits: @suits,
            symbols: @symbols,
            faces: @faces

  def new(attrs \\ %{suits: @suits, faces: @faces, symbols: @symbols}) do
    deck =
      __MODULE__
      |> struct!(attrs)
      |> Map.put(:id, :crypto.strong_rand_bytes(10) |> Base.encode16(case: :lower))

    cards_on_deck =
      for {suit, symbol} <- Enum.zip(deck.suits, deck.symbols), face <- deck.faces do
        Card.new(deck_id: deck.id, suit: suit, face: face, symbol: symbol)
      end

    deck
    |> Map.put(:cards, cards_on_deck)
    |> Map.put(:original_size, length(cards_on_deck))
  end

  def count(%__MODULE__{} = deck) do
    length(deck.cards)
  end

  def shuffle(%__MODULE__{} = deck) do
    Map.put(deck, :cards, Enum.shuffle(deck.cards))
  end

  def find(%__MODULE__{} = deck, %Card{} = card) do
    find(deck, Map.from_struct(card))
  end

  def find(%__MODULE__{} = deck, attrs) do
    attrs = Enum.into(attrs, %{})

    Enum.filter(deck.cards, fn card ->
      Map.take(card, Map.keys(attrs)) == attrs
    end)
  end

  def peek(%__MODULE__{} = deck, take_from \\ :top, n \\ 1)
      when take_from in [:top, :bottom, :random] do
    case take_from do
      :top ->
        Enum.take(deck.cards, -n)

      :bottom ->
        Enum.take(deck.cards, n)

      :random ->
        deck.cards |> Enum.shuffle() |> Enum.take(n)
    end
  end

  def remove(%__MODULE__{} = deck, card_or_cards) do
    card_or_cards = List.wrap(card_or_cards)

    Enum.reduce_while(card_or_cards, deck, fn card, deck ->
      if Enum.find(deck.cards, &(&1 == card)) do
        {:cont, %{deck | cards: deck.cards -- [card]}}
      else
        {:halt, :error}
      end
    end)
  end

  def return(%__MODULE__{} = deck, card_or_cards, at \\ :top) do
    card_or_cards = List.wrap(card_or_cards)

    case at do
      :top ->
        Map.put(deck, :cards, deck.cards ++ card_or_cards)

      :bottom ->
        Map.put(deck, :cards, card_or_cards ++ deck.cards)

      :random ->
        Enum.reduce(card_or_cards, deck, fn card, deck ->
          cards = List.insert_at(deck.cards, Enum.random(0..length(deck.cards)), card)
          %{deck | cards: cards}
        end)
    end
  end
end

defimpl Inspect, for: Cardashian.Deck do
  import Inspect.Algebra

  def inspect(deck, opts) do
    concat([
      "#Deck(",
      to_string(deck.original_size),
      ")<",
      deck.id,
      ": ",
      to_doc(deck.cards, opts),
      ">"
    ])
  end
end
