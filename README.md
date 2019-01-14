# 6502 NES Game

This project is a NES game written in 6502 Assembly Language. To run the game, simply open ```game.nes``` in a NES Emulator (I use [FCEUX-2.2.3](http://www.fceux.com/web/home.html)).

The game is written in 6502 assembly language, and there is a [wiki](http://wiki.nesdev.com/w/index.php/Nesdev_Wiki) containing everything you need to start programming, such as instruction set, memory map, interrupt vector and more.

The code is assembled and linked using ```ca65``` and ```ld65```, both from the [cc65](https://www.cc65.org/) project. If you have it installed, just run the ```make``` command, and it will assemble the code, and then link it using the ```nes.cfg``` file.

For tile editing, I use [NES Screen Tool](http://forums.nesdev.com/viewtopic.php?t=7237), because it has lots of features (for instance, I can export namepages automatically to address to the CHR file).

## Progress and References

### Basic code skeleton

[6502 Opcodes](http://www.6502.org/tutorials/6502opcodes.html)

[Programming Basics](https://wiki.nesdev.com/w/index.php/Programming_Basics)

[PPU Power Up State](https://wiki.nesdev.com/w/index.php/PPU_power_up_state)

[CPU Memory Map](https://wiki.nesdev.com/w/index.php/CPU_memory_map)

### Draw a background - PPU

[Background example](http://forums.nesdev.com/viewtopic.php?f=10&t=15648)

[PPU Registers](https://wiki.nesdev.com/w/index.php/PPU_registers)

[PPU Memory Map](https://wiki.nesdev.com/w/index.php/PPU_memory_map)

It's important to read about [NMI](https://wiki.nesdev.com/w/index.php/NMI) and [PPU Frame Timing](https://wiki.nesdev.com/w/index.php/PPU_frame_timing) and learn good practices about graphic update during NMI.

The first background is a simple platform.

![](https://github.com/sampaio23/nesgame/blob/master/images/background.png)

### Play some audio - APU

[Audio Example](https://safiire.github.io/blog/2015/03/29/creating-sound-on-the-nes/)

[APU Registers](https://wiki.nesdev.com/w/index.php/APU_registers)

I used a [period table](http://wiki.nesdev.com/w/index.php/APU_period_table) to have notes on the fly. The link shows how to get one (or just copy) and a good example on how to use is [here](http://blargg.8bitalley.com/parodius/nes-code/apu_scale.s).

### Draw a Sprite

[Sprite Example](http://forums.nesdev.com/viewtopic.php?f=10&t=15647)

[PPU OAM](http://wiki.nesdev.com/w/index.php/PPU_OAM)

PPUCTRL ($2000) and PPUMASK ($2001) had to be changed in order to load sprites too.

![](https://github.com/sampaio23/nesgame/blob/master/images/1sprite.png)

Using OAM DMA ($4014), one can load 256 bytes of sprites, and now it's possible to draw more than one sprite faster.

![](https://github.com/sampaio23/nesgame/blob/master/images/2sprite.png)

[OAM DMA Example](http://www.vbforums.com/showthread.php?858523-NES-6502-Programming-Tutorial-Part-3-Drawing-a-Sprite)

### Get controller input and move the character

Reading controller input is done through $4016 and $4017.

[Reading Input Example](http://forums.nesdev.com/viewtopic.php?f=10&t=15645)

[Controller Reading](http://wiki.nesdev.com/w/index.php/Controller_Reading)

[Controller Port Registers](http://wiki.nesdev.com/w/index.php/Controller_port_registers)

Now it's possible to move the sprite (character) based on controller input.

### Play a song for the game

Not done yet. References until now:

[APU DMC](https://wiki.nesdev.com/w/index.php/APU_DMC)
[DMC Usage](http://nesdev.com/dmc.txt)
[IRQ](https://wiki.nesdev.com/w/index.php/IRQ)

### Future Work

* Add gravity and make movement better
* Play a sound for jump
* Move background