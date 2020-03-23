defmodule WF.TForecaster do
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

    IO.inspect paramList, label: "--- TF Data Received"

    cond do
      paramList.temp < -8 ->
        GenServer.cast(aggregator, {:Aggregate, "SNOW"})
      true ->
        GenServer.cast(aggregator, {:Aggregate, ""})
    end

    {:noreply, aggregator}

  end

end
