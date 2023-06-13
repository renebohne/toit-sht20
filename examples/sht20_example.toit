// Copyright (C) 2023 René Gern. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

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
    