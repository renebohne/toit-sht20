# SHT20

Toit driver for SHT20 Digital Temperature and Humidity Sensor.

# Installation

```bash
toit pkg install github.com/renebohne/toit-sht20
```

# Usage

```toit
import i2c
import gpio
import sht20 show *

main:
    bus := i2c.Bus
        --sda=gpio.Pin 0
        --scl=gpio.Pin 26

    device := bus.device Sht20.I2C_ADDRESS

    sensor := Sht20 device

    while true:
      print "$sensor.read_temperature C"
      print "$sensor.read_humidity %"
      sleep --ms=1000
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/renebohne/toit-sht20/issues

# Credits

This library is inspired by https://github.com/RobTillaart/SHT2x and https://github.com/harshkc03/sht31-d_driver
