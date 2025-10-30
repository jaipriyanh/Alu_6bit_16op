library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- =========================
-- Core ALU: alu_6bit
-- =========================
entity alu_6bit is
    port (
        clk_i     : in  std_logic;
        res_ni    : in  std_logic;                       -- active-low async reset
        op1_i     : in  signed(5 downto 0);
        op2_i     : in  signed(5 downto 0);
        opcode_i  : in  std_logic_vector(3 downto 0);
        result_o  : out signed(5 downto 0);
        zero_o    : out std_logic;
        carry_o   : out std_logic                        -- signed overflow flag
    );
end alu_6bit;

architecture rtl of alu_6bit is
    signal result_s : signed(5 downto 0);
begin
    process(clk_i, res_ni)
        variable tmp_overflow : std_logic;
        variable result_v     : signed(5 downto 0);
        variable sum_v        : signed(5 downto 0);
        variable diff_v       : signed(5 downto 0);
    begin
        if res_ni = '0' then
            result_s <= (others => '0');
            zero_o   <= '1';
            carry_o  <= '0';

        elsif rising_edge(clk_i) then
            tmp_overflow := '0';
            result_v     := (others => '0');

            case opcode_i is
                -- 0000 PASS A
                when "0000" =>
                    result_v := op1_i;

                -- 0001 ADD (signed)
                when "0001" =>
                    sum_v    := op1_i + op2_i;
                    result_v := sum_v;
                    if (op1_i(5) = op2_i(5)) and (sum_v(5) /= op1_i(5)) then
                        tmp_overflow := '1';
                    end if;

                -- 0010 SUB (signed)
                when "0010" =>
                    diff_v   := op1_i - op2_i;
                    result_v := diff_v;
                    if (op1_i(5) /= op2_i(5)) and (diff_v(5) /= op1_i(5)) then
                        tmp_overflow := '1';
                    end if;

                -- 0011 MUL (truncate to 6)
                when "0011" =>
                    result_v := resize(op1_i * op2_i, 6);

                -- 0100 DIV (guard divide by zero)
                when "0100" =>
                    if op2_i /= to_signed(0, 6) then
                        result_v := op1_i / op2_i;
                    else
                        result_v := (others => '0');  -- policy: return 0
                    end if;

                -- 0101 AND
                when "0101" =>
                    result_v := op1_i and op2_i;

                -- 0110 OR
                when "0110" =>
                    result_v := op1_i or op2_i;

                -- 0111 XOR
                when "0111" =>
                    result_v := op1_i xor op2_i;

                -- 1000 LSL1 (logical left shift by 1)
                when "1000" =>
                    result_v := shift_left(op1_i, 1);

                -- 1001 ASR1 (arithmetic right shift by 1)
                when "1001" =>
                    result_v := shift_right(op1_i, 1);

                -- 1010 NOT A
                when "1010" =>
                    result_v := not op1_i;

                -- 1011 NEG A (two's complement)
                when "1011" =>
                    result_v := -op1_i;
                    -- overflow when negating minimum value (-32 for 6-bit signed)
                    if op1_i = to_signed(-32, 6) then
                        tmp_overflow := '1';
                    end if;

                -- 1100 INC A
                when "1100" =>
                    result_v := op1_i + to_signed(1, 6);
                    -- signed overflow if +31 -> -32
                    if (op1_i(5) = '0') and (result_v(5) = '1') then
                        tmp_overflow := '1';
                    end if;

                -- 1101 DEC A
                when "1101" =>
                    result_v := op1_i - to_signed(1, 6);
                    -- signed overflow if -32 -> +31
                    if (op1_i(5) = '1') and (result_v(5) = '0') then
                        tmp_overflow := '1';
                    end if;

                -- 1110 SLT (set if A < B, signed)
                when "1110" =>
                    if op1_i < op2_i then
                        result_v := to_signed(1, 6);
                    else
                        result_v := to_signed(0, 6);
                    end if;

                -- 1111 XNOR
                when "1111" =>
                    result_v := not (op1_i xor op2_i);

                -- Default to cover X/Z/- on opcode
                when others =>
                    result_v     := (others => '0');
                    tmp_overflow := '0';
            end case;

            -- Register result and flags
            result_s <= result_v;
            carry_o  <= tmp_overflow;  -- overflow for ADD/SUB/NEG/INC/DEC

            if result_v = to_signed(0, 6) then
                zero_o <= '1';
            else
                zero_o <= '0';
            end if;
        end if;
    end process;

    result_o <= result_s;
end rtl;


-- =========================
-- Top wrapper: tt_um_vhdl_ALU_top
-- =========================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    -- Internal signals (6-bit)
    signal op1_s    : signed(5 downto 0);
    signal op2_s    : signed(5 downto 0);
    signal opcode_s : std_logic_vector(3 downto 0);
    signal result_s : signed(5 downto 0);
    signal zero_s   : std_logic;
    signal carry_s  : std_logic;
begin
    -- Input mapping
    op1_s <= signed(ui_in(5 downto 0));         -- A = ui_in[5:0]
    op2_s <= signed(uio_in(7 downto 2));        -- B = uio_in[7:2]
    opcode_s(3 downto 2) <= uio_in(1 downto 0); -- opcode[3:2]
    opcode_s(1 downto 0) <= ui_in(7 downto 6);  -- opcode[1:0]

    -- ALU instance (direct entity bind to avoid unbound issues)
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

    -- Output mapping
    uo_out(7 downto 2) <= std_logic_vector(result_s);
    uo_out(1)          <= zero_s;
    uo_out(0)          <= carry_s;

    uio_out <= (others => '0');
    uio_oe  <= (others => '0');
end Behavioral;

