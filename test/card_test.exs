defmodule CardTest do
  use ExUnit.Case

  alias Cardashian.Card

  test "new card can be instantiated" do
    card = Card.new(face: 5, suit: :diamonds)
    assert card.suit == :diamonds
    assert card.symbol == "️♦️"
    assert card.face == 5
    assert card.visibility == :back
    assert card.id
    refute card.deck_id
  end
end
