defmodule CoingeckoTest do
  use ExUnit.Case
  doctest Coingecko

  test "greets the world" do
    assert Coingecko.hello() == :world
  end
end
