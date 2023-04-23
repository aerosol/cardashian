defmodule CardashianTest do
  use ExUnit.Case
  doctest Cardashian

  test "greets the world" do
    assert Cardashian.hello() == :world
  end
end
