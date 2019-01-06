;;; Some instructions ;;;;;
; LDX: load x
; STX: store x
; SEI: set interrupt disable
; CLD: clear decimal
; TXS: transfer X to stack pointer
;;;

; Variables


; Character
sprite_Y		=	$0200
sprite_tile		=	$0201
sprite_att		=	$0202
sprite_X		=	$0203

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
	lda $2002
	ldx #%00000000
	stx	$2000	; disable NMI
	ldx #%00000000
	stx $2001	; disable rendering
;	stx $4010	; disable DMC IRQs

	lda $2002	; PPU warm up
vblankwait1:	; First wait for vblank to make sure PPU is ready
	bit $2002	; PPU status register
	bpl vblankwait1

vblankwait2:
	bit $2002
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
	lda $2002 	; reading PPUSTATUS
	lda #$20	; writing 0x2000 in PPUADDR to write on PPU, the address for nametable 0
	sta $2006
	lda #$00
	sta $2006
	lda #<background_nametable	; saving nametable in RAM
	sta $0000
	lda #>background_nametable
	sta $0001
	ldx #$00
	ldy #$00

nametable_loop:
	lda ($00), Y
	sta $2007
	iny
	cpy #$00
	bne nametable_loop
	inc $0001
	inx
	cpx #$04	; size of nametable 0: 0x0400
	bne nametable_loop

; Color setup for background
	lda $2002
	lda #$3F	; writing 0x3F00, pallete RAM indexes
	sta $2006
	lda #$00
	sta $2006
	ldx #$00

background_color_loop:
	lda background_pallete, X
	sta $2007
	inx
	cpx #$10	; size of pallete RAM: 0x0020, until 0x3F10 is background palletes
	bne background_color_loop	; after 0x3F10, there should be sprite palletes

; Sprites color setup
	lda $2002
	lda #$3F
	sta $2006
	lda #$10
	sta $2006
	ldx #$00
sprite_color_loop:
	lda background_pallete, X
	sta $2007
	inx
	cpx #$10
	bne sprite_color_loop

; Load our sprite to RAM
load_sprites:
	ldx #$00
load_sprites_loop:
	lda sprites00, X
	sta $0200, X
	inx
	cpx #$04
	bne load_sprites_loop

; Code for reseting scroll
	lda #$00
	sta $2005
	lda #$00
	sta $2005

; Turning on NMI and rendering
	lda #%10010000
	sta $2000	; PPUCTRL
	lda #%00011010	; show background
	sta $2001	; PPUMASK, controls rendering of sprites and backgrounds

; Let's try some audio
	
; enable apu
	lda #%00000001
	sta $4015

forever:
	jmp	forever

nmi:
	jsr nmi_sprites
	rti

nmi_sprites:
	lda #$00
	sta $2003
	lda #$02
	sta $4014
;	lda sprite_Y
;	sta $2004
;	lda sprite_tile
;	sta $2004
;	lda sprite_att
;	sta $2004
;	lda sprite_X
;	sta $2004
	inc sprite_X
	rts

irq:
	rti

play_a440:
	pha
	lda #%10011111
	sta $4000

;	lda #%11111101	; Low: 0xFD
;	sta $4002

;	lda #%11111000	; High: 0x00
;	sta $4003

	ldx #$27
	lda periodTableLo, X
	sta $4002

	lda periodTableHi, X
	ora #%10011000
	sta $4003

	pla
	rts

play_a220:
	pha
	lda #%10011111
	sta $4000
	lda #%11111011
	sta $4002

	lda #%11111001
	sta $4003

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

sprites00:
	.byte $80, $08, %00000000, $80
;sprites10:
;	.byte $81, $09, %00000000, $80
;sprites01:
;	.byte $82, $16, %00000000, $80
;sprites11:
;	.byte $83, $17, %00000000, $80

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
