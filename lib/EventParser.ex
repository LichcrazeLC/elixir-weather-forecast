defmodule WF.EventParser do
  use GenServer, restart: :temporary

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_info(msg, state) do

    case msg do
      %HTTPoison.AsyncChunk{chunk: c} ->
        data = String.slice(Enum.at(String.split(c, "\n"), 2), 6..-1)
        respJson = Jason.decode!(data)
        IO.inspect respJson["message"]
      _ ->
        IO.puts "something else received"
    end

    {:noreply, state}

  end

end
