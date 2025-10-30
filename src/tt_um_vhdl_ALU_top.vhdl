library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- tt_um_vhdl_ALU_top : 6-bit wrapper for the fixed 6-bit ALU (alu_6bit)
--
-- Inputs:
--   ui_in  [5:0]  = A (signed, 6-bit)
--   ui_in  [7:6]  = opcode[1:0]
--   uio_in [7:2]  = B (signed, 6-bit)
--   uio_in [1:0]  = opcode[3:2]
--
-- Opcode map (binary):
--   0000 PASSA   0001 ADD     0010 SUB     0011 MUL
--   0100 DIV     0101 AND     0110 OR      0111 XOR
--   1000 LSL1    1001 ASR1    1010 NOT     1011 NEG
--   1100 INC     1101 DEC     1110 SLT     1111 XNOR
--
-- Outputs:
--   uo_out[7:2] = result (signed 6-bit)
--   uo_out[1]   = zero flag
--   uo_out[0]   = overflow flag (for signed add/sub/neg/inc/dec)
--   uio_out     = 0
--   uio_oe      = 0
-- ============================================================================

entity tt_um_vhdl_ALU_top is
    port (
        -- Inputs
        ui_in   : in  std_logic_vector(7 downto 0);  -- [5:0]=A, [7:6]=opcode[1:0]
        uio_in  : in  std_logic_vector(7 downto 0);  -- [7:2]=B, [1:0]=opcode[3:2]
        ena     : in  std_logic;                     -- unused
        clk     : in  std_logic;
        rst_n   : in  std_logic;                     -- active-low reset

        -- Outputs
        uo_out  : out std_logic_vector(7 downto 0);  -- [7:2]=result, [1]=zero, [0]=ovf
        uio_out : out std_logic_vector(7 downto 0);  -- unused (0)
        uio_oe  : out std_logic_vector(7 downto 0)   -- unused (0)
    );
end tt_um_vhdl_ALU_top;

architecture Behavioral of tt_um_vhdl_ALU_top is
    -- Internal signals (6-bit wide operands/result)
    signal op1_s    : signed(5 downto 0);
    signal op2_s    : signed(5 downto 0);
    signal opcode_s : std_logic_vector(3 downto 0);
    signal result_s : signed(5 downto 0);
    signal zero_s   : std_logic;
    signal carry_s  : std_logic;  -- overflow flag from ALU
begin
    -- =========
    -- Inputs
    -- =========
    -- A = ui_in[5:0]
    op1_s <= signed(ui_in(5 downto 0));

    -- B = uio_in[7:2]
    op2_s <= signed(uio_in(7 downto 2));

    -- opcode = {uio_in[1:0], ui_in[7:6]}  -> [3:2] from uio_in, [1:0] from ui_in
    opcode_s(3 downto 2) <= uio_in(1 downto 0);
    opcode_s(1 downto 0) <= ui_in(7 downto 6);

    -- =========
    -- DUT (direct entity instantiation of your present ALU)
    -- =========
    u_alu: entity work.alu_6bit
        port map (
            clk_i    => clk,
            res_ni   => rst_n,
            op1_i    => op1_s,
            op2_i    => op2_s,
            opcode_i => opcode_s,
            result_o => result_s,
            zero_o   => zero_s,
            carry_o  => carry_s
        );

    -- =========
    -- Outputs
    -- =========
    uo_out(7 downto 2) <= std_logic_vector(result_s);
    uo_out(1)          <= zero_s;
    uo_out(0)          <= carry_s;      -- overflow

    uio_out <= (others => '0');         -- keep UIO as inputs only
    uio_oe  <= (others => '0');

    -- 'ena' is unused by design
end Behavioral;
