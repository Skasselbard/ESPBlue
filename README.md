# ESPBlue
Link the ESP8266 ESP-01 with Rust on the Blue Pill  
Tested Environment: Ubuntu 18.04.2 LTS

# Setup ESP
- [Build the firmware](https://nodemcu.readthedocs.io/en/master/build/)
    - the [cloud build](https://nodemcu-build.com/) works very easy out of the box
    - important modules:
        - File
        - WiFi
        - UART
        - MQTT
        - timer
    - helpful modules:
        - HTTP
        - Net
        - TLS/SSL
- [Flash the firmware](https://nodemcu.readthedocs.io/en/master/flash/)
    - get a functioning flasher
        - I had connection timeouts with a common model
        - switching to another model ([this one](https://www.amazon.com/UJuly-OPEN-SMART-ESP8266-ESP-01-Adapter/dp/B07DL6KKQP)) solved the problem
    - install esptool: ``sudo apt install esptool``
    - run the flash script
- deploy the firmware extending lua scripts with the deployESP script
    - requires ``pip3 install pyserial``
# Links
## ESP
- [Node MCU Firmware Documentation](https://nodemcu.readthedocs.io/en/master/)

## Blue Pill