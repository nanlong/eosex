defmodule Eosex.Client do

  def request(url, params \\ []) do
    params = params_encode!(params)

    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.post(url, params)

    case Poison.decode!(body) do
      %{"error" => _} = body ->
        {:error, body}

      body -> {:ok, body}
    end
  end

  defp params_encode!(params) do
    cond do
      Keyword.keyword?(params) -> Map.new(params)
      is_tuple(params) -> Tuple.to_list(params)
      true -> params
    end
    |> Poison.encode!()
  end
end
