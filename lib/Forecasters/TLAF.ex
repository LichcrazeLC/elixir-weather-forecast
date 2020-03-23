defmodule WF.TLAForecaster do
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
      paramList.temp < -2 and paramList.light < 128 and paramList.atm < 720 ->
        GenServer.cast(aggregator, {:Aggregate, "SNOW"})
      paramList.temp < -2 and paramList.light > 128 and paramList.atm < 680 ->
        GenServer.cast(aggregator, {:Aggregate, "WET_SNOW"})
      true ->
        GenServer.cast(aggregator, {:Aggregate, ""})

    end

    {:noreply, aggregator}

  end

end
