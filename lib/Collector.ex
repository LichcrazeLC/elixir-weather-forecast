defmodule WF.Collector do
  use GenServer, restart: :permanent

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl true
  def init(_state) do

    {:ok, pid} = DynamicSupervisor.start_child(WF.ParserSupervisor, WF.Parser)
    resp = HTTPoison.get! "http://localhost:4000/iot", %{}, stream_to: pid, async: :once
    Process.send_after(self(), resp, 1_000)
    {:ok, %{last_run_at: nil}}

  end

  @impl true
  def handle_info(resp, state) do

    case resp do
      :kill -> {:stop, :normal, state}
          _ -> ":ok"
    end

    send_event_chunk(resp)

    case Supervisor.which_children(WF.ParserSupervisor) do
      [] -> Process.send(self(), :kill, [])
       _ -> Process.send_after(self(), resp, 1_000)
    end

    {:noreply, %{last_run_at: :calendar.local_time()}}

  end

  defp send_event_chunk(resp) do
    HTTPoison.stream_next(resp)
  end

end

