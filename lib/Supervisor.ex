defmodule WF.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do

    children = [
      {DynamicSupervisor, name: WF.ParserSupervisor, strategy: :one_for_one},
      {WF.Computer, name: WF.Computer},
      {DynamicSupervisor, name: WF.ForecasterSupervisor, strategy: :one_for_one},
      {WF.Aggregator, name: WF.Aggregator},
      {WF.ForecasterRegistry, name: WF.ForecasterRegistry},
      WF.Collector
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
