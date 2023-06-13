import i2c

/**
Driver for SHT20 sensor
*/
class SHT20Driver:
  static I2C_ADDRESS ::= 0x40
  static TRIGGER_HUMD_MEASURE_HOLD   ::= 0xE5
  static TRIGGER_TEMP_MEASURE_HOLD   ::= 0xE3
  static TRIGGER_TEMP_MEASURE_NOHOLD ::= 0xF3
  static TRIGGER_HUMD_MEASURE_NOHOLD ::= 0xF5
  static WRITE_USER_REG              ::= 0xE6
  static READ_USER_REG               ::= 0xE7
  static SOFT_RESET                  ::= 0xFE
  static REG_RESOLUTION_MASK         ::= 0x81
  static REG_RESOLUTION_RH12_TEMP14  ::= 0x00
  static REG_RESOLUTION_RH8_TEMP12   ::= 0x01
  static REG_RESOLUTION_RH10_TEMP13  ::= 0x80
  static REG_RESOLUTION_RH11_TEMP11  ::= 0x81
  static REG_END_OF_BATTERY          ::= 0x40
  static REG_HEATER_ENABLED          ::= 0x04
  static REG_DISABLE_OTP_RELOAD      ::= 0x02
  static MAX_WAIT                    ::= 100
  static DELAY_INTERVAL              ::= 10
  static SHIFTED_DIVISOR             ::= 0x988000

  stemp/float := 0.00
  shum/float := 0.00

  device_/i2c.Device

  constructor .device_:
    initialize
  
  initialize:
    reset
    sleep --ms=1

  reset:
    write_simple_command SOFT_RESET
    sleep --ms=10

  read_temperature -> float:
    write_simple_command TRIGGER_TEMP_MEASURE_NOHOLD
    sleep --ms=85

    data := device_.read 3
    
    // crc does not work yet
    //if data[2] != (crc8_ data[0..1]):
    //  return  -100.0
    
    //Raw temperature reading
    raw_stemp := data[0]
    raw_stemp <<= 8
    raw_stemp |= data[1]
    raw_stemp &= 0xFFFC;
    
    //Raw to physical temperature value (°C)
    stemp = raw_stemp*175.72
    stemp = stemp / 65536.0
    stemp = -46.85 + stemp
    
    return stemp
  
  read_humidity -> float:
    //write_command TRIGGER_HUMD_MEASURE_NOHOLD
    write_simple_command TRIGGER_HUMD_MEASURE_NOHOLD
    sleep --ms=29

    data := device_.read 3
    
    // crc does not work yet
    //if data[2] != (crc8_ data[0..2]):
    //  return  -100.0

    //Raw humidity reading
    raw_shum := data[0]
    raw_shum <<= 8
    raw_shum |= data[1]
    raw_shum &= 0xFFFC;
    
    //Raw to physical humidity value (%)
    shum = raw_shum*125.0
    shum = shum / 65536.0    
    shum = -6.0 + shum
    return shum


  static crc8_ data/ByteArray -> int:
    crc := 0xff
    data.do:
      crc ^= it;
      8.repeat:
        if crc & 0x80 != 0:
          crc = ((crc << 1) ^ 0x31) & 0xff
        else:
          crc <<= 1;
          crc &= 0xff
    return crc

    
  /**
  Break the 16-bit command into 8-bit commands and write into device
  */
  write_simple_command command/int:
    cmd/ByteArray := #[0x00]

    cmd[0] = command
    device_.write cmd