#!/bin/python3

import argparse
import os
import serial
import time
import shutil


def executeCommand(device, baudRate, command):
    """ execute commants over UART """
    s = serial.Serial(device)
    s.baudrate = baudRate
    line = command+"\r\n"  # add a newline to finish the command
    s.write(line.encode())
    # print the answer
    answer = s.readline().decode('ascii', 'backslashreplace')
    time.sleep(0.01)  # wait for additional output
    while True:
        bytesToRead = s.inWaiting()
        answer = answer + \
            s.read(bytesToRead).decode('ascii', 'backslashreplace')
        if bytesToRead == 0:
            answer = answer[:-3]  # trim the newline and the promt ('>')
            print("answer: " + answer)
            break


def sendFile(filePath, device, baudRate):
    fileName = os.path.basename(filePath)
    openCommand = str.format('file.open("{}","w+")', fileName)
    executeCommand(device, baudRate, openCommand)
    f = open(filePath)
    for line in f:
        line = line.replace("\n", "")       # remove \n
        line = line.replace("\\", "\\\\")   # escape backslashes (first!)
        line = line.replace("\"", "\\\"")   # escape double quotes
        line = line.replace("\'", "\\\'")   # escape single quotes
        writeCommand = str.format(
            'file.writeline("{}")', line)  # send the line
        executeCommand(device, baudRate, writeCommand)
    f.close()
    executeCommand(device, baudRate, "file.close()")


parser = argparse.ArgumentParser()
parser.add_argument(
    "wifi_ssid", help="SSID used to connect to an access point")
parser.add_argument("wifi_password", help="password for the wifi")
parser.add_argument(
    "mqtt_name", help="name that the device should use in the mqtt network")
parser.add_argument(
    "device", help="UART interface like /dev/ttyUSB0")
args = parser.parse_args()

# create temp folder and copy all files
tmpdir = "tmp"
if not os.path.exists(tmpdir):
    os.mkdir(tmpdir)
for file in os.listdir("ESP_LUA_extensions"):
    shutil.copy("ESP_LUA_extensions/" + file, tmpdir)

# search and replace configuration keys
wifi_lua = open("ESP_LUA_extensions/wifi.lua", 'rt')
wifi_tmp = open("tmp/wifi.lua", 'wt')
wifi_code = wifi_lua.read()
wifi_code = wifi_code.replace('{ssid}', args.wifi_ssid)
wifi_code = wifi_code.replace('{pwd}', args.wifi_password)
wifi_tmp.write(wifi_code)
wifi_lua.close()
wifi_tmp.close()

mqtt_lua = open("ESP_LUA_extensions/mqtt.lua", 'rt')
mqtt_tmp = open("tmp/mqtt.lua", 'wt')
mqtt_code = mqtt_lua.read()
mqtt_code = mqtt_code.replace('{name}', args.mqtt_name)
mqtt_tmp.write(mqtt_code)
mqtt_lua.close()
mqtt_tmp.close()

baudrate = 115200
# delete the current init.lua to avoid bootloops
executeCommand(args.device, baudrate, 'file.remove("init.lua")')
# collect lua files
files = [
    tmpdir + "/" + f for f in os.listdir(tmpdir)
    if os.path.isfile(os.path.join(tmpdir, f)) and os.path.splitext(f)[1] == ".lua"
]
# transmitt files
print("Transmitting " + str(len(files)) + " files")
for f in files:
    print("\n<<<" + f + ">>>")
    sendFile(f, args.device, baudrate)

# delete files
shutil.rmtree(tmpdir)
