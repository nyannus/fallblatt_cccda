defmodule FallblattCore.Transaction do
  use Agent
  alias FallblattCore.Command

  defstruct id: 0,
            timestamp: nil,
            request: nil,
            response: nil,
            executed?: false

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          timestamp: non_neg_integer(),
          request: Command.t()
        }

  def start_link() do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def new(req) do
    id = Agent.get_and_update(__MODULE__, &{&1, &1 + 1})

    %__MODULE__{
      id: id,
      timestamp: :os.system_time(),
      request: req
    }
  end
end
