defmodule WF.ForecasterRegistry do
  use GenServer, restart: :temporary

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl true
  def init(forecasters) do
    {:ok, forecasters}
  end

  @impl true
  def handle_call({:lookup, fc_name}, _from, forecasters) do

    if Map.has_key?(forecasters, fc_name) do
      {:reply, Map.fetch(forecasters, fc_name), forecasters}

    else
      case fc_name do
        "TLAF" ->
          {:ok, forecaster} = DynamicSupervisor.start_child(WF.ForecasterSupervisor, WF.TLAForecaster)
          forecasters = Map.put(forecasters, fc_name, forecaster)
          IO.puts "--- created TLA Forecaster"
          {:reply, Map.fetch(forecasters, fc_name), forecasters}

        "TF" ->
          {:ok, forecaster} = DynamicSupervisor.start_child(WF.ForecasterSupervisor, WF.TForecaster)
          forecasters = Map.put(forecasters, fc_name, forecaster)
          IO.puts "--- created T Forecaster"
          {:reply, Map.fetch(forecasters, fc_name), forecasters}

        "TWF" ->
          {:ok, forecaster} = DynamicSupervisor.start_child(WF.ForecasterSupervisor, WF.TWForecaster)
          forecasters = Map.put(forecasters, fc_name, forecaster)
          IO.puts "--- created TW Forecaster"
          {:reply, Map.fetch(forecasters, fc_name), forecasters}

        "TAWHF" ->
          {:ok, forecaster} = DynamicSupervisor.start_child(WF.ForecasterSupervisor, WF.TAWHForecaster)
          forecasters = Map.put(forecasters, fc_name, forecaster)
          IO.puts "--- created TAWH Forecaster"
          {:reply, Map.fetch(forecasters, fc_name), forecasters}

        "TAHLWF" ->
          {:ok, forecaster} = DynamicSupervisor.start_child(WF.ForecasterSupervisor, WF.TAHLWForecaster)
          forecasters = Map.put(forecasters, fc_name, forecaster)
          IO.puts "--- created TAHWL Forecaster"
          {:reply, Map.fetch(forecasters, fc_name), forecasters}

        "TAHLF" ->
          {:ok, forecaster} = DynamicSupervisor.start_child(WF.ForecasterSupervisor, WF.TAHLForecaster)
          forecasters = Map.put(forecasters, fc_name, forecaster)
          IO.puts "--- created TAHL Forecaster"
          {:reply, Map.fetch(forecasters, fc_name), forecasters}

        "LF" ->
          {:ok, forecaster} = DynamicSupervisor.start_child(WF.ForecasterSupervisor, WF.LForecaster)
          forecasters = Map.put(forecasters, fc_name, forecaster)
          IO.puts "--- created L Forecaster"
          {:reply, Map.fetch(forecasters, fc_name), forecasters}

      end

    end

  end


end

