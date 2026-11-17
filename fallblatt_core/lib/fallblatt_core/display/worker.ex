defmodule FallblattCore.Display.Worker do
  alias Circuits.UART
  alias FallblattCore.{Queue, Transaction}
  use GenServer

  @poll_ms 500

  defstruct device: nil,
            timer: nil,
            task: nil,
            running?: true

  @type t :: %__MODULE__{
          timer: pid() | nil,
          task: Task.t() | nil,
          running?: boolean()
        }

  # Simple getters for struct fields
  defp device(%__MODULE__{device: device}), do: device
  defp timer(%__MODULE__{timer: timer}), do: timer
  defp task(%__MODULE__{task: task}), do: task
  defp running?(%__MODULE__{running?: running?}), do: running?

  defguard is_running(x)
           when is_struct(x, __MODULE__) and :erlang.map_get(x, :running?)

  @impl true
  def init(_opts) do
    state = %{status: :running, task: nil, timer: nil}
    {:ok, state}
  end

  def handle_info(:tick, state) when not is_running(state),
    do: {:noreply, %__MODULE__{state | timer: nil}}

  def handle_info(:tick, %__MODULE__{task: %Task{}} = state),
    do: {:noreply, %__MODULE__{state | timer: nil}}

  def handle_info(:tick, state) do
    state = %{state | timer: nil}

    case Queue.pop() do
      :empty ->
        {:noreply, state, {:continue, :schedule}}

      {:ok, %Transaction{} = t} ->
        task = Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> execute(cmd) end)
        {:noreply, %{state | task: task}}
    end
  end

  def handle_continue(:schedule, %__MODULE__{timer: nil} = state) do
    timer = Process.send_after(self(), :tick, @poll_ms)
    {:noreply, %__MODULE__{state | timer: timer}}
  end

  def handle_continue(:schedule, state) do
    {:noreply, state}
  end
end
