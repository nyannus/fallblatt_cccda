defmodule FallblattCore.Display.Supervisor do
  use Supervisor

  alias FallblattCore.{Queue, Worker}

  def start_link(module),
    do: Supervisor.start_link(__MODULE__, module)

  @impl true
  def init(module) do
    [
      %{id: module, start: {module, :start_link, []}},
      {Queue, module},
      {Worker, module}
    ]
    |> Supervisor.init(strategy: :rest_for_one)
  end
end
