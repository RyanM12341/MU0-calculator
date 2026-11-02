# MU0-calculator
A calculator programmed using the MU0 assembly language.

Distinct functions are marked in the code between tags:

EVENT LOOP:
Coninually polls the keypad buttons and simple buttons (which control the history buttons), jumping to FUNCTION THAT DETERMINES WHICH BUTTON HAS BEEN PRESSED when it detects a value in any of the registers the periphals write to when they're pressed.
The keypad writes a code to FF2 corresponding to the key being pressed at every point the button is being held down, so this function keeps track of previous_code to determine whether the key press has already been processed. The moment the keypad writes a different code to FF2, we know that the button is no longer being held down, so we can assign an impossible code to previous_code to allow that button to be pressed again.

RESET DIGITS FUNCTION:
Removes any digits that may be being displayed. Happens when the calculator is turned on, reset, or a value needs to be displayed.

FUNCTION THAT HANDLES HISTORY BUTTONS:
Controls the history buttons. Uses traffic lights to show whether the stack can be traversed further up, or down and displays the stored result.

FUNCTION THAT DETERMINES WHICH BUTTON HAS BEEN PRESSED:
At the time its jumped to, the code corresponding to the key pressed is stored in the accumulator. This function substracts every possible code that could correspond to any button being pressed from the value that the keypad stored. We find the correct button when this substraction equals 0, in which case we jump to PROCESS BUTTON START with our own value corresponding to this key stored in temp_counter, which is easier to work with.

PROCESS BUTTON START:
Firstly figures out whether the key pressed is a number or a letter (which correspond to arithmetic operations). If the button is a number, it updates the display and the value the calculator uses to keep track of what's on the display. If the equals button has been pressed it jumps to CALCULATE ANSWER FUNCTION START. If its an arithemitic operation, it stores a value corresponding to the operation that will be used when the equals button is pressed. If clear is pressed, everything is reset.

RETURN FUNCTION:
Jumped to at the end some more commonly used function. Returns to the address at the top of the stack, like with an actual computer.

CALCULATE ANSWER FUNCTION START:
Does the operation that is stored in the operation variable on the previous result and the value currenly entered before the equals was pressed.

DISPLAY ANSWER FUNCTION START:
Displays the number corresponding to a value in memory. Used to display results to calculations

DIVIDE FUNCTION START:
Handles all division required in the program because MU0 does not have an instruction for this.

MULTIPLY FUNCTION START:
Handles all multiplication required in the program because MU0 does not have an instruction for this.