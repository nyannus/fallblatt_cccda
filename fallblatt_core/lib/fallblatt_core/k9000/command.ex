defmodule FallblattCore.K9000.Command do
  import Bitwise

  @type t :: %__MODULE__{
          payload: binary(),
          response_bytes: non_neg_integer(),
          response_format: function()
        }
  defstruct payload: <<>>,
            response_bytes: 0,
            response_format: &Function.identity/1

  # OP Codes
  @cmd_start 0b0001
  @cmd_set_home 0b0010
  @cmd_reset 0b0011
  @cmd_read_status 0b0100
  @cmd_read_code 0b0101
  @cmd_lock 0b0110
  @cmd_unlock 0b0111
  @cmd_set_code 0b1000
  @cmd_calibrate_auto 0b1001
  @cmd_calibrate_hand 0b1010
  @cmd_calibrate_stop 0b1011
  @cmd_calibrate_info 0b1100
  @cmd_set_table 0b1101
  @cmd_delete_table 0b1110

  # Flags
  @flag_large_address 0b0100
  @flag_large_code 0b0100

  # Error codes
  @err_comm_error 0b1000
  @err_start_missing 0b1001
  @err_unknown_char 0b1010
  @err_external_rot 0b1011
  @err_rot_timeout 0b1100
  @err_fbm_missing 0b1101
  @err_rotating 0b1111

  defp command(opcode),
    do: <<
      # The MSB of the byte being set signals beginning of a new command.
      # Since this implies the MSB cannot be set for any arguments, the
      # MSB of the arguments are stored in this first byte:
      0::1,
      # Address expansion flag (MSB of the address, 1 if address > 127)
      0::1,
      # Code expansion flag (MSB of the charcode, 1 if code > 127)
      0::1,
      1::1,
      # 4 bits opcode
      opcode::4
    >>

  # Helper function to append the address argument and set the flag if needed
  defp with_address(<<cmd::8>>, address) when address > 127,
    do: <<
      cmd ||| @flag_large_address::8,
      address &&& 0x7F::8
    >>

  defp with_address(<<cmd::8>>, address), do: <<cmd::binary, address::8>>

  # Helper function to append the charcode argument and set the flag if needed
  defp with_code(<<cmd::8, address::8>>, code) when code > 127,
    do: <<
      cmd ||| @flag_large_code::8,
      address::8,
      code &&& 0x7F::8
    >>

  defp with_code(<<cmd::8, address::8>>, code),
    do: <<
      cmd::8,
      address::8,
      code::8
    >>

  # Helper function to append the charcode argument (no flag needed)
  defp with_position(cmd, position),
    do: <<
      cmd::binary,
      position &&& 0x7F::8
    >>

  defp noreply(cmd), do: %__MODULE__{payload: cmd}

  defp reply(cmd, opts \\ []),
    do: %__MODULE__{
      payload: cmd,
      response_bytes: Keyword.fetch!(opts, :bytes),
      response_format: Keyword.get(opts, :format, &Function.identity/1)
    }

  @doc """
    ## Official documentation:
    > Der "Startbefehl" bewirkt den Start der Einstellung, wenn vorher eine
    > gültige Einstellsequenz (Einstellbefehl, FBM-Adresse, Code) gesendet wurde.
    > Ist das FBM gesperrt, wird keine Einstellung gestartet.
    > Eine evt. erhaltene Einstellsequenz wird nicht gelöscht.
    > Erhält ein FBM während einer Einstellung (Status Lauf) den Startbefehl,
    > stellt sich das FBM auf den zuletzt gesendeten Code einer Einstellsequenz ein.
  """
  def start() do
    command(@cmd_start)
    |> noreply()
  end

  @doc """
    ## Official documentation:
    > Der "Leerbildbefehl" bewirkt den Start der Einstellung auf Leerbild, wobei
    > immer über Synchronimpuls gedreht wird. Erhält ein FBM während einer
    > Einstellung (Status Lauf) den "Leerbildbefehl", stellt sich das FBM auf
    > Leerbild. Der "Leerbildbefehl" löscht eine evt. erhaltene Einstellsequenz.
    > Ist das FBM gesperrt, wird keine Leerbildeinstellung gestartet.
  """
  def blank() do
    command(@cmd_start)
    |> noreply()
  end

  @doc """
    ## Original documentation:
    > Programmneustart.
    > Der "Softwareresetbefehl" sperrt die Interuptbearbeitung im FBM und bewirkt
    > dadurch den Ablauf des Watchdogtimers mit anschließendem Reset des FBM-Controllers.
  """
  def reset() do
    command(@cmd_reset)
    |> noreply()
  end

  @doc """
    ## Official documentation:
    > Die Statusabfrage wird durch das FBM mit dem aktuellen Status beantwortet.
    > Sie kann zu jedem Zeit- punkt erfolgen und bewirkt selber keine Veränderung
    > des FBM-Status. Antworten des FBM siehe unter FBM-Status. Ist eine voll-
    > ständige Einstellsequenz empfangen worden ohne Startbefehl, antwortet das
    > FBM mit der entsprechenden Statusmeldung und kann dann noch mit dem
    > "Startbefehl" eingestellt werden.
  """
  def status(address) do
    command(@cmd_read_status)
    |> with_address(address)
    |> reply(bytes: 1, format: &status_code_format/1)
  end

  defp status_code_format(<<1::1, blank::1, reset::1, locked::1, error::4>>) do
    text =
      case error do
        0b0000 -> "keine Störung"
        0b0001 -> "Störung (Synchronimpuls fehlt)"
        0b0010 -> "Störung (Blattimpuls fehlt)"
        0b0011 -> "Störung (Motor dreht nicht/keine Sensorimpulse)"
        0b0100 -> "Störung (keine 42V Impulse)"
        0b0101 -> "Störung (keine 42V Impulse u. kein Synchronimpuls)"
        0b0110 -> "Störung (keine 42V Impulse u. kein Blattimpuls)"
        0b0111 -> "Störung (keine 42V Impulse u. keine Sensorimpulse, 42V defekt)"
        0b1000 -> "Übertragungsfehler (letztes Telegramm wurde nicht verstanden)"
        0b1001 -> "Startbefehl nach Einstellbefehl fehlt"
        0b1010 -> "Störung (Datencode unbekannt)"
        0b1100 -> "Störung (Modul schwergängig, Zeitproblem)"
        0b1111 -> "Lauf"
      end

    status =
      for {flag, true} <- [
            blank: blank,
            reset: reset,
            locked: locked,
            running: error == 0b1111,
            ok: error == 0b0000
          ],
          do: flag

    {status, text}
  end

  @doc """
    ## Official documentation:
    > Die Codeabfrage wird durch das FBM mit dem aktuell eingestellten Code
    > beantwortet. Während einer Einstellung antwortet das FBM mit dem einzu-
    > stellendem Code. Nach dem Empfang einer Einstellsequenz vor dem Startbefehl
    > wird diese Abfrage mit dem noch eingestellten Code beantwortet und der Start
    > einer Einstellung mit dem "Startbefehl" ist weiterhin möglich.
  """
  def get_code(address) do
    command(@cmd_read_code)
    |> with_address(address)
    |> reply(bytes: 1, format: &code_format/1)
  end

  defp code_format(<<code::unsigned-integer-8>>), do: code

  @doc """
    ## Official documentation:
    > Der Befehl "Einstellen" ist der Anfang einer Einstellsequenz bestehend aus
    > dem Befehl, FBM-Adresse und des FBM-Codes. Die Einstellsequenz selber
    > startet nicht das FBM, so daß mehrere Module ihre Einstellsequenz erhalten
    > können und dann mit dem "Startbefehl" gemeinsam gestartet werden können.
    > Während des Laufs eines FBM wird jederzeit eine neue Einstellsequenz ange-
    > nommen. Ist ein FBM gesperrt, wird die Einstellsequenz abgespeichert und
    > kann nach Freigabe mit dem "Startbefehl" gestartet werden.
  """
  def set_code(address, code) do
    command(@cmd_set_code)
    |> with_address(address)
    |> with_code(code)
    |> noreply()
  end

  @doc """
    # Original german technical documentation:
    Die Bedruckungsliste laden besteht aus folgender Sequenz:
    Befehl, FBM-Adresse, Blattnummer, Blattcode,..., Blattnr., Blattcode, Bedruckungslistenende.
    Das Leerbildblatt hat die Blattnummer 0.
    Die Übertragung kann in beliebiger Reihenfolge erfolgen. Es können auch nur einzelne Werte
    geändert werden.
    Das FBM antwortet nach jedem ordnungsgemäßen Empfang einer Blattnummer und des Blattcodes
    mit dem Blattcode. Antwortet das FBM nicht, so muß immer mit dem Befehl wieder begonnen werden.
    Der zusendende Code für die bedruckten Zeichen entspricht dem ISO Latin Alphabet Nr.1.
    Zur Übertragung des ASCII Zeichensatzes und des erweiterten Zeichensatzes müssen 2 Sequenzen
    übertragen werden.

    Beispiel :

    9Dh, 00h,00h,20h,04h,33h,0Bh,41h,9Bh

    Das FBM mit der Adresse 0 ist bedruckt: Blatt 0 -  Leerbildblatt
        Blatt 4 -  3
        Blatt 11 - A

    0xBD,0x00h,0x32,0x46,0x33,0x58,0x31h,0x45h,0x9Bh
  """
  def load_table(address, code, position) do
    command(@cmd_set_table)
    |> with_address(address)
    |> with_code(code)
    |> with_position(position)
  end
end
