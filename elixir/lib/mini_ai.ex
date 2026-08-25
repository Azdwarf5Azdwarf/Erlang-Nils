defmodule MiniAi do
  @moduledoc "Ask the supervised AI GenServer."
  def ask(prompt) when is_binary(prompt), do: MiniAi.Server.ask(prompt)
end
