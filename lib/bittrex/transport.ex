defmodule Bittrex.Api.Error do
  defexception [message: "Bittrex API exception", body: nil, status_code: nil, headers: nil]
end

defmodule Bittrex.Api.Transport do
  use GenServer

  @base_url "https://bittrex.com/api/v1.1/"
  @bittrex_key Application.get_env(:bittrex_elixir, :key)
  @bittrex_secret Application.get_env(:bittrex_elixir, :secret)

  ## Public API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def get(command, params, server \\ __MODULE__) do
    GenServer.call(server, {:get, command, params}, :infinity)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:get, command, params}, _from, state) do
    {url, signature} = get_api_params(command, params)
    headers = %{"Content-Type" => "application/x-www-form-urlencoded", "apisign" => signature}
    opts = [recv_timeout: get_recv_timeout]
    case HTTPoison.get(url, headers, opts) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        reply = parse_res(body, headers)
        {:reply, reply, state}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body, headers: headers}} ->
        {:reply, {:error, %Bittrex.Api.Error{message: "Bittrex POST API exception", body: body, status_code: status_code, headers: headers}}, state}
      {:error, e} ->
        {:reply, {:error, e}, state}
    end
  end

  defp parse_res(body, headers) do
    case get_header(headers, "Content-Type") do
      "application/json; charset=utf-8" ->
        case Poison.decode(body) do
          {:ok, %{"success" => true, "result" => json}} -> {:ok, json}
          {:ok, %{"success" => false, "message" => error}} -> {:error, %Bittrex.Api.Error{message: error}}
          {:error, e} -> {:error, %Bittrex.Api.Error{message: body}}
        end
      _ ->
        {:error, %Bittrex.Api.Error{message: body}}
    end
  end

  defp get_api_params(command, params) do
    query = Map.merge(%{apikey: get_bittrex_key(), nonce: generate_nonce()}, params) |> URI.encode_query
    uri = @base_url <> command <> "?" <> query
    signature = generate_signature(uri)
    {uri, signature}
  end

  defp generate_nonce do
    Integer.to_string(:os.system_time(:milli_seconds)) <> "0"
  end

  defp generate_signature(uri) do
    :crypto.hmac(:sha512, get_bittrex_secret(), uri)
      |> Base.encode16
  end

  defp get_header(headers, key) do
    headers
    |> Enum.filter(fn({k, _}) -> k == key end)
    |> hd
    |> elem(1)
  end

  defp get_bittrex_key do
    Application.get_env(:bittrex_elixir, :key) || System.get_env("BITTREX_KEY") || @bittrex_key
  end

  defp get_bittrex_secret do
    Application.get_env(:bittrex_elixir, :secret) || System.get_env("BITTREX_SECRET") || @bittrex_secret
  end

  defp get_recv_timeout do
    Application.get_env(:bittrex_elixir, :recv_timeout) || 5_000
  end

end
