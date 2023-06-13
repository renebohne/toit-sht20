# toit-sht20

Toit driver for SHT20 Digital Temperature and Humidity Sensor

# Installation

```bash
toit pkg sync

toit pkg install github.com/renebohne/toit-sht20
```

# Usage

```toit
import i2c
import gpio
import sht20

main:
    bus := i2c.Bus
      --sda=gpio.Pin 0
      --scl=gpio.Pin 26

    device := bus.device sht20.SHT20Driver.I2C_ADDRESS

    driver := sht20.SHT20Driver device
    
    while true:
      print "$driver.read_temperature C"
      print "$driver.read_humidity %"
      sleep --ms=1000
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].
[tracker]: https://github.com/renebohne/toit-sht20/issues

# Credits 

This library is inspired by https://github.com/RobTillaart/SHT2x and https://github.com/harshkc03/sht31-d_driver

