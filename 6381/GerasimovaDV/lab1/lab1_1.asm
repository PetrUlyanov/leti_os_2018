TESTPC	   SEGMENT
	   ASSUME  CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
	   ORG	   100H
START:	   JMP	   BEGIN

; ������:
; �������⥫�� �����
EOF	EQU '$'	; ��।������ ᨬ���쭮� ����⠭��
; ����� IBM PC
_type 	db '��� IMB PC ',EOF
_PC 		db 'PC',0DH,0AH,EOF
_PC_XT 	db 'PC/XT',0DH,0AH,EOF
_AT 		db 'AT',0DH,0AH,EOF
_PS2_30 	db 'PS2 ������ 30',0DH,0AH,EOF
_PS2_50_60 	db 'PS2 ������ 50 ��� 60',0DH,0AH,EOF
_PS2_80 	db 'PS2 ������ 80',0DH,0AH,EOF
_PCjr 	db 'PCjr',0DH,0AH,EOF
_PC_Conv db 'PC Convertible',0DH,0AH,EOF
; ����� MS DOS
_ver		db '����� ���ᨨ MS DOS:  .    ',0DH,0AH,EOF
_oem		db '��਩�� ����� OEM:    ',0DH,0AH,EOF
_user	db '��਩�� ����� ���짮��⥫�:      ',0DH,0AH,EOF

; ���������:
TETR_TO_HEX PROC near

	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT:	add AL,30h
	ret
TETR_TO_HEX ENDP

BYTE_TO_HEX PROC near
;���� AL ��ॢ������ � ��� ᨬ���� ���. �᫠ � AX
	push CX
	mov AH,AL
	call TETR_TO_HEX
	xchg AL,AH
	mov CL,4
	shr AL,CL
	call TETR_TO_HEX  ;� AL - �����, � AH - ������
	pop CX
	ret
BYTE_TO_HEX ENDP

WRD_TO_HEX PROC near
;��ॢ�� � 16 �/� 16-� ࠧ�來��� �᫠
;� AX - �᫮, DI - ���� ��᫥����� ᨬ����
	push BX
	mov BH,AH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	dec DI
	mov AL,BH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	pop BX
	ret
WRD_TO_HEX ENDP

BYTE_TO_DEC PROC near
;��ॢ�� � 10�/�, SI - ���� ���� ����襩 ����
	push CX
	push DX
	xor AH,AH
	xor DX,DX
	mov CX,10
loop_bd: div CX
	or DL,30h
	mov [SI],DL
	dec SI
	xor DX,DX
	cmp AX,10
	jae loop_bd
	cmp AL,00h
	je end_l
	or AL,30h
	mov [SI],AL
end_l:	pop DX
	pop CX
	ret
BYTE_TO_DEC ENDP

; �㭪�� ��।������ ⨯� IMB PC
TYPE_IMB_PC PROC NEAR
  push ds
	mov ax, 0F000h
	mov ds, ax
	sub bx, bx
	mov bh, [0FFFEh]
  pop ds
	ret
TYPE_IMB_PC ENDp

; �㭪�� ��।������ ���ᨨ MS DOS (al)
VERS_DOS PROC NEAR
	push ax
	push si

	mov si, offset _ver
	add si, 15h
	call BYTE_TO_DEC

	mov si, offset _ver
	add si, 17h
	mov al, ah
	call BYTE_TO_DEC
	pop si
	pop ax
	ret
VERS_DOS ENDP

; �㭪�� ���������� �਩���� ����� OEM (bh)
OEM_DOS PROC NEAR
	push ax
	push bx
	push si

	mov si, offset _oem
	add si, 16h
	mov al, bh
	call BYTE_TO_DEC

	pop si
	pop bx
	pop ax
	ret
OEM_DOS ENDP

; �㭪�� ��।������ �਩���� ����� ���짮��⥫� (bl:cx)
USER_DOS PROC NEAR
	push bx
	push cx
	push di
	push ax

	mov di, offset _user
	add di, 22h
	mov ax, cx
	call WRD_TO_HEX

	mov al, bl
	call BYTE_TO_HEX
	mov di, offset _user
	add di, 1Dh
	mov [di], ax

	pop ax
	pop di
	pop cx
	pop bx
  ret
USER_DOS ENDP

; �㭪�� �뢮�� �� ��࠭
PRINT PROC NEAR
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
PRINT ENDP

; ���
BEGIN:
	; ��뢠�� �㭪�� ��।������ ⨯� IBM PC
	call TYPE_IMB_PC

	; �뢮� ������饩 ��ப�
	mov dx, offset _type
	call PRINT

	; ��।��塞 �� �।��᫥����� ���� ROM BIOS ⨯ IBM PC
	; �।���⥫쭮 ����㦠�� ᬥ饭�� ��।��񭭮�� ⨯�
	; � � ��砥 �ᯥ� - �뢮��� ⨯ �� ��࠭
	mov dx, offset _PC
	cmp bh, 0FFh
	je	to_print

	mov dx, offset _PC_XT
	cmp bh, 0FEh
	je	to_print

  mov dx, offset _PC_XT
  cmp bh, 0FBh
  je	to_print

	mov dx, offset _AT
	cmp bh, 0FCh
	je	to_print

	mov dx, offset _PS2_30
	cmp bh, 0FAh
	je	to_print

	mov dx, offset _PS2_50_60
	cmp bh, 0FCh
	je	to_print

	mov dx, offset _PS2_80
	cmp bh, 0F8h
	je	to_print

	mov dx, offset _PCjr
	cmp bh, 0FDh
	je	to_print

	mov dx, offset _PC_Conv
	cmp bh, 0F9h
	je	to_print

 	mov al, bh
 	call BYTE_TO_HEX
	mov dx, ax

	; ��뢠�� �㭪�� �뢮�� �� ��࠭
to_print:
	call PRINT

	; ��뢠�� �㭪�� ��।������ ���ᨨ MS DOS
	mov ah, 30h
  int 21h

	; ��࠭塞 ����祭�� ���祭��
	call VERS_DOS
	call OEM_DOS
  call USER_DOS

	; �뢮��� ����祭�� ���祭��
	mov dx, offset _ver
	call PRINT
	mov dx, offset _oem
	call PRINT
	mov dx, offset _user
	call PRINT
; ��室 � DOS
	xor al, al
	mov ah, 4ch
	int 21h
  TESTPC     ENDS
		END START	; ����� �����
