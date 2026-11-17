defmodule FallblattCore.Command do
  @moduledoc """
    A command is a basic struct that encapsulates
    - a `payload` being send to the device;
    - the amount of bytes expected as a response (`response_byte`); and
    - an optional function that reads the binary response into a
      human readable format (`response_format`).

    Also see `FallblattCore.Transaction`
  """

  defstruct payload: <<>>,
            response_bytes: 0,
            response_format: &Function.identity/1

  @type t :: %__MODULE__{
          payload: binary(),
          response_bytes: non_neg_integer(),
          response_format: function()
        }

end
