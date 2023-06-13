// Copyright (C) 2023 René Gern.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.

import i2c
import crypto.crc show Crc

/**
Driver for SHT20 sensor.
*/
class Sht20:
  static I2C_ADDRESS ::= 0x40

  static TRIGGER_TEMP_MEASURE_NOHOLD_ ::= 0xF3
  static TRIGGER_HUMD_MEASURE_NOHOLD_ ::= 0xF5
  static SOFT_RESET_                  ::= 0xFE

  device_/i2c.Device

  constructor .device_:
    initialize

  initialize:
    reset
    sleep --ms=1

  reset:
    write_simple_command_ SOFT_RESET_
    sleep --ms=10

  read_temperature -> float:
    write_simple_command_ TRIGGER_TEMP_MEASURE_NOHOLD_
    sleep --ms=85

    data := device_.read 3
    calculated_crc := crc8_sht20 data[..2]

    if data[2] != calculated_crc:
      throw "CRC error: $data[2]!=$calculated_crc"

    // Raw temperature reading.
    // The two least significant bits are used for transmitting status information.
    // For example, bit 1 is 1 if the returned value is for the temperature.
    // We simply discard it.
    raw := (data[0] << 8) | (data[1] & 0b1111_1100)

    // Raw to physical temperature value (°C).
    result := raw * 175.72
    result = result / 65536.0
    result = -46.85 + result

    return result

  read_humidity -> float:
    write_simple_command_ TRIGGER_HUMD_MEASURE_NOHOLD_
    sleep --ms=29

    data := device_.read 3
    calculated_crc := crc8_sht20 data[..2]

    if data[2] != (crc8_sht20 data[..2]):
      throw "CRC error: $data[2]!=$calculated_crc"

    // Raw humidity reading.
    // The two least significant bits are used for transmitting status information.
    // For example, bit 1 is 0 if the returned value is for the humidity.
    // We simply discard it.
    raw := (data[0] << 8) | (data[1] & 0b1111_1100)

    //Raw to physical humidity value (%)
    result := raw * 125.0
    result = result / 65536.0
    result = -6.0 + result
    return result

  /**
  Writes a simple command to the device.
  */
  write_simple_command_ command/int:
    cmd := #[command]
    device_.write cmd

  crc8_sht20 data -> int:
    mycrc := Crc.big_endian 8 --polynomial=0x31 
    mycrc.add data
    return mycrc.get_as_int