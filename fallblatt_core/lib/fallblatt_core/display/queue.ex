defmodule FallblattCore.Display.Queue do
  use GenServer

  @type t :: {:queue.queue(), non_neg_integer()}
  @max_queue_size 64

  defp via_tuple(display),
    do: {:via, Registry, {FallblattCore.QueueRegistry, display}}

  def start_link(display) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(display))
  end

  @spec init([]) :: {:ok, t()}
  def init([]) do
    {:ok, {:queue.new(), 0}}
  end

  # GenServer calls:

  @doc false
  def handle_call({:push, _}, _from, {q, size})
      when size > @max_queue_size,
      do: {:reply, :full, {q, size}}

  def handle_call({:push, item}, _from, {q, size}),
    do: {:reply, :ok, {:queue.snoc(q, item), size + 1}}

  def handle_call(:pop, _from, {q, 0}),
    do: {:reply, :empty, {q, 0}}

  def handle_call(:pop, _from, {q, size}),
    do: {:reply, {:ok, :queue.head(q)}, {:queue.tail(q), size}}

  # API

  @spec push(binary(), term()) :: :ok | :full
  def push(display, item),
    do: GenServer.call(via_tuple(display), {:push, item})

  @spec pop(binary()) :: {:ok, term()} | :empty
  def pop(display),
    do: GenServer.call(via_tuple(display), :pop)
end
