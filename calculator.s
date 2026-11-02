; to do

; buzzer addition


; history addition
; whenever an answer is calculated, add it to a new stack
; whenever a button is pressed, move the pointer, need to check if you can (can check light)
; display the number there, loading value into operand 2
; check whether the pointer can move which way

; check when one of the buttons is being pressed
; 

ORG &000

; initialise traffic lights
LDA light_init
STA &FFF

; reset all of the digits

; function that resets everything

reset_this_op 

LDA zero
STA digits_numbers
STA previous_code
STA digits_numbers
STA operand1
STA operand2
STA operation

; reset all the digits 
LDA store_opcode
ADD sp
STA initial_rd_stack_add

initial_load_rd_r LDA loop
LDA initial_load_rd_r
initial_rd_stack_add STP ; dummy instruction

LDA sp
ADD one
STA sp

; the function expectes temp_counter to be in the ACC when its called
LDA zero
SUB six
STA temp_counter

JMP rd

;##### DEFINE ALL VARIABLES #####

sp DEFW &0F00 ; address stack pointer
dsp DEFW &0F10 ; address of the bottom of the digit table

asp DEFW &0F20 ; answer stack address
answers DEFW &0000 ; number of answers in the stack
current_asp DEFW &0F20 ; the answer being looked at
last_history DEFW &0000


store_opcode DEFW &1000
add_opcode DEFW &2000
jump_opcode DEFW &4000

zero DEFW &0000
one DEFW &0001
two DEFW &0002
six DEFW &0006
ten DEFW &000A
max DEFW &FFFF

temp1 DEFW &0000

; args for checking what button has been pressed
current_code DEFW &0000
previous_code DEFW &FFFF

button_pressed DEFW &0000

counter DEFW &000F
temp_counter DEFW &0000

largest_number DEFW &8000 ; largest button on the keypad that corrosponds to a number
W_largest_number DEFW &0000

mul_op1 DEFW &0000
mul_op2 DEFW &0000
mul_res DEFW &0000

div_op1 DEFW &0000
div_op2 DEFW &0000
div_res DEFW &0000

address_checker DEFW &0FFB
first_digit_address DEFW &0FFA
last_digit_address DEFW &0FF5
digits_numbers DEFW &0000
digits_written DEFW &0000

light_init DEFW &000C
next_red DEFW &0004

prev_green DEFW &0010
prev_red DEFW &0008

next DEFW &0000 ; one when next is green
prev DEFW &0000 ; one when prev is green

operand1 DEFW &0000
operand2 DEFW &0000
operation DEFW &0000 ; default opertion is add

function_result DEFW &0000

working_calc_result DEFW &0000
calc_ans_current_divisor DEFW &0000

largest_digit_allowed DEFW &2710 ; 10000 in decimal 
; the max number is going to be 61439

;##### EVENT LOOP #####

; event loop
loop LDA &FF2 ; read from keypad
SUB previous_code
JNE button_not_held_down
JMP loop

button_not_held_down
LDA first_digit_address ; a number that will never be a possible code
STA previous_code

LDA &FF2 ; read from keypad again so that we can now process what has been pressed
JNE process

; read from simple buttons
LDA &FF0
JNE history

LDA first_digit_address
STA last_history ; reset last history

JMP loop

;##### RESET DIGITS FUNCTION #####
; inputs: temp_counter as the negation of the number of digits to be ovewritten

rd
; use how negative temp_counter is to calculate which digits to overwrite
; The more negative the temp_counter, the more digit to turn off
; We start by turning them off RTL this way
ADD address_checker ; this constant is one more than the address of the first digit
ADD store_opcode
STA rd_instruction

LDA ten ; something that should turn off the digit
rd_instruction STP ; dummy instruction

LDA temp_counter
ADD one
STA temp_counter

JGE rds_intiate_r

JMP rd

rds_intiate_r
; no return values
JMP return_function

;###### FUNCTION THAT HANDLES HISTORY BUTTONS #####
history
STA temp1

SUB last_history
JNE hist_not_held
JMP loop

hist_not_held
ADD last_history ; restore
SUB two
JNE cont_hist

; forward pressed

; check whether we can

LDA asp
ADD answers
SUB current_asp

SUB two ; sub overshoots by one + so that JGE can be used 

JGE next_poss ; if its good, return to loop
JMP loop ; negative, so go to the loop

next_poss JNE keep_next_g ; not zero means that there's  no stuff after

LDA &FFF
SUB one ; remove green
ADD next_red ; add red
STA &FFF

LDA next
SUB one 
STA next

keep_next_g

; do anything with prev lights?
LDA prev
JNE next_c_prev

; change to green
ADD one
STA prev

LDA &FFF 
ADD prev_green
SUB prev_red
STA &FFF

next_c_prev

;initialise temp_counter
LDA max
STA temp_counter

LDA two 
STA last_history

LDA current_asp
ADD one
STA current_asp

STA load_next_ans
load_next_ans STP ; dummy

JMP write_answer

cont_hist
ADD one
JNE loop

; back pressed
; check whether we can

LDA current_asp
SUB asp

SUB one ; so we can use JGE

JGE prev_poss
JMP loop

prev_poss JNE keep_prev_g

LDA &FFF
SUB prev_green
ADD prev_red
STA &FFF

LDA zero
STA prev

keep_prev_g

; do anything with next lights?
LDA next
JNE prev_c_next

; change to green
ADD one
STA next

LDA &FFF 
ADD one
SUB next_red
STA &FFF

prev_c_next

;initialise temp_counter
LDA max
STA temp_counter

LDA one 
STA last_history

LDA current_asp
SUB one
STA load_prev_ans

STA current_asp
load_prev_ans STP ; dummy

;ADD one ; we dont want to write the number before the pointer

JMP write_answer
JMP loop


;##### FUNCTION THAT DETERMINES WHICH BUTTON HAS BEEN PRESSED #####

; to see what number has been pressed, we need to try substracting
; each possible number until we get zero

; initialise variables
process STA current_code
STA previous_code

LDA largest_number
STA W_largest_number

LDA counter
STA temp_counter

find_number_loop

find_number LDA current_code
SUB W_largest_number

JNE process_divide_call
JMP process_button
; divide the subtracting number by 2
process_divide_call
LDA W_largest_number
STA div_op1

LDA two
STA div_op2

LDA store_opcode
ADD sp
STA process_d_stack_add

process_l_d_r LDA process_d_reset_r
LDA process_l_d_r
process_d_stack_add STP ; dummy instruction

LDA sp
ADD one
STA sp
JMP divide
process_d_reset_r 
STA W_largest_number

LDA temp_counter
SUB one
STA temp_counter

JNE find_number_loop
JMP process_button ; if the 0 button is pressed

;##### PROCESS BUTTON START #####

process_button
; check whether a digit or a letter
LDA temp_counter
SUB ten
JGE process_letter

;firstly build the address of the digit code that we need
;now add it to the number stack
LDA dsp
ADD digits_numbers
ADD store_opcode
STA process_button_add_number_stack

LDA temp_counter
process_button_add_number_stack STP ; dummy instruction that

LDA digits_numbers
ADD one
STA digits_numbers

; need to check whether this is the first digit they entered after entering an answer
SUB one
JNE not_first_digit

;we need to reset everything if it is 

LDA store_opcode
ADD sp
STA process_rd_stack_add

process_l_rd_r LDA process_rd_r
LDA process_l_rd_r
process_rd_stack_add STP ; dummy instruction

LDA sp
ADD one
STA sp

;set paremeters so that the function resets everything
; function expectes temp_counter to be in the ACC when its called
LDA zero
SUB six
STA temp_counter

JMP rd

process_rd_r
; read the digit from the stack, so that it can be written

LDA first_digit_address
ADD store_opcode
STA write_first_digit

;read the digit at the top of the stack

LDA dsp
STA read_first_digit
read_first_digit STP ; dummy instruction
write_first_digit STP ; dummy instruction

JMP loop

not_first_digit
LDA first_digit_address
SUB digits_numbers
ADD one ; because we add the number to the stack before writing

ADD store_opcode
STA process_button_digits_write
LDA temp_counter
process_button_digits_write STP ; dummy instruction
JMP loop

; given a number from zero to 6 corresponding to each of the letters in the board
; this is the ((number of the bit for each letter on the keypad) - 10 )
process_letter


SUB two ; now we check whether the equals button has been pressed
JNE assign_operation

; reset operand 2 
LDA zero
STA operand2

JMP calc_answer

assign_operation

; check if clear button has been pressed
SUB two
SUB one

JGE reset_this_op
ADD six
SUB one

STA operation
JMP loop

;##### RETURN FUNCTION #####
;returns to the address at the top of the address stack

return_function
LDA sp
SUB one
STA sp

; we build the instructions that will get the address on the stack and then jump to it

LDA add_opcode
ADD sp
STA add_pointer

LDA jump_opcode
add_pointer STP ; dummy instruction

STA return
LDA function_result
return STP ; dummy instruction


;##### CALCULATE ANSWER FUNCTION START #####
; use the numbers on the stack to load the added value into operand 2
; to read a number, it must read from the top of the stack to the bottom, multiplying by increasing powers of 10

calc_answer
LDA one
STA mul_op1

; OPERAND2 SHOULD BE 0
read_input_digits
LDA digits_numbers
JNE display_next_input_digit
; EVERYTHING HAS BEEN READ

JMP calculate_operation

;read the digit at the top of the stack
display_next_input_digit

SUB one ; get the top number from the stack
STA digits_numbers

ADD dsp
STA read_next_input_digit
read_next_input_digit STP ; dummy instruction

STA mul_op2

; MULTIPLY

LDA store_opcode
ADD sp
STA inputs_mul_stack_add

inputs_load_mul_r LDA input_mul_r
LDA inputs_load_mul_r
inputs_mul_stack_add STP ; dummy instruction

LDA sp
ADD one
STA sp
JMP mul

input_mul_r
ADD operand2
STA operand2

LDA ten
STA mul_op2

; MULTIPLY
LDA store_opcode
ADD sp
STA ten_mul_stack_add

ten_load_mul_r LDA ten_mul_r
LDA ten_load_mul_r
ten_mul_stack_add STP ; dummy instruction

LDA sp
ADD one
STA sp
JMP mul

ten_mul_r
STA mul_op1; so that this can be multiplied with the next digit in the table

JMP read_input_digits

calculate_operation

; firstly get the first address in the table of operations
operation_table_l LDA operation_table
LDA operation_table_l

ADD operation
ADD jump_opcode
STA operation_table_jump

; right before we jump, we put operation1 into the ACC
LDA operand1

operation_table_jump STP ; dummy instruction

; table of operations
operation_table
JMP calc_add
JMP calc_sub
ADD &0FEF ; just adds zero (does nothing) 
JMP calc_div
JMP calc_mul

calc_add
ADD operand2
JMP process_answer

calc_sub
SUB operand2
JMP process_answer

calc_mul
STA mul_op1
LDA operand2
STA mul_op2

LDA store_opcode
ADD sp
STA calc_mul_stack_add

calc_load_mul_r LDA process_answer ; return to process_answer immediately
LDA calc_load_mul_r
calc_mul_stack_add STP ; dummy instruction

LDA sp
ADD one
STA sp
JMP mul

calc_div
STA div_op1

LDA operand2
STA div_op2



LDA store_opcode
ADD sp
STA calc_divide_stack_add

calc_load_division_r LDA process_answer
LDA calc_load_division_r
calc_divide_stack_add STP ; dummy instruction

LDA sp
ADD one
STA sp

JMP divide


process_answer

; change current_asp
STA temp1

LDA asp
ADD answers

STA current_asp

SUB asp
JGE curr_asp_pos
;asp not positive
LDA asp
STA current_asp
curr_asp_pos

; add to the results stack

LDA asp
ADD answers
ADD store_opcode
STA store_answer

LDA temp1
store_answer  STP ; dummy instruction

; do anything with next lights?
; change to red if we need to
LDA next
SUB one
JNE ans_c_next

; change to red
STA next

LDA &FFF 
SUB one
ADD next_red
STA &FFF

ans_c_next

; do anything with prev lights?
; change to green if we need to

LDA answers

JNE over_one_res ; need over one res for this

JMP ans_c_prev

over_one_res

LDA prev
JNE ans_c_prev

; change to green
ADD one
STA prev

LDA &FFF 
ADD prev_green
SUB prev_red
STA &FFF

ans_c_prev

LDA answers
ADD one
STA answers

; prepare temp_counter to be used to detect when the first digit is placed
LDA max ; this is &FFFF (-1) one addition will allow it to jump using JGE
STA temp_counter

LDA temp1

; if is negative or over, we reset it
JGE over_test
JMP reset_this_op

over_test
SUB largest_digit_allowed
JGE reset_this_op
ADD largest_digit_allowed ; restore

LDA temp1 ; restore result

JMP write_answer

write_answer
STA operand1
STA working_calc_result ; we make a copy of operand1

LDA largest_digit_allowed
STA calc_ans_current_divisor

; write the answer onto the number stack
; first of all divide our answer by the tenth powers
write_answer_loop

LDA working_calc_result
STA div_op1

LDA calc_ans_current_divisor
STA div_op2

LDA store_opcode
ADD sp
STA write_answer_division_stack_add

write_answer_division_r LDA write_answer_division_r_point
LDA write_answer_division_r
write_answer_division_stack_add STP ; dummy instruction

LDA sp
ADD one
STA sp

JMP divide
write_answer_division_r_point
STA temp1

; first digit check
JNE first_digit_in_ans
JMP not_first_digit_in_ans
first_digit_in_ans
LDA temp_counter
ADD one
STA temp_counter
not_first_digit_in_ans


LDA temp_counter
JGE ans_add_number

LDA temp1

; if is zero and not the first, we just go straight to the lowering of the power of ten
JMP lower_ten_power
ans_sub
; we now need to substract from the answer
; we need to multilpy the power of ten by the remainder we got ealier
LDA temp1
STA mul_op2 ; the division result will always be smaller than the power of ten

LDA calc_ans_current_divisor
STA mul_op1

LDA store_opcode
ADD sp
STA calc_mul_div_res_stack_add

calc_load_mul_div_res_r LDA calc_mul_div_res_r_point ; return to write_answer immediately
LDA calc_load_mul_div_res_r
calc_mul_div_res_stack_add STP ; dummy instruction

LDA sp
ADD one
STA sp 
JMP mul

calc_mul_div_res_r_point 
LDA working_calc_result
SUB mul_res
STA working_calc_result

; we lower the divisor power of ten
lower_ten_power
LDA calc_ans_current_divisor
STA div_op1

LDA ten
STA div_op2

LDA store_opcode
ADD sp
STA write_lower_ten_stack_add

write_answer_lower_ten_r LDA write_answer_lower_ten_r_point
LDA write_answer_lower_ten_r
write_lower_ten_stack_add STP ; dummy instruction shortened label

LDA sp
ADD one
STA sp

JMP divide
write_answer_lower_ten_r_point
STA calc_ans_current_divisor

JNE write_answer_loop ; reloop of the writing one digit of the answer function


; if the result of the divsion, is zero, we are ready to write the answer
; if the result of the entire op is zero, we write a zero to the display
LDA temp_counter
JGE display_ans

LDA dsp
ADD store_opcode
STA store_zero

LDA zero
store_zero  STP ; dummy instruction

LDA one
STA digits_numbers

JMP display_ans

ans_add_number
; here we add the number to the stack

LDA dsp
ADD digits_numbers
ADD store_opcode
STA store_ans_digit

LDA temp1
store_ans_digit STP ; dummy instruction

LDA digits_numbers
ADD one
STA digits_numbers
JMP ans_sub

; ##### DISPLAY ANSWER FUNCTION START #####
; reads from the number stack to output the answer RTL
; assumes that the answer is on the number stack

display_ans
LDA zero
STA temp_counter; keep track of how many digits have been written

display_ans_loop ; if all digits are done, return to the loop
LDA digits_numbers
JNE display_next_digit

; before we return to the loop, we need to turn off any unused digits

LDA store_opcode
ADD sp
STA display_ans_rd_stack_add

display_ans_rd_stack_r LDA loop
LDA display_ans_rd_stack_r
display_ans_rd_stack_add STP ; dummy instruction

display_ans_rd_r
LDA sp
ADD one
STA sp

; it goes after we put the return address on the stack because the funciton expectes temp_counter to be in the ACC when its called
LDA temp_counter
SUB six
STA temp_counter

JMP rd

LDA temp_counter
SUB six
JGE loop ; this means that all digits have been written to
STA temp_counter
JMP rd

;find the correct display digit to write to
display_next_digit
LDA last_digit_address
ADD temp_counter

;make sure its in the acceptable range
SUB address_checker
JGE loop ; FOR NOW IT EXITS IF THE MAX NUMBER OF 6 DIGITS HAS BEEN WRITTEN

; its good, so we build and place the instruction that will write to the display
ADD address_checker ; restore the address
ADD store_opcode
STA display_answer_write_digit

;read the digit at the top of the stack

LDA digits_numbers
SUB one
STA digits_numbers
ADD dsp
STA read_next_digit
read_next_digit STP ; dummy instruction
display_answer_write_digit STP ; dummy instruction

LDA temp_counter
ADD one
STA temp_counter

JMP display_ans_loop ; return to loop once temp counter is no longer negative

;##### DIVIDE FUNCTION START #####
divide 
LDA zero
STA div_res ; reset the divide result

divide_loop
LDA div_op1
SUB div_op2
STA div_op1

JGE continue_division

; the division is done, jump us back to caller
LDA div_res
STA function_result
JMP return_function

continue_division
LDA div_res
ADD one
STA div_res
JMP divide_loop ; loop back around the function

;##### MULTIPLY FUNCTION START #####
mul
LDA zero
STA mul_res ; reset the result

;if one operand is negative, that becomes operand 1, if they are both negative, then their signs are switched
LDA mul_op1
JNE mul_non_zero
;RETURN
mul_non_zero

; if operand 1 is positive and operand 2 is negative, we move operand 2 to operand 1
JGE mul_pos_operand1

;if we are here, then the first operand is negative
LDA mul_op2
JGE mul_loop

;if we are here, both operands are negative
; in this case we flip the signs
LDA zero
SUB mul_op1
STA mul_op1

LDA zero
SUB mul_op2
STA mul_op2


mul_pos_operand1 
LDA mul_op2
JGE mul_loop

;if we are here, operand 1 is positive, but operand 2 is negative, so we need to swap them
LDA mul_op1
STA temp1

LDA mul_op2
STA mul_op1

LDA temp1
STA mul_op2


mul_loop
;firstly check whether operand 2 is zero
LDA mul_op2
JNE mul_op2_non_zero

; the multiplication is done, so we set up the code that will jump us back to caller
LDA mul_res
STA function_result
JMP return_function

mul_op2_non_zero
LDA mul_res
ADD mul_op1
STA mul_res

LDA mul_op2
SUB one
STA mul_op2
JMP mul_loop
