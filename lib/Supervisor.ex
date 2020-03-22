defmodule WF.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do

    children = [
      {DynamicSupervisor, name: WF.ParserSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: WF.TaskSupervisor, strategy: :one_for_one},
      WF.Collector
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
