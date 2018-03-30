defmodule Bittrex.Api do

  def getbalances do
    get_from_api "account/getbalances"
  end

  def getbalance(currency) do
    get_from_api "account/getbalance", %{currency: currency}
  end

  def buylimit(opts \\ []) do
    market = Keyword.fetch!(opts, :market)
    quantity = Keyword.fetch!(opts, :quantity)
    rate = Keyword.fetch!(opts, :rate)
    get_from_api "market/buylimit", %{market: market, quantity: quantity, rate: rate}
  end

  def buymarket(opts \\ []) do
    market = Keyword.fetch!(opts, :market)
    quantity = Keyword.fetch!(opts, :quantity)
    get_from_api "market/buymarket", %{market: market, quantity: quantity}
  end

  def selllimit(opts \\ []) do
    market = Keyword.fetch!(opts, :market)
    quantity = Keyword.fetch!(opts, :quantity)
    rate = Keyword.fetch!(opts, :rate)
    get_from_api "market/selllimit", %{market: market, quantity: quantity, rate: rate}
  end

  def sellmarket(opts \\ []) do
    market = Keyword.fetch!(opts, :market)
    quantity = Keyword.fetch!(opts, :quantity)
    get_from_api "market/sellmarket", %{market: market, quantity: quantity}
  end

  def cancel(uuid) do
    get_from_api "market/cancel", %{uuid: uuid}
  end

  def getopenorders(market) do
    get_from_api "market/getopenorders", %{market: market}
  end

  def getorder(uuid) do
    get_from_api "account/getorder", %{uuid: uuid}
  end

  def getorderhistory(opts \\ []) do
    market = Keyword.fetch!(opts, :market)
    get_from_api "account/getorderhistory", %{market: market}
  end

  def getwithdrawalhistory(opts \\ []) do
    currency = Keyword.fetch!(opts, :currency)
    get_from_api "account/getwithdrawalhistory", %{currency: currency}
  end

  def getdeposithistory(opts \\ []) do
    currency = Keyword.fetch!(opts, :currency)
    get_from_api "account/getdeposithistory", %{currency: currency}
  end

  defp get_from_api(command, params \\ %{}) do
    Bittrex.Api.Transport.get(command, params)
  end

  defp reduce_params(params_map) do
    for {k, v} <- params_map, v != nil, into: %{}, do: {k, v}
  end

end
