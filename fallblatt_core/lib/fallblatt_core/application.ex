defmodule FallblattCore.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    [
      # Starting registries so the Queues and Workers can be found by display
      {Registry, keys: :unique, name: FallblattCore.WorkerRegistry},
      {Registry, keys: :unique, name: FallblattCore.QueueRegistry},

      # Lastly start the configured display at lib/fallblatt_display/cccda.ex
      # The display will act as supervisor itself and start the worker and queue
      FallblattDisplay.CCCDA
    ]
    |> Supervisor.start_link(strategy: :one_for_one, name: FallblattCore.Supervisor)
  end
end
