	.globl	swoole_make_fcontext[DS]
	.globl .swoole_make_fcontext[PR]
	.align 2
	.csect  swoole_make_fcontext[DS]
swoole_make_fcontext:
	.long .swoole_make_fcontext[PR]
	.csect .swoole_make_fcontext[PR], 3
#.swoole_make_fcontext:
    # save return address into R6
    mflr  6

    # first arg of swoole_make_fcontext() == top address of context-function
    # shift address in R3 to lower 16 byte boundary
    clrrwi  3, 3, 4

    # reserve space for context-data on context-stack
    # including 64 byte of linkage + parameter area (R1 % 16 == 0)
    subi  3, 3, 304

    # third arg of swoole_make_fcontext() == address of context-function
    stw  5, 236(3)

    # load LR
    mflr  0
    # jump to label 1
    bl  .Label
.Label:
    # load LR into R4
    mflr  4
    # compute abs address of label .L_finish
    addi  4, 4, .L_finish - .Label
    # restore LR
    mtlr  0
    # save address of finish as return-address for context-function
    # will be entered after context-function returns
    stw  4, 232(3)

    # restore return address from R6
    mtlr  6

    blr  # return pointer to context-data

.L_finish:
    # save return address into R0
    mflr  0
    # save return address on stack, set up stack frame
    stw  0, 4(1)
    # allocate stack space, R1 % 16 == 0
    stwu  1, -16(1)

    # exit code is zero
    li  3, 0
    # exit application
    bl  ._exit
    nop
