defmodule WF do
  use Application

  @impl true
  def start(_type, _args) do

    WF.Supervisor.start_link(name: WF.Supervisor)

  end

end
