
#
# FILE:         forestfire.asm
# AUTHOR:       Isaias Villalobos, RIT 2020
#
#
# DESCRIPTION:
#       This file is the main driver that can handle taking input
#       This file is the main driver tha can handle calling error functions.
#       It will store the proper characters into the board
#       This file will call the proper functions for printing and generating
#       a board.
#
#-------------------------------
#
# Numeric Constants
#

.globl print_error
.globl main
.globl print_banner
.globl generate
.globl print_board


ASCII_SPACE = 32
ASCII_N = 78
ASCII_S = 83
ASCII_E = 69
ASCII_W = 87
ASCII_B = 66
ASCII_t = 116
ASCII_. = 46
ASCII_NL = 10

.data
.align 2

board: .space 930
board2: .space 930

.text
.align 2

READ_CHAR = 12
READ_INT = 5
READ_STRING = 4



main:
        addi $sp, $sp, -40
        sw   $ra, 32($sp)
        sw   $s7, 28($sp)
        sw   $s6, 24($sp)
        sw   $s5, 20($sp)
        sw   $s4, 16($sp)
        sw   $s3, 12($sp)
        sw   $s2, 8($sp)
        sw   $s1, 4($sp)
        sw   $s0, 0($sp)

        jal     print_banner
        addi    $a0, $zero, 10         # ascii code for line feed
        addi    $v0, $zero, 11         # syscall to print character
        syscall

        li      $v0, READ_INT          # load v0 with the proper SYSCALL code
        syscall
        move    $s0, $v0               # move return in s0
        slti    $t0, $s0, 4            # add check if greater than 4
        bne     $t0, $zero, grid_error # branch if needed
        slti    $t0, $s0, 31           # check if greater than 31
        beq     $t0, $zero, grid_error # branch if needed

        li      $v0, READ_INT          # read in the input for the generations
        syscall
        move    $s1, $v0               # save the value from the generations
        addi    $s1, $s1, 1            # check if the value is greater than 1
        slti    $t0, $s1, 0
        bne     $t0, $zero, generations_error # breanch if needed
        slti    $t0, $s1, 21           # check if the value is greater than 21
        beq     $t0, $zero, generations_error

        li      $v0, READ_CHAR         # read the wind direction
        syscall

        move    $s2, $v0               # save the wind direction in a s reg


        li      $t2, ASCII_N           # check if North
        beq     $v0, $t2, read_board   # branch to start reading board
        li      $t2, ASCII_S           # check if South
        beq     $v0, $t2, read_board   # branch if needed
        li      $t2, ASCII_E           # check if East
        beq     $v0, $t2, read_board
        li      $t2, ASCII_W           # check if West
        beq     $v0, $t2, read_board
        li      $a0, 3                 # if we make it here, there is print err
        jal     print_error            # jump to error
        j       main_done              # go to main_done

grid_error:                            # routine that handles grid error msg
        li      $a0, 1
        jal     print_error
        j       main_done

generations_error:                     # routine that handles generations error
        li      $a0, 2
        jal     print_error
        j       main_done
read_board:
        li      $v0, READ_CHAR           # read char input
        syscall
        la      $s7, board
        li      $t0, 0                   # t0 = counter
        mul     $t1, $s0, $s0            # t1 = size of grid


read_board_loop:
        slt     $t2, $t0, $t1            # if i < maxSize
        beq     $t2, $zero, read_board_done
        li      $v0, READ_CHAR
        syscall
        li      $t3, ASCII_B             # this is charcter code 'B'
        bne     $v0, $t3, check_tree
        j       store_character

check_tree:                              # check if the return value is tree
        li      $t3, ASCII_t
        bne     $v0, $t3, check_grass    # store the character in board
        j       store_character

check_grass:                             # check if the return value is grass
        li      $t3, ASCII_.
        bne     $v0, $t3, check_newline
        j       store_character          # if the char grass, store in board

check_newline:
        li      $t3, ASCII_NL            # routine that check for new lines
        bne     $v0, $t3, read_error
        sb      $zero, 0($s7)            # null terminate the string
        addi    $s7, $s7, 1              # go to next character
        j       read_board_loop          # go back to the read_board_loop



store_character:
        sb      $v0, 0($s7)              # store the byte
        addi    $t0, $t0, 1              # increment counter
        addi    $s7, $s7, 1              # increment character counter
        j       read_board_loop          # go back to loop

store_null:
        sb      $zero, 0($s7)            # store the byte
        addi    $s7, $s7, 1              # increment character counter
        j       read_board_loop          # go back to loop

read_error:
        li      $a0, 4                   # load proper val for a0
        jal     print_error              # call print_error
        j       main_done


read_board_done:
        la      $s7, board
        la      $s4, board2
        li      $t6, 0                   # start counter

print_and_generate_loop:
        slt     $t9, $t6, $s1            # if x < y then t9 is 1 else 0
        beq     $t9, $zero, main_done    # goto main_done
        jal     print_board              # call print_board
        jal     generate                 # call generate
        addi    $t6, $t6, 1              # incr. t6 = counter of board number
        j       print_and_generate_loop

main_done:
        lw $ra, 32($sp)
        lw $s7, 28($sp)
        lw $s6, 24($sp)
        lw $s5, 20($sp)
        lw $s4, 16($sp)
        lw $s3, 12($sp)
        lw $s2, 8($sp)
        lw $s1, 4($sp)
        lw $s0, 0($sp)
        addi $sp, $sp, 40
        jr $ra
