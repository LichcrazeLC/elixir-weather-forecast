defmodule WF.TAWHForecaster do
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

    IO.inspect paramList, label: "--- TLAF Data Received"

    cond do
      paramList.temp > 0 and paramList.hum > 70 and paramList.atm < 710 and paramList.wind < 20 ->
        GenServer.cast(aggregator, {:Aggregate, "SLIGHT_RAIN"})
      paramList.temp > 0 and paramList.hum > 70 and paramList.atm < 690 and paramList.wind > 20 ->
        GenServer.cast(aggregator, {:Aggregate, "HEAVY_RAIN"})
      paramList.temp > 30 and paramList.hum > 85 and paramList.atm < 660 and paramList.wind > 45 ->
        GenServer.cast(aggregator, {:Aggregate, "MONSOON"})
      true ->
        GenServer.cast(aggregator, {:Aggregate, ""})

    end

    {:noreply, aggregator}

  end

end
