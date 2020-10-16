defmodule Coingecko do
  @moduledoc """
  Documentation for `Coingecko`.
  https://www.coingecko.com/en/api#explore-api

  """

  @doc """
  Hello world.

  ## Examples

      iex> Coingecko.hello()
      :world

  """

  @base_url "https://api.coingecko.com/api/v3/"
  @spec get_simple_price([String.t()], [String.t()], map, boolean) :: {:ok, [map]} | {:error, any}
  def get_simple_price(ids, vs_currencies, options \\ %{}, force_refresh \\ false) do
    params =
      %{ids: Enum.join(ids, ","), vs_currencies: Enum.join(vs_currencies, ",")}
      |> Map.merge(options)
      |> URI.encode_query()

    url = "simple/price?" <> params
    request(:get, url, "", force_refresh)
  end

  @spec get_coin_list(boolean) :: {:ok, [map]} | {:error, any}
  def get_coin_list(force_refresh \\ false) do
    url = "/coins/list"
    request(:get, url, "", force_refresh)
  end

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
  end

  defp get_and_cache(method, url, body) do
    key = get_key(method, url, body)

    Mojito.request(method, @base_url <> url, [{"content-type", "application/json"}], body)
    |> parse_response
    |> case do
      {:ok, resp} ->
        Cachex.put(:coingecko_cache, key, resp)
        resp

      resp ->
        resp
    end
  end

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
