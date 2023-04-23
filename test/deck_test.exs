defmodule DeckTest do
  use ExUnit.Case

  alias Cardashian.Deck

  test "new deck has 52 cards by default" do
    deck = Deck.new()
    assert length(deck.cards) == 52
    assert Enum.all?(deck.cards, &is_atom(&1.suit))
    assert Enum.all?(deck.cards, &(not is_nil(&1.face)))
  end

  test "multiple cards can be found in deck by a single attr" do
    deck = Deck.new()

    kings = Deck.find(deck, face: :king)
    assert length(kings) == 4
    assert Enum.all?(kings, &(&1.face == :king))
    suits = Enum.map(kings, & &1.suit)
    assert :diamonds in suits
    assert :hearts in suits
    assert :clubs in suits
    assert :spades in suits
  end

  test "a single cart can be found in deck by face and suit" do
    deck = Deck.new()
    [queen_of_hearts] = Deck.find(deck, face: :queen, suit: :hearts)
    assert queen_of_hearts.face == :queen
    assert queen_of_hearts.suit == :hearts
    assert queen_of_hearts.symbol
  end

  test "a card can be peeked from the top of the deck (cards are facing down)" do
    deck = Deck.new()
    [card] = Deck.peek(deck)
    [^card] = Deck.peek(deck)

    assert card == List.last(deck.cards)
  end

  test "a card can be peeked from the bottom of the deck (cards are facing down)" do
    deck = Deck.new()
    [card] = Deck.peek(deck, :bottom)

    assert card == List.first(deck.cards)
  end

  test "card can be peeked randomly" do
    deck = Deck.new()
    assert [card] = Deck.peek(deck, :random)
    assert card.face
  end

  test "multiple cards can be peeked from top (cards are facing down)" do
    deck = Deck.new()
    assert [c1, c2, c3] = Deck.peek(deck, :top, 3)
    assert c1 != c2
    assert c2 != c3
    assert c1.face
    assert c2.face
    assert c3.face
  end

  test "a card can be removed from deck" do
    deck = Deck.new() |> Deck.shuffle()
    assert Deck.count(deck) == 52

    [card] = Deck.peek(deck)
    assert Deck.find(deck, card)

    deck = Deck.remove(deck, card)
    assert Deck.count(deck) == 51

    assert [] = Deck.find(deck, card)
  end

  test "a card can be returned on top of the deck" do
    deck = Deck.new() |> Deck.shuffle()

    [card] = Deck.peek(deck)
    deck = Deck.remove(deck, card)

    assert [] = Deck.find(deck, card)

    deck = Deck.return(deck, card)
    assert [^card] = Deck.peek(deck)
  end

  test "a card can be returned on bottom of the deck" do
    deck = Deck.new() |> Deck.shuffle()
    [card] = Deck.peek(deck, :bottom)

    deck = Deck.remove(deck, card)
    assert [] = Deck.find(deck, card)

    deck = Deck.return(deck, card, :bottom)
    assert [^card] = Deck.peek(deck, :bottom)
  end

  test "a card can be returned randomly to the deck" do
    deck = Deck.new()

    [card] = Deck.peek(deck)
    deck = Deck.remove(deck, card)

    deck = Deck.return(deck, card, :random)
    assert [^card] = Deck.find(deck, card)
  end

  test "many cards can be returned randomly to the deck" do
    deck = Deck.new()
    cards = Deck.peek(deck, :random, 10)
    deck = Deck.remove(deck, cards)

    assert Deck.count(deck) == 42

    deck2 = Deck.return(deck, cards, :random)

    assert Deck.count(deck2) == 52
    assert deck != deck2
  end
end
