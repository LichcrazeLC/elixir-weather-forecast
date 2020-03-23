# Weather Forecaster

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `theatre` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wf, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/theatre](https://hexdocs.pm/theatre).

## General Info

This application uses several "Actors" (GenServers) to parse SSE events. The actor chain consists of a **Collector**, which initiates the connection to the SSE source, the **Parser**, which transforms the SSE event in JSON, the **Computer**, which maintains state, a Map which consists of 5 Lists *%{temperature => [], light => [], etc.}*. Each sensor value from every event adds an entry to its respective list in the map. **The Computer** loops back every 5 seconds to compute an average value for each list, and distribute the values among the *Forecast workers*. The forecast workers can be of **7 DIFFERENT TYPES**. The forecast worker's type depends on what sensor data it uses to compute it's forecast. For example, a forecast worker of type TALF is able to compute forecast just on data from the temperature, athm_pressure and light sensors. The forecast workers are distributed by an agent (**The Forecast Worker Registry**). That way, more than one forecasts per event can be computed, depending on the sensor data. The results from ALL the forecast worker types combine into the **Aggregator** worker which displays the forecast from every worker that successfully computed a forecast. Every process is monitored either by a **Supervisor** or by a **DynamicSupervisor**, making this a fault-tolerant system.

