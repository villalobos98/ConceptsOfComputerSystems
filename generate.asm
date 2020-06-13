# FILE:         generations.asm
# AUTHOR:       Isaias Villalobos, RIT 2020
#
#
# DESCRIPTION:
# This file will handle the way that generations should behave
# The way this algorithm works is by maintain two grids
# One that will hold the previous generation and one that
# will hold the updated generation. Print grid 1, then use the data
# from grid 1 to create grid 2. Overwrite grid 1 with a new
# gneration using the data stored in grid 2. Keep exchanging
# the roles of these grids until the number of desired generations is reached.
#-------------------------------

#
# Numeric Constants
#
.globl generate

ASCII_SPACE = 32
ASCII_N = 78
ASCII_S = 83
ASCII_E = 69
ASCII_W = 87
ASCII_B = 66
ASCII_t = 116
ASCII_. = 46
ASCII_NL = 0



generate:
        li      $t8, 0                         # counter to go through array
        mul     $t1, $s0, $s0                  # s0 = size of the line, 1 row
        add     $s6, $t1, $s0                  # t6 = board size plus nulls

generate_loop:

        slt     $t5, $t8,$s6                   # if the t8 = counter
        beq     $t5, $zero, generate_loop_done # s6 = board_size

        add     $t3, $s7, $t8                  # s7 = address of board
        add     $s5, $s4, $t8                  # s5 = address within new board
        lb      $t9, 0($t3)                    # load the byte from board

        la      $t1, ASCII_NL                  # check if new line char
        beq     $t1, $t9, skip_null            # skip past all null


        la      $t1, ASCII_.                   # check if current char is grass
        beq     $t1, $t9, skip_grass           # t9 = character we're at

        la      $t1, ASCII_B
        beq     $t1, $t9, burning_stuff        # check current char is ASCII_B

        la      $t4, ASCII_N                   # load address of the N ASCII
        bne     $s2, $t4, wind_is_not_north    # if wind direction is north
        slt     $t4, $t8, $s0
        bne     $t4, $zero, wind_is_not_north

        sub     $t0, $t3, $s0                  # adress curr cell- board size
        lb      $t0,-1($t0)                    # previous value - extra null

        la      $t5, ASCII_.                   # load the address of the grass
        bne     $t0, $t5, wind_is_not_north    # if cell north of us is grass
        la      $t7, ASCII_t
        sub     $t0, $s5, $s0                  # t3=address of where within old
        sb      $t7, -1($t0)                   # store curr char in new board


wind_is_not_north:

        la      $t4, ASCII_S                  # load address of the S ASCII
        bne     $s2, $t4, wind_is_not_south   # if wind direction is south
        add     $t0, $t3, $s0                 # addres of curr cell-board size
        lb      $t0, 1($t0)                   # previous value - extra null

        la      $t5, ASCII_.
        bne     $t0, $t5, wind_is_not_south   # if cell south of us is grass
        la      $t7, ASCII_t
        add     $t0, $s5, $s0                 # add to get the correct loc
        sb      $t7, 1($t0)                   # store curr char into new board


wind_is_not_south:
        la      $t4, ASCII_E                  # load address of the S ASCII

        bne     $s2, $t4, wind_is_not_east    # if wind direction is north
        lb      $t0, 1($t3)                   # previous value - extra null

        la      $t5, ASCII_.
        bne     $t0, $t5, wind_is_not_east    # if cell north of us is grass
        la      $t7, ASCII_t
        sb      $t7, 1($s5)                   # store curr char into new board


wind_is_not_east:


        la      $t4, ASCII_W                 # load address of the S ASCII
        bne     $s2, $t4, wind_done          # if wind direction is north
        beq     $t8, $zero, wind_done

        lb      $t0, -1($t3)                 # previous value - extra null
        la      $t5, ASCII_.
        bne     $t0, $t5, wind_done          # if cell north of us is grass
        la      $t7, ASCII_t
        sb      $t7, -1($s5)                 # store curr char into new board


wind_done:
        lb      $t1, 0($s5)                  # load tree from old board

        la      $t4, ASCII_B
        beq     $t1, $t4, wind_done2

        la      $t4, ASCII_t
        sb      $t4, 0($s5)                  # store a "t" in the board

wind_done2:

        addi    $t8, $t8, 1                  # increment counter
        j       generate_loop                # jump back to generate_loop


burning_stuff:

        slt     $t4, $t8, $s0

        bne     $t4, $zero, burning_is_not_north
        sub     $t0, $t3, $s0                  # addres curr cell-boardsize
                                               # subtract 1 full column
        lb      $t7,-1($t0)                    # subtract away the null value

        la      $t5, ASCII_t                   # load the address of the tree
        bne     $t7, $t5, burning_is_not_north # if cell north of us is a tree
        la      $t5, ASCII_B
        sub     $t0, $s5, $s0
        sb      $t5, -1($t0)



burning_is_not_north:
        add     $t0, $t3, $s0                    # addres curr cell-boardsize
        lb      $t7, 1($t0)                      # subtract away null value


        la      $t5, ASCII_t                     # load the address of tree
        bne     $t7, $t5, burning_is_not_south   # if cell south of us is tree
        la      $t5, ASCII_B

        add     $t0, $s5, $s0
        sb      $t5, 1($t0)


burning_is_not_south:
        beq     $t8, $zero, burning_is_not_west
        lb      $t7, -1($t3)                   # subtract away the null value
                                               # t3 address of current cell
        la      $t5, ASCII_t                   # load the address of the tree
        bne     $t7, $t5, burning_is_not_west  # if cell south of us is a tree
        la      $t5, ASCII_B
        sb      $t5, -1($s5)



burning_is_not_west:
        lb      $t7, 1($t3)                   # subtract away the null value
        la      $t5, ASCII_t                  # load the address of the tree
        bne     $t7, $t5, burning_is_not_east # if cell east of us is a tree
        la      $t5, ASCII_B
        sb      $t5, 1($s5)


burning_is_not_east:
        la      $t1, ASCII_.
        sb      $t1, 0($s5)
        addi    $t8, $t8, 1              # increment counter
        j       generate_loop            # jump back to generate_loop

skip_grass:
        lb      $t1, 0($s5)              # loaded from the old board
        la      $t4, ASCII_t             # then check if the value was a 't'
        beq     $t1, $t4, skip_grass2    # if it was then skip the char
        la      $t4, ASCII_B             # check if item see if it was a 'B'
        beq     $t1,$t4, skip_grass2     # skip the item if it was
        la      $t4, ASCII_.
        sb      $t4, 0($s5)

skip_grass2:

        addi    $t8, $t8, 1
        j       generate_loop

skip_null:                                # routine skip null values of board
        sb      $t1, 0($s5)
        addi    $t8, $t8, 1               # add 1 to curr char
        j       generate_loop             # go back to the generate loop

generate_loop_done:

        li      $t8, 0
new_board_loop:
        slt     $t5, $t8, $s6
        beq     $t5, $zero, new_board_done
        add     $t1, $s7, $t8
        add     $t0, $s4, $t8
        lb      $t0, 0($t0)

        sb      $t0, 0($t1)
        addi    $t8, $t8, 1
        j       new_board_loop

new_board_done:
        jr      $ra

