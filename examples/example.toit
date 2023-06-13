// Copyright (C) 2023 René Gern.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

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
