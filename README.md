# 6502 NES Game

This project is a NES game written in 6502 Assembly Language. To run the game, simply open ```game.nes``` in a NES Emulator (I use [FCEUX-2.2.3](http://www.fceux.com/web/home.html)).

The game is written in 6502 assembly language, and there is a [wiki](http://wiki.nesdev.com/w/index.php/Nesdev_Wiki) containing everything you need to start programming, such as instruction set, memory map, interrupt vector and more.

The code is assembled and linked using ```ca65``` and ```ld65```, both from the [cc65](https://www.cc65.org/) project. If you have it installed, just run the ```make``` command, and it will assemble the code, and then link it using the ```nes.cfg``` file.
