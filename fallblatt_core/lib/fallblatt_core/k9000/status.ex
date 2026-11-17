defmodule FallblattCore.K9000.Status do
  defstruct blank?: false,
            ok?: false,
            reset?: false,
            locked?: false,
            running?: false,
            message: nil

  @type t :: %__MODULE__{
          blank?: boolean(),
          ok?: boolean(),
          reset?: boolean(),
          locked?: boolean(),
          running?: boolean(),
          message: binary() | nil
        }

  def from_binary(<<1::1, blank::1, reset::1, locked::1, error::4>>) do
    message =
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
        _ -> nil
      end

    %__MODULE__{
      blank?: blank,
      reset?: reset,
      locked?: locked,
      running?: error == 0b1111,
      ok?: error == 0b0000,
      message: message
    }
  end
end
