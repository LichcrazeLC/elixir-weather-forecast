defmodule WF.TAHLForecaster do
  use GenServer, restart: :temporary

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl true
  def init(aggregator) do
    {:ok, aggregator} = {:ok, Process.whereis(WF.Aggregator)}
  end

  @impl true
  def handle_cast({:Forecast, paramList}, aggregator) do

    IO.inspect paramList, label: "--- TAHLF Data Received"

    cond do
      paramList.temp > 30 and paramList.hum > 80 and paramList.atm < 770 and paramList.light > 192 ->
        GenServer.cast(aggregator, {:Aggregate, "HOT"})
      true ->
        GenServer.cast(aggregator, {:Aggregate, ""})

    end

    {:noreply, aggregator}

  end

end
