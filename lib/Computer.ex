defmodule WF.Computer do
  use GenServer

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

    Process.send_after(self(), %{}, 5_000)
    {:ok, state}

  end

  @impl true
  def handle_cast({:process, event}, state) do

      temperature = event["temperature_sensor_1"] + event["temperature_sensor_2"]
      light = event["light_sensor_1"] + event["light_sensor_2"]
      atmo_pressure = event["atmo_pressure_sensor_1"] + event["atmo_pressure_sensor_2"]
      wind_speed = event["wind_speed_sensor_1"] + event["wind_speed_sensor_2"]
      humidity =  event["humidity_sensor_1"] + event["humidity_sensor_2"]

      incomingSens = [atmo_pressure, humidity, light, temperature, wind_speed]

      state = store_values(state, incomingSens)

      {:noreply, state}

  end

  @impl true
  def handle_info(msg, state) do

    state = filter_and_reset(state)

    Process.send_after(self(), %{}, 5_000)

    {:noreply, state}

  end

  defp filter_and_reset(state) do

    worker_registry = WF.ForecasterRegistry

    {:ok, currentTmp} = Map.fetch(state, "temperature")

    state = Enum.map(state, fn ({key, val}) -> {key, Enum.reduce(val, fn (score, sum) -> sum + score end) / Enum.count(val)} end)
            |> Enum.into(%{})

    {:ok, temp} = Map.fetch(state, "temperature")
    {:ok, light} = Map.fetch(state, "light")
    {:ok, atm} = Map.fetch(state, "atmo_pressure")
    {:ok, wind} = Map.fetch(state, "wind_speed")
    {:ok, hum} = Map.fetch(state, "humidity")

    {:ok, tlaf} = GenServer.call(worker_registry, {:lookup, "TLAF"})
    GenServer.cast(tlaf, {:Forecast, %{:temp => temp, :light => light, :atm => atm}})

    {:ok, lf} = GenServer.call(worker_registry, {:lookup, "LF"})
    GenServer.cast(lf, {:Forecast, %{:light => light}})

    {:ok, tahlf} = GenServer.call(worker_registry, {:lookup, "TAHLF"})
    GenServer.cast(tahlf, {:Forecast, %{:temp => temp, :light => light, :atm => atm, :hum => hum}})

    {:ok, tahlwf} = GenServer.call(worker_registry, {:lookup, "TAHLWF"})
    GenServer.cast(tahlwf, {:Forecast, %{:temp => temp, :light => light, :atm => atm, :hum => hum, :wind => wind}})

    {:ok, tawhf} = GenServer.call(worker_registry, {:lookup, "TAWHF"})
    GenServer.cast(tawhf, {:Forecast, %{:temp => temp, :atm => atm, :hum => hum, :wind => wind}})

    {:ok, tf} = GenServer.call(worker_registry, {:lookup, "TF"})
    GenServer.cast(tf, {:Forecast, %{:temp => temp}})

    {:ok, twf} = GenServer.call(worker_registry, {:lookup, "TWF"})
    GenServer.cast(twf, {:Forecast, %{:temp => temp, :wind => wind}})

    state = Enum.map(state, fn ({key, val}) -> {key, []} end) |> Enum.into(%{})

  end

  defp store_values(state, incomingSens) do

    updatedSensList = Enum.to_list(state)
                        |> Enum.map(fn ({key, val}) -> val end)
                          |> Enum.zip(incomingSens)
                            |>  Enum.map(fn ({key, val}) -> key ++ [val / 2] end)

    state = Enum.to_list(state)
              |> Enum.map(fn ({key, val}) -> key end)
                |> Enum.zip(updatedSensList)
                  |> Enum.into(%{})


    # IO.inspect state, label: "--- Average Values After Storing"

  end

end
