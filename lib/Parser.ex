defmodule WF.Parser do
  use GenServer, restart: :temporary

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl true
  def init(computer) do
    {:ok, computer}
  end

  @impl true
  def handle_info(msg, computer) do

    case msg do
      %HTTPoison.AsyncChunk{chunk: c} ->
        data = String.slice(Enum.at(String.split(c, "\n"), 2), 6..-1)
        respJson = Jason.decode!(data)
        GenServer.cast(WF.Computer, {:process, respJson["message"]})
      _ ->
        IO.puts "-- Request Parameters Received --"
    end

    {:noreply, computer}

  end

end
