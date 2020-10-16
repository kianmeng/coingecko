defmodule Coingecko do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @base_url "https://api.coingecko.com/api/v3/"

  @doc """
  Returns the current price of any cryptocurrencies in any other supported
  currencies.

  ## Examples

      iex> Coingecko.get_simple_price(["binancecoin", "basecoin"], ["btc", "eth"])
      {:ok,
       %{
         "basecoin" => %{"btc" => 1.0e-8, "eth" => 3.016e-7},
         "binancecoin" => %{"btc" => 0.00267301, "eth" => 0.08249109}
       }}

  """
  @spec get_simple_price([String.t()], [String.t()], map, boolean) :: {:ok, [map]} | {:error, any}
  def get_simple_price(ids, vs_currencies, options \\ %{}, force_refresh \\ false) do
    params =
      %{ids: Enum.join(ids, ","), vs_currencies: Enum.join(vs_currencies, ",")}
      |> Map.merge(options)
      |> URI.encode_query()

    url = "simple/price?" <> params
    request(:get, url, "", force_refresh)
  end

  @doc """
  Returns a list of supported bitcoins.

  ## Examples

      iex> Coingecko.get_coin_list()
      {:ok,
       [
         %{"id" => "01coin", "name" => "01coin", "symbol" => "zoc"},
         %{
           "id" => "0-5x-long-algorand-token",
           "name" => "0.5X Long Algorand Token",
           "symbol" => "algohalf"
         },
         ...
       ]}

  """
  @spec get_coin_list(boolean) :: {:ok, [map]} | {:error, any}
  def get_coin_list(force_refresh \\ false) do
    url = "/coins/list"
    request(:get, url, "", force_refresh)
  end

  @doc """
  Returns a list of cached keys of HTTP requests.

  ## Examples

      iex> Coingecko.get_cached_keys()
      {:ok,
       ["get_simple/price?ids=binancecoin%2Cbasecoin&vs_currencies=btc%2Ceth_",
        "get_/simple/supported_vs_currencies_", "get_/coins/list_"]}

  """

  @spec get_cached_keys() :: {:ok, [String.t()]}
  def get_cached_keys, do: Cachex.keys(:coingecko_cache)

  @doc """
  Returns a list of supported vs currencies.

  ## Examples

      iex> Coingecko.get_simple_supported_vs_currencies
      {:ok,
       ["btc", "eth", "ltc", "bch", "bnb", "eos", "xrp", "xlm", "link", "dot", "yfi",
        "usd", "aed", "ars", "aud", "bdt", "bhd", "bmd", "brl", "cad", "chf", "clp",
        "cny", "czk", "dkk", "eur", "gbp", "hkd", "huf", "idr", "ils", "inr", "jpy",
        "krw", "kwd", "lkr", "mmk", "mxn", "myr", "ngn", "nok", "nzd", "php", "pkr",
        "pln", "rub", "sar", "sek", "sgd", "thb", "try", "twd", "uah", "vef", "vnd",
        "zar", "xdr", "xag", "xau"]}

  """
  @spec get_simple_supported_vs_currencies(boolean) :: {:ok, [String.t()]} | {:error, any}
  def get_simple_supported_vs_currencies(force_refresh \\ false) do
    url = "/simple/supported_vs_currencies"
    request(:get, url, "", force_refresh)
  end

  defp request(method, url, body, false) do
    get_from_cache(method, url, body)
  end

  defp request(method, url, body, true) do
    get_and_cache(method, url, body)
  end

  defp get_from_cache(method, url, body) do
    key = get_key(method, url, body)

    Cachex.fetch(:coingecko_cache, key, fn _ ->
      Mojito.request(method, @base_url <> url, [{"content-type", "application/json"}], body)
      |> parse_response
      |> case do
        {:ok, resp} -> {:commit, resp}
        resp -> {:ignore, resp}
      end
    end)
    |> convert_results
  end

  defp get_and_cache(method, url, body) do
    key = get_key(method, url, body)

    Mojito.request(method, @base_url <> url, [{"content-type", "application/json"}], body)
    |> parse_response
    |> case do
      {:ok, resp} ->
        Cachex.put(:coingecko_cache, key, resp)
        {:ok, resp}

      resp ->
        resp
    end
  end

  defp convert_results({:ignore, resp}), do: resp
  defp convert_results({:commit, resp}), do: {:ok, resp}
  defp convert_results(resp), do: resp

  defp get_key(method, url, body) do
    "#{method}_#{url}_#{body}"
  end

  defp parse_response({:ok, %{body: body, status_code: status_code}})
       when status_code in [200, 201] do
    case Jason.decode(body) do
      {:ok, resp} -> {:ok, resp}
      error -> {:error, error}
    end
  end

  defp parse_response(response), do: response
end
