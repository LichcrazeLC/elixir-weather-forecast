defmodule WF.Aggregator do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl true
  def init(_state) do
    state = []
    {:ok, state}
  end

  @impl true
  def handle_cast({:Aggregate, forecast}, state) do

    state = state ++ [forecast]

    if Enum.count(state) == 7 do

      state = Enum.filter(state, &(&1 != ""))

      if (Enum.count(state) == 0) do
        IO.inspect "JUST_A_NORMAL_DAY", label: "--- WEATHER FORECAST"
      else
        IO.inspect state, label: "--- WEATHER FORECAST"
      end

      {:noreply, []}
    else

      # IO.inspect forecast, label: "--- Aggregator Received"
      {:noreply, state}

    end

  end

end
