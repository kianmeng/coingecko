defmodule Coingecko.Helper do
  @spec symbols_to_names() :: map | none
  def symbols_to_names() do
    {:ok, coins} = Coingecko.get_coin_list()
    Enum.map(coins, fn(coin)->
      {coin["symbol"], coin["name"]}
    end)
    |> Enum.into(%{})
  end

  @spec names_to_symbols() :: map | none
  def names_to_symbols() do
    {:ok, coins} = Coingecko.get_coin_list()
    Enum.map(coins, fn(coin)->
      {String.downcase(coin["name"]), coin["symbol"]}
    end)
    |> Enum.into(%{})
  end
end
