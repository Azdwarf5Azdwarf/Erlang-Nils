defmodule MiniAi.Server do
  use GenServer

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def ask(prompt), do: GenServer.call(__MODULE__, {:ask, prompt}, 30_000)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:ask, prompt}, _from, state) do
    case System.get_env("OPENAI_API_KEY") do
      nil ->
        {:reply, {:error, :no_api_key}, state}

      key ->
        body =
          Jason.encode!(%{
            model: "gpt-4o-mini",
            messages: [%{role: "user", content: prompt}]
          })

        request = {
          ~c"https://api.openai.com/v1/chat/completions",
          [
            {~c"Authorization", String.to_charlist("Bearer " <> key)},
            {~c"Content-Type", ~c"application/json"}
          ],
          ~c"application/json",
          String.to_charlist(body)
        }

        reply =
          case :httpc.request(:post, request, [timeout: 20_000], []) do
            {:ok, {{_, 200, _}, _, resp}} -> {:ok, List.to_string(resp)}
            {:ok, {{_, code, _}, _, resp}} -> {:error, {code, List.to_string(resp)}}
            {:error, reason} -> {:error, reason}
          end

        {:reply, reply, state}
    end
  end
end
