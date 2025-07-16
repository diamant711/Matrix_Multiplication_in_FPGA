----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/12/2025 10:02:55 AM
-- Design Name:
-- Module Name: DSP - v0
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DSP is
    Port ( RESET : in STD_LOGIC;
           CLOCK : in STD_LOGIC;
           DINA : in STD_LOGIC_VECTOR (63 downto 0);
           DINB : in STD_LOGIC_VECTOR (63 downto 0);
           DOUT : out STD_LOGIC_VECTOR (63 downto 0);
           GETN : out STD_LOGIC;
           DAREADY : in STD_LOGIC;
           DBREADY : in STD_LOGIC;
           START : in STD_LOGIC;
           DONE : out STD_LOGIC;
           MPTY : in STD_LOGIC);
end DSP;

architecture v0 of DSP is

    -- stato
    type state_type is (
        IDLE, DATAIN, PROC, DECOP, MULT, MULT_INIT,
        MULT_STEP, MULT_SHIFT, MULT_BIAS, MULT_BIAS_2, MULT_FINISH,
        ACC, ACC_START, ACC_SHIFT, ACC_CALC, ACC_CALC_A_SUM_B,
        ACC_CALC_A_SUB_B, ACC_CALC_B_SUB_A, ACC_OVERFLOW_FIX, NORMROUNDCOMP,
        NORM_START, NORM_SHIFT, NORM_ROUND, NORM_ROUND_2, NORM_ROUND_3, NORM_PACK,
        ENDED
    );
    signal state : state_type := IDLE;

    -- costanti
    constant ZERO_106 : std_logic_vector(105 downto 0) := (others => '0');
    constant ZERO_53 : std_logic_vector(52 downto 0) := (others => '0');
    constant ZERO_11 : std_logic_vector(10 downto 0) := (others => '0');

    -- buffer ingresso e uscita
    subtype operand_type is STD_LOGIC_VECTOR(63 downto 0);
    signal a : operand_type := (others => '0');
    signal b : operand_type := (others => '0');
    signal c : operand_type := (others => '0');

    -- registri
    signal sign_a, sign_b, sign_res : STD_LOGIC := '0';
    signal exp_a, exp_b : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal man_a, man_b : STD_LOGIC_VECTOR(52 downto 0) := (others => '0'); -- 53 bit con '1' implicito
    signal exp_res : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal man_res : STD_LOGIC_VECTOR(105 downto 0) := (others => '0'); -- 53+53
    signal acc_sign : STD_LOGIC := '0';
    signal acc_man_reg : STD_LOGIC_VECTOR(105 downto 0) := (others => '0');
    signal acc_exp_reg : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');

    -- variabili di supporto non NUMERIC
    signal man_a_106 : STD_LOGIC_VECTOR(105 downto 0) := (others => '0');
    signal bias : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal GETN_reg : STD_LOGIC := '0';
    signal MPTY_reg : STD_LOGIC := '0';
    signal iready : STD_LOGIC := '0';
    signal acc_step_done : std_logic := '0';
    signal norm_step_done : std_logic := '0';
    signal tmp_sticky : std_logic := '0';

    -- Normalizzazione del mantissa (acc_man_reg) e dell'esponente (acc_exp_reg)
    signal tmp_man : std_logic_vector(105 downto 0) := (others => '0');
    signal norm_man : std_logic_vector(105 downto 0) := (others => '0');
    signal norm_exp : std_logic_vector(10 downto 0) := (others => '0');
    signal rounded_man : std_logic_vector(52 downto 0) := (others => '0'); -- 53 bit con 1 implicito
    signal guard_bit : std_logic := '0';
    signal round_bit : std_logic := '0';
    signal sticky_bit : std_logic := '0';

    -- variabili di supporto con NUMERIC
    signal exp_diff : integer := 0;
    signal i : integer := 0;
    signal leading_zeros : integer := 0;
    signal norm_shift_count : integer range 0 to 106 := 0;
    signal acc_shift_count : integer range 0 to 105 := 0;

begin

    process(CLOCK, RESET)
    begin
        if RESET = '1' then
        DOUT <= (others => '0');
        GETN <= '0';
        DONE <= '0';
        a <= (others => '0');
        b <= (others => '0');
        c <= (others => '0');
        sign_a <= '0';
        sign_b <= '0';
        sign_res <= '0';
        exp_a <= (others => '0');
        exp_b <= (others => '0');
        man_a <= (others => '0');
        man_b <= (others => '0');
        exp_res <= (others => '0');
        man_res <= (others => '0');
        acc_sign <= '0';
        acc_man_reg <= (others => '0');
        acc_exp_reg <= (others => '0');
        man_a_106 <= (others => '0');
        bias <= (others => '0');
        GETN_reg <= '0';
        MPTY_reg <= '0';
        iready <= '0';
        acc_step_done <= '0';
        norm_step_done <= '0';
        tmp_sticky <= '0';
        tmp_man <= (others => '0');
        norm_man <= (others => '0');
        norm_exp <= (others => '0');
        rounded_man <= (others => '0');
        round_bit <= '0';
        guard_bit <= '0';
        sticky_bit <= '0';
        exp_diff <= 0;
        leading_zeros <= 0;
        norm_shift_count <= 0;
        acc_shift_count <= 0;
        i <= 0;
        state <= IDLE;
        elsif rising_edge(CLOCK) then
            case state is
                when IDLE =>
                    GETN <= '0'; -- assicura che GETN sia basso in IDLE
                    if START = '1' then
                        c <= (others => '0');
                        DONE <= '0';
                        acc_man_reg <= (others => '0');
                        acc_sign <= '0';
                        acc_exp_reg <= (others => '0');
                        state <= PROC;
                    else
                        state <= IDLE;
                    end if;
                when PROC =>
                    MPTY_reg <= MPTY;
                    if MPTY_reg = '0' and iready = '1' then
                        sign_a <= '0';
                        sign_b <= '0';
                        sign_res <= '0';
                        exp_a <= (others => '0');
                        exp_b <= (others => '0');
                        man_a <= (others => '0');
                        man_b <= (others => '0');
                        exp_res <= (others => '0');
                        man_res <= (others => '0');
                        man_a_106 <= (others => '0');
                        bias <= (others => '0');
                        iready <= '0';
                        acc_step_done <= '0';
                        norm_step_done <= '0';
                        tmp_sticky <= '0';
                        tmp_man <= (others => '0');
                        norm_man <= (others => '0');
                        norm_exp <= (others => '0');
                        rounded_man <= (others => '0');
                        round_bit <= '0';
                        guard_bit <= '0';
                        sticky_bit <= '0';
                        exp_diff <= 0;
                        leading_zeros <= 0;
                        norm_shift_count <= 0;
                        acc_shift_count <= 0;
                        state <= DECOP;
                    elsif MPTY_reg = '0' and iready = '0' then
                        state <= DATAIN;
                    elsif MPTY_reg = '1' then
                        state <= NORMROUNDCOMP;
                    else
                        state <= IDLE;
                    end if;
                when DATAIN =>
                    if GETN_reg = '0' then
                        GETN <= '1';
                        GETN_reg <= '1'; -- ricordiamo di aver emesso la richiesta
                    else
                        GETN <= '0'; -- subito dopo, lo abbassiamo
                        if DAREADY = '1' and DBREADY = '1' then
                            a <= DINA;
                            b <= DINB;
                            iready <= '1';
                            GETN_reg <= '0'; -- resettiamo per permettere una nuova richiesta in futuro
                            state <= PROC;
                        else
                            state <= DATAIN;
                        end if;
                    end if;
                when DECOP =>
                    sign_a <= a(63);
                    sign_b <= b(63);
                    exp_a  <= a(62 downto 52);
                    exp_b  <= b(62 downto 52);
                    man_a  <= "1" & a(51 downto 0); -- aggiungiamo il bit implicito
                    man_b  <= "1" & b(51 downto 0);
                    -- Reset support variable before MULT stage
                    if a = x"0000000000000000" and b = x"0000000000000000" then
                        state <= PROC;
                    else
                        bias <= "01111111111";
                        man_res <= (others => '0');
                        state <= MULT;
                    end if;
                when MULT =>
                    sign_res <= sign_a xor sign_b;
                    man_a_106 <= ZERO_53 & man_a;
                    state <= MULT_STEP;
                -- Somma iterativa finché y_106 ≠ 0
                when MULT_STEP =>
                    if man_b /= ZERO_53 then
                        if man_b(0) = '1' then
                            man_res <= std_logic_vector(unsigned(man_res) + unsigned(man_a_106));
                        end if;
                        man_a_106 <= man_a_106(104 downto 0) & '0';  -- shift a sinistra (×2)
                        man_b <= '0' & man_b(52 downto 1);            -- shift a destra (÷2)
                        state <= MULT_STEP;
                    else
                        state <= MULT_BIAS;
                    end if;
                -- Calcolo exp_a <- exp_a + exp_b - bias
                when MULT_BIAS =>
                    exp_a <= exp_a xor exp_b;
                    exp_b <= (exp_a(9 downto 0) & '0') and (exp_b(9 downto 0) & '0');
                    if exp_b = ZERO_11 then
                        state <= MULT_BIAS_2;
                    else
                        state <= MULT_BIAS;
                    end if;
                    -- Sub bias
                when MULT_BIAS_2 =>
                    bias <= ((not exp_a(9 downto 0) & '0')) and (bias(9 downto 0) & '0');
                    exp_a <= exp_a xor bias;
                    if exp_b = ZERO_11 and bias = ZERO_11 then
                        state <= MULT_FINISH;
                    else
                        state <= MULT_BIAS_2; -- Continua l'iterazione
                    end if;
                -- Fine: scrive i risultati
                when MULT_FINISH =>
                    exp_res <= exp_a;
                    state <= ACC;
                when ACC =>
                    state <= ACC_START;
                when ACC_START =>
                    if acc_man_reg = ZERO_106 then
                        acc_exp_reg <= exp_res;
                        state <= ACC_CALC;
                    elsif acc_exp_reg > exp_res then
                        exp_diff <= to_integer(unsigned(acc_exp_reg) - unsigned(exp_res));
                        acc_shift_count <= 0;
                        state <= ACC_SHIFT;
                    elsif exp_res > acc_exp_reg then
                        exp_diff <= to_integer(unsigned(exp_res) - unsigned(acc_exp_reg));
                        acc_shift_count <= 0;
                        state <= ACC_SHIFT;
                    else
                        state <= ACC_CALC;
                    end if;
                when ACC_SHIFT =>
                    if acc_exp_reg > exp_res then
                        if acc_shift_count < exp_diff and acc_shift_count < 106 then
                            man_res <= '0' & man_res(105 downto 1);
                            acc_shift_count <= acc_shift_count + 1;
                            state <= ACC_SHIFT;
                        else
                            exp_res <= acc_exp_reg;
                            state <= ACC_CALC;
                        end if;
                    else
                        if acc_shift_count < exp_diff and acc_shift_count < 106 then
                            acc_man_reg <= '0' & acc_man_reg(105 downto 1);
                            acc_shift_count <= acc_shift_count + 1;
                            state <= ACC_SHIFT;
                        else
                            acc_exp_reg <= exp_res;
                            state <= ACC_CALC;
                        end if;
                    end if;
                -- A == RES, B == ACC
                when ACC_CALC =>
                    if sign_res /= acc_sign then
                        if man_res > acc_man_reg then
                            acc_sign <= sign_res;
                            state <= ACC_CALC_A_SUB_B;
                        elsif man_res = acc_man_reg then
                            acc_sign <= '0';
                            acc_exp_reg <= (others => '0');
                            acc_man_reg <= (others => '0');
                            state <= PROC;
                        else
                            --acc_sign <= acc_sign;
                            state <= ACC_CALC_B_SUB_A;
                        end if;
                    else
                        --acc_sign <= acc_sign;
                        state <= ACC_CALC_A_SUM_B;
                    end if;
                when ACC_CALC_A_SUM_B =>
                        if man_res /= ZERO_106 then
                            man_res <= (acc_man_reg(104 downto 0) & '0') and (man_res(104 downto 0) & '0');
                            acc_man_reg <= acc_man_reg xor man_res;
                            state <= ACC_CALC_A_SUM_B;
                        else
                            state <= ACC_OVERFLOW_FIX;
                        end if;
                when ACC_CALC_A_SUB_B =>
                    if acc_man_reg /= ZERO_106 then
                        acc_man_reg <= (not (man_res(104 downto 0) & '1')) and (acc_man_reg(104 downto 0) & '0');
                        man_res <= man_res xor acc_man_reg;
                        state <= ACC_CALC_A_SUB_B;
                    else
                        acc_man_reg <= man_res;
                        state <= ACC_OVERFLOW_FIX;
                    end if;
                when ACC_CALC_B_SUB_A =>
                    if man_res /= ZERO_106 then
                        man_res <= (not (acc_man_reg(104 downto 0) & '1')) and (man_res(104 downto 0) & '0');
                        acc_man_reg <= acc_man_reg xor man_res;
                        state <= ACC_CALC_B_SUB_A;
                    else
                        state <= ACC_OVERFLOW_FIX;
                    end if;
                when ACC_OVERFLOW_FIX =>
                    if acc_man_reg(105) = '1' then
                        acc_man_reg <= '0' & acc_man_reg(105 downto 1);
                        acc_exp_reg <= std_logic_vector(unsigned(acc_exp_reg) + 1);
                    end if;
                    state <= PROC;
                when NORMROUNDCOMP =>
                    if acc_man_reg = std_logic_vector(to_unsigned(0, 106)) then
                        c <= (others => '0');
                        state <= ENDED;
                    else
                        state <= NORM_START;
                    end if;
                when NORM_START =>
                    tmp_man <= acc_man_reg;
                    norm_exp <= acc_exp_reg;
                    norm_shift_count <= 0;
                    i <= 0;
                    state <= NORM_SHIFT;
                when NORM_SHIFT =>
                    if tmp_man(105) = '1' then
                        norm_man <= '0' & tmp_man(105 downto 1);
                        norm_exp <= std_logic_vector(unsigned(norm_exp) + 1);
                        state <= NORM_ROUND;
                    elsif tmp_man(104) = '0' and norm_shift_count < 106 then
                        tmp_man <= tmp_man(104 downto 0) & '0';
                        norm_exp <= std_logic_vector(unsigned(norm_exp) - 1);
                        norm_shift_count <= norm_shift_count + 1;
                        state <= NORM_SHIFT;
                    else
                        norm_man <= tmp_man;
                        state <= NORM_ROUND;
                    end if;
                when NORM_ROUND =>
                    rounded_man <= norm_man(104 downto 52);
                    guard_bit <= norm_man(52);
                    round_bit <= norm_man(51);
                    tmp_sticky <= '0';
                    state <= NORM_ROUND_2;
                when NORM_ROUND_2 =>
                    if i < 51 and norm_man(i) = '1' then
                        tmp_sticky <= '1';
                        i <= i + 1;
                        state <= NORM_ROUND_2;
                    else
                        sticky_bit <= tmp_sticky;
                        state <= NORM_ROUND_3;
                    end if;
                when NORM_ROUND_3 =>
                    if round_bit = '1' and (guard_bit = '1' or sticky_bit = '1') then
                        rounded_man <= std_logic_vector(unsigned(rounded_man) + 1);
                    end if;
                    state <= NORM_PACK;
                when NORM_PACK =>
                    c <= acc_sign & norm_exp & rounded_man(51 downto 0);
                    state <= ENDED;
                when ENDED =>
                    DOUT <= c;
                    DONE <= '1';
                    a <= (others => '0');
                    b <= (others => '0');
                    sign_a <= '0';
                    sign_b <= '0';
                    sign_res <= '0';
                    exp_a <= (others => '0');
                    exp_b <= (others => '0');
                    man_a <= (others => '0');
                    man_b <= (others => '0');
                    exp_res <= (others => '0');
                    man_res <= (others => '0');
                    acc_sign <= '0';
                    acc_man_reg <= (others => '0');
                    acc_exp_reg <= (others => '0');
                    man_a_106 <= (others => '0');
                    bias <= (others => '0');
                    GETN_reg <= '0';
                    MPTY_reg <= '0';
                    iready <= '0';
                    acc_step_done <= '0';
                    norm_step_done <= '0';
                    tmp_sticky <= '0';
                    tmp_man <= (others => '0');
                    norm_man <= (others => '0');
                    norm_exp <= (others => '0');
                    rounded_man <= (others => '0');
                    round_bit <= '0';
                    guard_bit <= '0';
                    sticky_bit <= '0';
                    exp_diff <= 0;
                    leading_zeros <= 0;
                    norm_shift_count <= 0;
                    acc_shift_count <= 0;
                    state <= IDLE;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end v0;
