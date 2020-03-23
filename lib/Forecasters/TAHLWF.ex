defmodule WF.TAHLWForecaster do
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

    IO.inspect paramList, label: "--- TAHLWF Data Received"

    cond do
      paramList.temp > 30 and paramList.hum > 50 and paramList.atm < 770 and paramList.light > 192 and paramList.wind > 35 ->
        GenServer.cast(aggregator, {:Aggregate, "CONVECTION_OVEN"})
      paramList.temp > 25 and paramList.hum > 70 and paramList.atm < 750 and paramList.light < 192 and paramList.wind < 10 ->
        GenServer.cast(aggregator, {:Aggregate, "WARM"})
      paramList.temp > 25 and paramList.hum > 70 and paramList.atm < 750 and paramList.light < 192 and paramList.wind > 10 ->
        GenServer.cast(aggregator, {:Aggregate, "SLIGHT_BREEZE"})
      true ->
        GenServer.cast(aggregator, {:Aggregate, ""})

    end

    {:noreply, aggregator}

  end

end
