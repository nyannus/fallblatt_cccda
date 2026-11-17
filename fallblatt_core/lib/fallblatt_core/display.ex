defmodule FallblattCore.Display do
  alias FallblattCore.K9000.Command
  alias FallblattCore.Segment
  alias Circuits.UART

  use GenServer

  defmacro __using__(opts) do
    device = Keyword.fetch!(opts, :device)

    quote do
      import FallblattCore.K9000.Segment
      use GenServer

      def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
      end

      # Delegate genserver methods to this module for better compiler and lsp support
      defdelegate handle_call(request, from, state), to: unquote(__MODULE__)

      def set_offset(pos, offset),
        do: GenServer.call(__MODULE__, {:set_offset, position, offset})

      @doc """
        Lookup a string of characters inside of a FBM segement definition
        Return a list of positions the FBMs need to be turned to
      """
      def lookup(string, color \\ :white),
        do: GenServer.call(__MODULE__, {:lookup, string, color})

      # Expose device option
      def device, do: unquote(device)

      # Register segements attribute, which Segment.defsegment macro will add to
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :segments, accumulate: true)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      # Expose all registered segments that where defined by using defsegment/1
      # Order them in a map with the position as the key
      def segments,
        do:
          @segments
          |> Enum.map(fn %Segment{position: pos} = seg -> {pos, seg} end)
          |> Enum.into(%{})

      def init() do
        {:ok, segments()}
      end
    end
  end

  ### Genserver methods

  def handle_call({:set_offset, position, offset}, _from, segments) do
    Map.get_and_update(segments, position, nil, fn
      nil -> :pop
      seg -> Map.put(seg, :offset, offset)
    end)
    |> then(&{:noreply, &1})
  end

  def handle_call({:lookup, string, color}, _from, segments) do
    string
    |> to_charlist()
    |> Enum.with_index(fn char, pos ->
      with %Segment{} = seg <- Map.get(segments, pos) do
        Segment.lookup(seg, {color, char})
      else
        nil -> nil
      end
    end)
    |> then(&{:reply, &1, segments})
  end


  def send_command(device, %Command{} = cmd) do
    with :ok <- UART.write(device, cmd.payload),
         {:ok, response} <- recieve_response(device, cmd) do
      # register_transaction(cmd, response)
      {:ok, response}
    else
      {:error, :ebadf} -> {:error, :closed}
      {:error, error} -> {:error, error}
    end
  end

  def recieve_response(device, %Command{response_bytes: 0}),
    do: {:ok, nil}

  def recieve_response(device, %Command{response_format: format}) do
    case UART.read(device) do
      {:ok, <<>>} -> {:error, :rx_timeout}
      {:ok, response} -> {:ok, {response, format.(response)}}
      {:error, :ebadf} -> {:error, :closed}
    end
  end

  defp register_transaction() do
  end
end
