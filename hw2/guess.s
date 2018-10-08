.code16 # Use 16-bit assembly
.globl start # This tells the linker where we want to start executing

start:
	movw $message, %si # load the offset of our message into %si
	movb $0x00,%ah # 0x00 - set video mode
	movb $0x03,%al # 0x03 - 80x25 text mode
	int $0x10 # call into the BIOS
	call rand #load a random number
	call print_char
read_char:
	movb $0x00,%ah #0x00 is the BIOS code to read a single character
	int $0x16 #call int the BIOS to wait for character input (software interrupt)
	jmp check_num #check if the inputted char is a number digit character (0-9)
echo_char:
	movb $0x0E,%ah #set the BIOS to print the inputted character
	int $0x10 #print the inputted character
	sub $0x30,%al #convert the ASCII number to the real value by subtracting by 0 ascii (0x30)
	cmp %dl,%al #check if the selected value is the same as the actual number
	jz success #if it is, print success message and be done
	jmp wrong #if not, ask again
check_num:
	cmpb $0x30,%al #check if the inputted char is a below ASCII numbers value (<0x30)
	js read_char #if not read again
	cmpb $0x3A,%al #check if the inputted char is a above ASCII numbers values (>0x39)
	jns read_char #if not read again
	jmp echo_char #if it is a number, echo back the input so the user can see
success:
	call newline #print newline
	movw $success_message, %si #load success message
	call print_char #print the success message
	jmp done #exit program
wrong:
	call newline #print newline
	movw $error_message, %si #load error message
	call print_char #print error message
	call newline #print newline
	movw $message, %si #load prompt
	call print_char #print prompt
	jmp read_char #jump to read character
done:
	jmp done # loop forever
newline:
	movb $0x0A,%al #newline
	int $0x10 #print newline char
	movb $0x0D,%al #carriage return
	int $0x10 #print carriage return char
	ret
rand :
	movb $0x00,%al #desired register: 0x00 for the seconds
	outb $0x70 #select seconds register from cmos clock
	inb $0x71 #load current seconds into the %al register
	movb %al,%dl #ove loaded value into %dl
mod: #find the number of seconds mod 10 for a number 0 - 9
	cmpb $0x0A,%dl #check if %dl is less than 10
	jl return #if so, return %dl
	sub $0x0A,%dl #if not subtract 10 from dl
	jmp mod #loop
print_char:
	lodsb # loads a single byte from (%si) into %al and increments %si
	testb %al,%al # checks to see if the byte is 0
	jz return # if so, jump out (jz jumps if ZF in EFLAGS is set)
	movb $0x0E,%ah # 0x0E is the BIOS code to print the single character
	int $0x10 # call into the BIOS using a software interrupt
	jmp print_char # go back to the start of the loop
return:
	ret #return from function

# String constants
message:
	.string "What number am I thinking of (0-9)? "
success_message:
	.string "Right! Congratulations."
error_message:
	.string "Wrong! "

# Fill file with 0 bits
.fill 510 - (. - start), 1, 0
.byte 0x55
.byte 0xAA
