defmodule WF.LForecaster do
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

    IO.inspect paramList, label: "--- LF Data Received"

    cond do
      paramList.light < 128 ->
        GenServer.cast(aggregator, {:Aggregate, "CLOUDY"})
      true ->
        GenServer.cast(aggregator, {:Aggregate, ""})
    end

    {:noreply, aggregator}

  end

end
