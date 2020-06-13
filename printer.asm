#
# FILE:         Printer.asm
# AUTHOR:       Isaias Villalobos, RIT 2020
#
#
# DESCRIPTION:
#       This file will handle all the printing that is done with
#       project. It is in charge of printing, Forrest Fire logo,
#       The error will also be printed.
#       The board will be printed.
#       In addition to properly printing the top/bottom of board
#       Proper spacing is also handled
#-------------------------------
#
# Numeric Constants
#

PRINT_CHAR = 11
PRINT_INT = 1
PRINT_STRING = 4
space: .asciiz "\n"


.globl print_error
.globl print_banner

.data

.align 2
newLine: .ascii "\n"
firstLine: .asciiz  "+-------------+\n"
secondLine: .asciiz "| FOREST FIRE |\n"
thirdLine: .asciiz "+-------------+\n"
fourthLine: .asciiz "==== \#"
fourthLine2: .asciiz " ====\n"
dash: .asciiz "-"
plus: .asciiz "+"
pipe: .asciiz "|"
pipepipe: .asciiz "|\n|"
pluspipe: .asciiz "+\n|"
pipeplus: .asciiz "|\n+"

ERROR1: .asciiz "ERROR: invalid grid size\n"
ERROR2: .asciiz "ERROR: invalid number of generations\n"
ERROR3: .asciiz "ERROR: invalid wind direction\n"
ERROR4: .asciiz "ERROR: invalid character in grid\n"
.text
.align 2
print_error:
                                           
        move $t1, $a0                        # pass the correct values into a0
        li $t2, 1                            # values that will have values
        li $t3 ,2
        li $t4, 3
        li $t5, 4

        bne     $t1, $t2, error2             # if t1 == 1

        li      $v0, PRINT_STRING
        la      $a0, ERROR1
        syscall                              # Print ERROR1
error2:
        bne     $t1,$t3, error3              # If t1 == 2

        li      $v0, PRINT_STRING
        la      $a0, ERROR2
        syscall                              # Print ERROR2
error3:
        bne     $t1, $t4, error4             # If t1 == 3

        li      $v0, PRINT_STRING
        la      $a0, ERROR3                  # Print ERROR3
        syscall
error4:
        bne     $t1,$t5, print_done          # if t1 == 4

        li      $v0, PRINT_STRING
        la      $a0, ERROR4
        syscall                              # Print ERROR4

print_done:
        jr      $ra

print_banner:                               # routine that handles logo print
        li      $v0, PRINT_STRING           # load v0 with proper SYSCALL code
        la      $a0, firstLine              # load the first line
        syscall

        li      $v0, PRINT_STRING           # print the second line
        la      $a0, secondLine
        syscall

        li      $v0, PRINT_STRING           # print the third line
        la      $a0, thirdLine
        syscall

        jr      $ra


print_board:
        li      $v0, PRINT_STRING         # print the banner regardless of err
        la      $a0, fourthLine
        syscall

        li      $v0, PRINT_INT
        move    $a0, $t6                  # track num of gen, print bord
        syscall

        li      $v0, PRINT_STRING
        la      $a0, fourthLine2
        syscall

        li      $t9, 0                    # counter for current char
        mul     $t1, $s0, $s0             # t1 = size of the grid, total
        li      $v0, PRINT_STRING
        la      $a0, plus
        syscall

print_top_and_bottom_loop:

        slt     $t2, $t9, $s0               # if t9 < s0, set t2 to be 1, else 0
        beq     $t2, $zero, print_plus_pipe # go to print_plus_pipe
        addi    $t9, $t9, 1                 # add 1 to t9
        li      $v0, PRINT_STRING           # v0 = PRINT_CHAR
        la      $a0, dash                   # a0 = '-'
        syscall
        j       print_top_and_bottom_loop

print_plus_pipe:                            # top and bottom loop reset
        li      $t9, 0                      # t9 = counter, 
        beq     $s7, $t3, print_board_done  # branch to if needed
        li      $v0, PRINT_STRING           # load PRINT_STRING for SYSCALL
        la      $a0, pluspipe               # load the pluspipe string
        syscall
        li      $t8, 0                      # t8 = all lines in board counter
        addi    $t5, $s0, 1                 # t5 = s0 + 1
        addi    $t0, $s0, -1
        mul     $t1, $t5, $t0               # t1 = size of grid with nullspaces
        addi    $t3, $s7, 0                 # temporarily store size of board

print_board_loop:

        li      $v0,PRINT_STRING           # code 4 == print string
        add     $a0, $t3, $t8              # $a0 == address of the string
        syscall

        slt     $t4, $t8, $t1              # num of lines == max lines of board
        beq     $t4, $zero, print_pipe_plus

        li      $v0, PRINT_STRING          # load v0 with the correct SYSCALL
        la      $a0, pipepipe              # load the address of the ASCII "|"
        syscall

        add     $t8, $t5, $t8              # increment line count

        j       print_board_loop

print_pipe_plus:
        li      $v0, PRINT_STRING          # load v0 with correct SYSCALL code
        la      $a0, pipeplus              # load address of the ASCII "|"
        syscall
        j       print_top_and_bottom_loop

print_board_done:
        li      $t3, 0                     # resets t3, back to 0
        li      $v0, 4                     # code 4 == print string
        la      $a0, plus                  # $a0 == address of the string
        syscall
        addi    $a0, $zero, 10             # ascii code for line feed
        addi    $v0, $zero, 11             # syscall to print character
        syscall
         addi    $a0, $zero, 10            # ascii code for line feed
        addi    $v0, $zero, 11             # syscall to print character
        syscall

        jr      $ra
