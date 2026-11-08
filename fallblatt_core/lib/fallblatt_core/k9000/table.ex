defmodule K9000.Table do
  alias FallblattCore.K9000.Command

  def load_commands(address) do
    for i <- 0..51 do
      Command.load_table(address, i, i + 0x20)
    end

    Enum.each(0..51, fn page ->
      code = 0x20 + page
      port_write(fbm.port, <<page, code>>)
      resp = port_read(fbm.port, 1)

      {resp_str, ok} =
        case resp do
          <<^code, _::binary>> -> {Base.encode16(resp, case: :lower), true}
          <<_, _::binary>> -> {Base.encode16(resp, case: :lower), false}
          _ -> {"NO RESPONSE", false}
        end

      page_str = page |> Integer.to_string() |> String.pad_leading(2)
      code_str = code |> Integer.to_string(16) |> String.pad_leading(2, "0")

      IO.puts(
        "    Flap #{page_str} -> 0x#{code_str}: #{resp_str}" <>
          if(ok, do: "", else: "  <-- MISMATCH")
      )

      Process.sleep(60)
    end)
  end
end
