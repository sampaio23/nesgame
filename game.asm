;;; Some instructions ;;;;;
; LDX: load x
; STX: store x
; SEI: set interrupt disable
; CLD: clear decimal
; TXS: transfer X to stack pointer
;;;

; Variables

char_vel_x	=	$0001
char_vel_y	=	$0002

;;; Important Registers

; PPU

PPU_CTRL    =   $2000
PPU_MASK    =   $2001
PPU_STATUS  =   $2002
OAM_ADDR    =   $2003
OAM_DATA    =   $2004
PPU_SCROLL  =   $2005
PPU_ADDR    =   $2006
PPU_DATA    =   $2007
OAM_DMA     =   $4014

; APU

SQ1_VOL     =   $4000
SQ1_LO      =   $4002
SQ1_HI      =   $4003
APU_STATUS  =   $4015

; CONTROLLER INPUT

JOY1        =   $4016


.segment "HEADER"
	.byte 	"NES", $1A
	.byte 	2
	.byte	1
	.byte 	$01, $00

.segment "STARTUP"


.segment "CODE"

reset:
	sei			; disable IRQs
	cld			; disable decimal mode
;	ldx #$40
;	stx $4017	; disable APU frame IRQ
	ldx #$FF
	txs			; set up stack
	inx			; now X = 0
	lda PPU_STATUS
	ldx #%00000000
	stx	PPU_CTRL	; disable NMI
	ldx #%00000000
	stx PPU_MASK	; disable rendering
;	stx $4010	; disable DMC IRQs

	lda PPU_STATUS	; PPU warm up
vblankwait1:	; First wait for vblank to make sure PPU is ready
	bit PPU_STATUS	; PPU status register
	bpl vblankwait1

vblankwait2:
	bit PPU_STATUS
	bpl vblankwait2

	lda #$00
	ldx #$00
clear_memory:
	sta $0000, X
	sta $0100, X
	sta $0200, X
	sta $0300, X
	sta $0400, X
	sta $0500, X
	sta $0600, X
	sta $0700, X
	inx
	cpx #$00
	bne clear_memory


; Loading nametable
	lda PPU_STATUS 	; reading PPUSTATUS
	lda #$20	; writing 0x2000 in PPUADDR to write on PPU, the address for nametable 0
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	lda #<background_nametable	; saving nametable in RAM
	sta $0000
	lda #>background_nametable
	sta $0001
	ldx #$00
	ldy #$00

nametable_loop:
	lda ($00), Y
	sta PPU_DATA
	iny
	cpy #$00
	bne nametable_loop
	inc $0001
	inx
	cpx #$04	; size of nametable 0: 0x0400
	bne nametable_loop

; Color setup for background
	lda PPU_STATUS
	lda #$3F	; writing 0x3F00, pallete RAM indexes
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	ldx #$00

background_color_loop:
	lda background_pallete, X
	sta PPU_DATA
	inx
	cpx #$10	; size of pallete RAM: 0x0020, until 0x3F10 is background palletes
	bne background_color_loop	; after 0x3F10, there should be sprite palletes

; Sprites color setup
	lda PPU_STATUS
	lda #$3F
	sta PPU_ADDR
	lda #$10
	sta PPU_ADDR
	ldx #$00
sprite_color_loop:
	lda background_pallete, X
	sta PPU_DATA
	inx
	cpx #$10
	bne sprite_color_loop

; Code for reseting scroll
	lda #$00
	sta PPU_SCROLL
	lda #$00
	sta PPU_SCROLL

; Turning on NMI and rendering
	lda #%10010000
	sta PPU_CTRL	; PPUCTRL
	lda #%00011010	; show background
	sta PPU_MASK	; PPUMASK, controls rendering of sprites and backgrounds

; Let's try some audio
	
; enable apu
	lda #%00000001
	sta APU_STATUS

	lda #$01
	sta char_vel_x

forever:
	
; Reading input data

	lda #$01
	sta JOY1
	lda #$00
	sta JOY1

; Order: A B Select Start Up Down Left Right
; only one bit is read at a time, so we have to read JOY1 eight times

; A
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne A_not_pressed

A_not_pressed:

; B
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne B_not_pressed

B_not_pressed:

; Select
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Select_not_pressed

Select_not_pressed:

; Start
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Start_not_pressed

Start_not_pressed:

; Up
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Up_not_pressed

	dec char_vel_y

Up_not_pressed:

; Down
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Down_not_pressed

	inc char_vel_y

Down_not_pressed:

; Left
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Left_not_pressed
	
	dec char_vel_x

Left_not_pressed:

; Right
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Right_not_pressed

	inc char_vel_x

Right_not_pressed:

	jmp	forever

nmi:

nmi_sprites:
	lda #$00
	sta OAM_ADDR
	lda #$02
	sta OAM_DMA

;; Draw character

	lda #$08      ; Top of the screen
	clc
	adc char_vel_y
  	sta $0200     ; Sprite 1 Y Position
  	lda #$08
	clc
	adc char_vel_y
  	sta $0204     ; Sprite 2 Y Position
  	lda #$10
	clc
	adc char_vel_y
  	sta $0208     ; Sprite 3 Y Position
  	lda #$10
	clc
	adc char_vel_y
  	sta $020C     ; Sprite 4 Y Position

  	lda #$3A      ; Top Left section of Mario standing still
  	sta $0201     ; Sprite 1 Tile Number
  	lda #$37      ; Top Right section of Mario standing still
 	sta $0205     ; Sprite 2 Tile Number
  	lda #$4F      ; Bottom Left section of Mario standing still
  	sta $0209     ; Sprite 3 Tile Number
  	lda #$4F      ; Bottom Right section of Mario standing still
  	sta $020D     ; Sprite 4 Tile Number
  	lda #$00		; No attributes, using first sprite palette which is number 0
  	sta $0202     ; Sprite 1 Attributes
  	sta $0206     ; Sprite 2 Attributes
  	sta $020A     ; Sprite 3 Attributes
  	lda #$40      ; Flip horizontal attribute
  	sta $020E     ; Sprite 4 Attributes

  	lda #$08      ; Left of the screen.
	clc
	adc char_vel_x
  	sta $0203     ; Sprite 1 X Position
  	lda #$10
	clc
  	adc char_vel_x
	sta $0207     ; Sprite 2 X Position
  	lda #$08
	clc
  	adc char_vel_x
	sta $020B     ; Sprite 3 X Position
 	lda #$10
	clc
  	adc char_vel_x
	sta $020F     ; Sprite 4 X Position

	rti

irq:
	rti

play_a440:
	pha
	lda #%10011111
	sta SQ1_VOL

;	lda #%11111101	; Low: 0xFD
;	sta SQ1_LO

;	lda #%11111000	; High: 0x00
;	sta SQ1_HI

	ldx #$27
	lda periodTableLo, X
	sta SQ1_LO

	lda periodTableHi, X
	ora #%10011000
	sta SQ1_HI

	pla
	rts

play_a220:
	pha
	lda #%10011111
	sta SQ1_VOL
	lda #%11111011
	sta SQ1_LO

	lda #%11111001
	sta SQ1_HI

	pla
	rts

periodTableLo:
	.byte $F1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34
	.byte $F8,$BF,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a
	.byte $FB,$DF,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c
	.byte $FD,$EF,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86
  	.byte $7E,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42
  	.byte $3F,$3B,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21
  	.byte $1F,$1D,$1b,$1a,$18,$17,$15,$14
periodTableHi:
  	.byte $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
  	.byte $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
  	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
  	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  	.byte $00,$00,$00,$00,$00,$00,$00,$00

background_nametable:
	.incbin "backgrounds/bk1.nam"

background_pallete:
	.incbin "backgrounds/bag.pal"


;.segment "RODATA"

.segment "VECTORS"
	.word nmi		; when non-maskable interrupt happens, goes to label nmi
	.word reset		; when the processor first turns on or is reset, goes to reset
	.word irq		; using external interrupt IRQ

.segment "CHARS"
	.incbin "chr/mario.chr"	; includes 8KB graphics
