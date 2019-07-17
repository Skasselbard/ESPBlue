#!/bin/python3

import subprocess
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("firmware", help="File of the Firmware")
parser.add_argument("-f", nargs='?', help="flashmode [keep|qio|qout|dio|dout]")
parser.add_argument("-p", nargs='?', help="serial device e.g. /dev/ttyUSB0")
args = parser.parse_args()

if args.p == None:
    args.p = "/dev/ttyUSB0"
if args.f == None:
    args.f = "qio"

subprocess.run(
    str.format(
        'esptool --port {} write_flash -fm {} 0x00000 {}',
        args.p,
        args.f,
        args.firmware
    ).split(' '), check=True
)
