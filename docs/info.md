Project Title: 6-bit Signed ALU with TinyTapeout Wrapper<br>
Institution: FH Kärnten<br>
Course: Digital-1<br>
Program: Integrated Systems & Circuit Design

## How it works

This design is a 6-bit signed (two’s-complement) ALU with a TinyTapeout wrapper.
Core timing: Inputs (A, B, opcode) are sampled on a rising clock edge; RESULT/ZERO/OVF are registered and appear on the next rising edge (1-cycle latency).
Signed input operand range: −32…+31.  
Reset: rst_n is active-low, asynchronous. While low, the ALU holds RESULT=0, ZERO=1, OVF=0.
Enable: ena is unused in this design (wrapper passes it through; it does not gate logic).

**ALU core:** 
For each clock cycle, one of 16 operations is selected by opcode.
ZERO flag is 1 when the computed result equals 0.
OVF is a signed overflow flag (asserted for ADD/SUB/NEG/INC/DEC under two’s-complement rules). It is 0 for logic, shifts, MUL, DIV (Signed integer division, if B = 0, the result is 0 (ZERO=1, OVF=0)).

**Control truth table (opcode --> operation)**

0000  PASSA   RESULT = A<br>
0001  ADD     RESULT = A + B                 (OVF on signed overflow)<br>
0010  SUB     RESULT = A - B                 (OVF on signed overflow)
0011  MUL     RESULT = (A * B) mod 64        (truncate to 6 bits, OVF=0)
0100  DIV     RESULT = A / B (signed); B=0 → 0 (ZERO=1, OVF=0)
0101  AND     RESULT = A and B               (bitwise)
0110  OR      RESULT = A or  B               (bitwise)
0111  XOR     RESULT = A xor B               (bitwise)
1000  LSL1    RESULT = A << 1                (logical left shift)
1001  ASR1    RESULT = A >> 1                (arithmetic right shift; keeps sign)
1010  NOT     RESULT = not A                 (bitwise)
1011  NEG     RESULT = -A                    (OVF when A = -32)
1100  INC     RESULT = A + 1                 (OVF when A = +31 → wraps to -32)
1101  DEC     RESULT = A - 1                 (OVF when A = -32 → wraps to +31)
1110  SLT     RESULT = 1 if A < B else 0     (signed compare)
1111  XNOR    RESULT = not (A xor B)         (bitwise)

Mapping of ports:
Input port: ui_in[5:0]=A,<br>
            ui_in[7:6]=opcode[1:0],<br>

Bidirectional port : uio_in[7:2]=B,<br>
                     uio_in[1:0]=opcode[3:2]<br>

Output port : uo_out[7:2]=RES[5:0]<br>
              uo_out[0]=OVF, uo_out[1]=ZERO<br>


## How to test

ttExplain how to use your project

## External hardware

ttList external hardware used in your project (e.g. PMOD, LED display, etc), if any
