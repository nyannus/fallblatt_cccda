defmodule FallblattDisplay.CCCDA do
  use FallblattCore.Display,
    device: "/dev/cu.usbserial-110"

  # The letters (FBs) that are currently loaded into the FBM
  @letters [
    white:  ~FB<_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ          -*.: >,
    yellow: ~FB<_                                    0123456789    :>
  ]

  defsegment position: 0,
    address: 0x00,
    letters: @letters,
    offset:  0

  defsegment position: 1,
    address: 0x01,
    letters: @letters,
    offset:  0

  defsegment position: 2,
    address: 0x02,
    letters: @letters,
    offset:  0

  defsegment position: 3,
    address: 0x03,
    letters: @letters,
    offset:  0

  defsegment position: 4,
    address: 0x10,
    letters: @letters,
    offset:  0

  defsegment position: 5,
    address: 0x11,
    letters: @letters,
    offset:  0

  defsegment position: 6,
    address: 0x12,
    letters: @letters,
    offset:  0

  defsegment position: 7,
    address: 0x13,
    letters: @letters,
    offset:  0

  defsegment position: 8,
    address: 0x20,
    letters: @letters,
    offset:  0

  defsegment position: 9,
    address: 0x21,
    letters: @letters,
    offset:  0

  defsegment position: 10,
    address: 0x22,
    letters: @letters,
    offset:  0

  defsegment position: 11,
    address: 0x23,
    letters: @letters,
    offset:  0

  defsegment position: 12,
    address: 0x30,
    letters: @letters,
    offset:  0

  defsegment position: 13,
    address: 0x31,
    letters: @letters,
    offset:  0

  defsegment position: 14,
    address: 0x32,
    letters: @letters,
    offset:  0

end
