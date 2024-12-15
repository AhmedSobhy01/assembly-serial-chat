import os
import subprocess
from time import sleep

for file in os.listdir():
    file = file.lower()
    if (
        file.endswith(".exe")
        or file.endswith(".obj")
        or file.endswith(".lst")
        or file.endswith(".conf")
    ):
        os.remove(file)

filedata = r"""
[sdl]
fullscreen=false
fulldouble=false
fullresolution=original
windowresolution=original
output=surface
autolock=true
sensitivity=100
waitonerror=true
priority=higher,normal
mapperfile=mapper-0.74-3.map
usescancodes=true
[dosbox]
machine=svga_s3
captures=capture
memsize=16
[render]
frameskip=0
aspect=false
scaler=normal2x
[cpu]
core=auto
cputype=auto
cycles=auto
cycleup=10
cycledown=20
[dos]
xms=true
ems=true
umb=true
keyboardlayout=auto
[ipx]
ipx=false
[autoexec]
mount C C:\8086
set PATH=%PATH%;C:
MOUNT D --path--
D:
masm chat.asm;
link chat.obj;
chat.exe
"""


if os.path.exists("dosbox-x-generated1.conf"):
    os.remove("dosbox-x-generated1.conf")

filedata1 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM1
serial2=dummy
serial3=disabled
serial4=disabled
    """
)
filedata1 = filedata1.replace("--path--", os.getcwd())

with open("dosbox-x-generated1.conf", "w") as file:
    file.write(filedata1)


if os.path.exists("dosbox-x-generated2.conf"):
    os.remove("dosbox-x-generated2.conf")

filedata2 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM2
serial2=dummy
serial3=disabled
serial4=disabled
    """
)
filedata2 = filedata2.replace("--path--", os.getcwd())

with open("dosbox-x-generated2.conf", "w") as file:
    file.write(filedata2)

prog1 = ["C:\DOSBox-X\dosbox-x.exe", "-conf", "dosbox-x-generated1.conf"]
prog2 = ["C:\DOSBox-X\dosbox-x.exe", "-conf", "dosbox-x-generated2.conf"]

subprocess.Popen(prog1)
sleep(2)
subprocess.Popen(prog2)
