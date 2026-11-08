defmodule FallblattCore.K9000.Display do
  alias FallblattCore.K9000.Command
  alias Circuits.UART

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
