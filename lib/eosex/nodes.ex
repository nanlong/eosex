defmodule Eosex.Nodes do

  defstruct [:api_endpoint, :ssl_endpoint]

  def get(node_key) do
    %{
      api_endpoint: "",
      ssl_endpoint: "",
    }
  end
end
