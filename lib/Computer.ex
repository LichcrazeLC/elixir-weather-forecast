defmodule WF.Computer do
  use GenServer, restart: :temporary

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl true
  def init(opts) do

    state = %{"temperature" => [],
                "light" => [],
                  "atmo_pressure" => [],
                    "wind_speed" => [],
                      "humidity" => []}

    forecaster_registry = WF.ForecasterRegistry
    Process.send_after(self(), forecaster_registry, 5_000)
    {:ok, state}

  end

  @impl true
  def handle_cast({:process, event}, state) do

      temperature = event["temperature_sensor_1"] + event["temperature_sensor_2"]
      light = event["light_sensor_1"] + event["light_sensor_2"]
      atmo_pressure = event["atmo_pressure_sensor_1"] + event["atmo_pressure_sensor_2"]
      wind_speed = event["wind_speed_sensor_1"] + event["wind_speed_sensor_2"]
      humidity =  event["humidity_sensor_1"] + event["humidity_sensor_2"]

      state = store_values(state, temperature, light, atmo_pressure, wind_speed, humidity)

      # IO.inspect Map.fetch(state, "temperature"), label: "Temperature values"
      {:noreply, state}

  end

  @impl true
  def handle_info(msg, state) do

    state = filter_and_reset(msg, state)

    Process.send_after(self(), msg, 5_000)

    {:noreply, state}

  end

  defp filter_and_reset(msg, state) do

    {:ok, currentTmp} = Map.fetch(state, "temperature")

    avgList = Enum.map(state, fn ({key, val}) -> {key, Enum.reduce(val, fn (score, sum) -> sum + score end) / Enum.count(val)} end)
    state = Enum.into(avgList, %{})

    {:ok, temp} = Map.fetch(state, "temperature")
    {:ok, light} = Map.fetch(state, "light")
    {:ok, atm} = Map.fetch(state, "atmo_pressure")
    {:ok, wind} = Map.fetch(state, "wind_speed")
    {:ok, hum} = Map.fetch(state, "humidity")

    {:ok, tlaf} = GenServer.call(msg, {:lookup, "TLAF"})
    GenServer.cast(tlaf, {:Forecast, %{:temp => temp, :light => light, :atm => atm}})

    {:ok, lf} = GenServer.call(msg, {:lookup, "LF"})
    GenServer.cast(lf, {:Forecast, %{:light => light}})

    {:ok, tahlf} = GenServer.call(msg, {:lookup, "TAHLF"})
    GenServer.cast(tahlf, {:Forecast, %{:temp => temp, :light => light, :atm => atm, :hum => hum}})

    {:ok, tahlwf} = GenServer.call(msg, {:lookup, "TAHLWF"})
    GenServer.cast(tahlwf, {:Forecast, %{:temp => temp, :light => light, :atm => atm, :hum => hum, :wind => wind}})

    {:ok, tawhf} = GenServer.call(msg, {:lookup, "TAWHF"})
    GenServer.cast(tawhf, {:Forecast, %{:temp => temp, :atm => atm, :hum => hum, :wind => wind}})

    {:ok, tf} = GenServer.call(msg, {:lookup, "TF"})
    GenServer.cast(tf, {:Forecast, %{:temp => temp}})

    {:ok, twf} = GenServer.call(msg, {:lookup, "TWF"})
    GenServer.cast(twf, {:Forecast, %{:temp => temp, :wind => wind}})

    state = Enum.map(state, fn ({key, val}) -> {key, []} end) |> Enum.into(%{})

    # IO.inspect state, label: "--- Average Values After 5 seconds"

  end

  defp store_values(state, temperature, light, atmo_pressure, wind_speed, humidity) do

    {:ok, currentTmp} = Map.fetch(state, "temperature")
    state = %{state | "temperature" => [temperature / 2] ++ currentTmp}

    {:ok, currentLight} = Map.fetch(state, "light")
    state = %{state | "light" => [light / 2] ++ currentLight}

    {:ok, currentAtmoPressure} = Map.fetch(state, "atmo_pressure")
    state = %{state | "atmo_pressure" => [atmo_pressure / 2] ++ currentAtmoPressure}

    {:ok, currentWindSpeed} = Map.fetch(state, "wind_speed")
    state = %{state | "wind_speed" => [wind_speed / 2] ++ currentWindSpeed}

    {:ok, currentHumidity} = Map.fetch(state, "humidity")
    state = %{state | "humidity" => [humidity / 2] ++ currentHumidity}

  end

end
