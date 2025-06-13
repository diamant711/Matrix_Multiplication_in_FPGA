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
           RDY : out STD_LOGIC;
           DONE : out STD_LOGIC;
           MPTY : in STD_LOGIC);
end DSP;

architecture v0 of DSP is
    
    -- stato
    type state_type is (IDLE, DATAIN, PROC, DECOP, MULT, ACC, NORMROUNDCOMP, ENDED);
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
    signal exp_res : STD_LOGIC_VECTOR(11 downto 0) := (others => '0'); -- 1 bit extra per overflow
    signal man_res : STD_LOGIC_VECTOR(105 downto 0) := (others => '0'); -- 53+53
    signal acc_sign : STD_LOGIC := '0';
    signal acc_man_reg : STD_LOGIC_VECTOR(105 downto 0) := (others => '0'); -- 53+53+1
    signal acc_exp_reg : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal result : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    
    -- variabili di supporto non NUMERIC
    signal carry_12 : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal tmp_12 : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal carry_106 : STD_LOGIC_VECTOR(105 downto 0) := (others => '0');
    signal y_106 : STD_LOGIC_VECTOR(105 downto 0) := (others => '0');
    signal x_106 : STD_LOGIC_VECTOR(105 downto 0) := (others => '0');
    signal tmp_106 : STD_LOGIC_VECTOR(105 downto 0) := (others => '0');
    signal bias : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal borrow_11 : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal borrow_106 : STD_LOGIC_VECTOR(105 downto 0) := (others => '0');
    signal found : STD_LOGIC := '0';
    signal GETN_reg : STD_LOGIC := '0';
    signal iready : STD_LOGIC := '0';
    
    -- Normalizzazione del mantissa (acc_man_reg) e dell'esponente (acc_exp_reg)
    signal tmp_man : std_logic_vector(105 downto 0) := (others => '0');
    signal norm_man : std_logic_vector(105 downto 0);
    signal norm_exp : std_logic_vector(11 downto 0) := (others => '0');
    signal rounded_man : std_logic_vector(52 downto 0); -- 53 bit con 1 implicito
    signal final_exp : std_logic_vector(10 downto 0);
    signal ieee_mantissa : std_logic_vector(51 downto 0);
    signal round_bit : std_logic := '0';
    signal sticky_bit : std_logic := '0';
    
    -- variabili di supporto con NUMERIC
    signal exp_diff : integer;
    signal leading_zeros : integer := 0;

begin

    process(CLOCK, RESET)
    begin
        if RESET = '1' then
        DOUT <= (others => '0');
        a <= (others => '0');
        b <= (others => '0');
        c <= (others => '0');
        GETN <= '0';
        DONE <= '0';
        RDY <= '0';
        GETN_reg <= '0';
        iready <= '0';
        bias <= (others => '0');
        borrow_11 <= (others => '0');
        acc_man_reg <= (others => '0');
        acc_sign <= '0';
        acc_exp_reg <= (others => '0');
        elsif rising_edge(CLOCK) then
            case state is
                when IDLE =>
                    if START = '1' then
                        DONE <= '0';
                        acc_man_reg <= (others => '0');
                        acc_sign <= '0';
                        acc_exp_reg <= (others => '0');
                        state <= PROC;
                    else
                        state <= IDLE;
                    end if;
                when PROC =>
                    if MPTY = '0' and iready = '1' then
                        state <= DECOP;
                    elsif MPTY = '0' and iready = '0' then
                        state <= DATAIN;
                    elsif MPTY = '1' then
                        state <= NORMROUNDCOMP;
                    else
                        state <= IDLE;
                    end if;
                when DATAIN =>
                    if GETN_reg = '0' then
                        GETN <= '1';
                        GETN_reg <= '1';
                        iready <= '0';
                        state <= DATAIN;
                    elsif DAREADY = '1' and DBREADY = '1' and GETN_reg = '1' then
                        GETN <= '0';
                        GETN_reg <= '0';
                        a <= DINA;
                        b <= DINB;
                        iready <= '1';
                        state <= PROC;
                    else
                        state <= DATAIN;
                    end if;
                when DECOP =>
                    sign_a <= a(63);
                    sign_b <= b(63);
                    exp_a  <= a(62 downto 52);
                    exp_b  <= b(62 downto 52);
                    man_a  <= "1" & a(51 downto 0); -- aggiungiamo il bit implicito
                    man_b  <= "1" & b(51 downto 0);
                    -- Reset support variable before MULT stage
                    bias <= "00111111111";
                    man_res <= (others => '0');
                    found <= '1';
                    state <= MULT;
                when MULT =>
                    sign_res <= sign_a xor sign_b; -- <-- SIGN_RES ASSIGN
                    if man_b /= ZERO_53 then
                        if man_b(0) = '1' then
                            --Accumulo a in multiplication_result
                            if found = '1' then
                                carry_106 <= (others => '1'); -- Magic Number
                                x_106 <= man_a;
                                y_106 <= man_res;
                                found <= '0';
                            end if;
                            if carry_106 /= ZERO_106 then
                                tmp_106 <= x_106 xor y_106;
                                carry_106 <= x_106 and y_106;
                                carry_106 <= carry_106(104 downto 0) & "0";
                                x_106 <= tmp_106;
                                y_106 <= carry_106;
                            else
                                man_res <= x_106; -- <-- MAN_RES ACC
                                man_a <= man_a(50 downto 0) & "0";
                                man_b <= "0" & man_b(51 downto 1);
                                found <= '1';
                            end if;
                        else
                            man_a <= man_a(50 downto 0) & "0";
                            man_b <= "0" & man_b(51 downto 1);
                        end if;
                    end if;
                    if exp_b /= ZERO_11 then
                        tmp_12 <= "0" & exp_a xor exp_b;
                        carry_12 <= exp_a and exp_b;
                        carry_12 <= carry_12(10 downto 0) & "0";
                        exp_a <= tmp_12;
                        exp_b <= carry_12;
                    end if;
                    if bias /= ZERO_11 then
                        borrow_11 <= (not exp_a) and bias;
                        exp_a <= exp_a xor bias;
                        bias <= borrow_11(10 downto 0) & "0";
                    end if;
                    if man_b = ZERO_53 and exp_b = ZERO_11 and bias = ZERO_11 then
                        exp_res <= exp_a; -- <-- EXP_RES ASSIGN
                        state <= ACC;
                    else
                        state <= MULT;
                    end if;
                when ACC =>
                    -- fino ad ora abbiamo exp_res(12) e man_res(106) che vanno accumulati
                    -- Qui è l'unico punto in cui uso la STD NUMERIC
                    -- Qui dati i while loop l'esecuzione resta bloccata dentro
                    -- Controllo su esponenti
                    if acc_exp_reg > exp_res then
                        exp_diff <= to_integer(unsigned(acc_exp_reg) - unsigned(exp_res));
                        if exp_diff > 105 then
                            man_res <= (others => '0');
                        else
                            man_res <= man_res(105 - exp_diff downto 0) & (exp_diff downto 1 => '0');
                        end if;
                        exp_res <= acc_exp_reg;
                    elsif exp_res > acc_exp_reg then
                        exp_diff <= to_integer(unsigned(exp_res) - unsigned(acc_exp_reg));
                        if exp_diff > 105 then
                            acc_man_reg <= (others => '0');
                        else
                            acc_man_reg <= acc_man_reg(105 - exp_diff downto 0) & (exp_diff downto 1 => '0');
                        end if;
                        acc_exp_reg <= exp_res;
                    end if;
                    -- Somma o sottrazione in base al segno
                    if sign_res /= acc_sign then
                        if sign_res = '1' then
                            if man_res > acc_man_reg then
                                acc_sign <= '1';
                                --acc_man_reg <= man_res - acc_man_reg;
                                while acc_man_reg /= ZERO_106 loop
                                    borrow_106 <= (not man_res) and acc_man_reg;
                                    man_res <= man_res xor acc_man_reg;
                                    acc_man_reg <= borrow_106(104 downto 0) & "0";
                                end loop;
                                acc_man_reg <= man_res;
                            elsif man_res = acc_man_reg then
                                acc_sign <= '0';
                                acc_man_reg <= (others => '0');
                            else --if man_res < acc_man_reg then
                                acc_sign <= '0';
                                --acc_man_reg <= acc_man_reg - man_res;
                                while man_res /= ZERO_106 loop
                                    borrow_106 <= (not acc_man_reg) and man_res;
                                    acc_man_reg <= acc_man_reg xor man_res;
                                    man_res <= borrow_106(104 downto 0) & "0";
                                end loop;
                            end if;
                        else --if acc_sign = '1' then
                            if man_res > acc_man_reg then
                                acc_sign <= '0';
                                --acc_man_reg <= man_res - acc_man_reg;
                                while acc_man_reg /= ZERO_106 loop
                                    borrow_106 <= (not man_res) and acc_man_reg;
                                    man_res <= man_res xor acc_man_reg;
                                    acc_man_reg <= borrow_106(104 downto 0) & "0";
                                end loop;
                                acc_man_reg <= man_res;
                            elsif man_res = acc_man_reg then
                                acc_sign <= '0';
                                acc_man_reg <= (others => '0');
                            else --if man_res < acc_man_reg then
                                acc_sign <= '1';
                                --acc_man_reg <= acc_man_reg - man_res;
                                while man_res /= ZERO_106 loop
                                    borrow_106 <= (not acc_man_reg) and man_res;
                                    acc_man_reg <= acc_man_reg xor man_res;
                                    man_res <= borrow_106(104 downto 0) & "0";
                                end loop;
                            end if;
                        end if;
                    else
                        --acc_man_reg <= acc_man_reg + man_res;
                        while man_res /= ZERO_106 loop
                            carry_106 <= acc_man_reg and man_res;
                            carry_106 <= carry_106(105 downto 0) & "0";
                            acc_man_reg <= acc_man_reg xor man_res;
                            man_res <= carry_106;
                        end loop;
                    end if;
                    iready <= '0';
                    state <= PROC;
                when NORMROUNDCOMP =>
                    tmp_man <= acc_man_reg;
                    norm_exp <= acc_exp_reg;
                    leading_zeros <= 0;
                    -- Trova leading '1'
                    while leading_zeros < 106 and tmp_man(105) = '0' loop
                        tmp_man <= tmp_man(104 downto 0) & '0';
                        leading_zeros <= leading_zeros + 1;
                    end loop;
                    norm_man <= tmp_man;
                    norm_exp <= std_logic_vector(unsigned(norm_exp) - leading_zeros);
                    -- Arrotondamento (round-to-nearest-even)
                    rounded_man <= norm_man(105 downto 53);
                    round_bit <= norm_man(52);
                    sticky_bit <= '0';
                    for i in 0 to 51 loop
                        if norm_man(i) = '1' then
                            sticky_bit <= '1';
                        end if;
                    end loop;
                    -- Applica arrotondamento (round to nearest even)
                    if (round_bit = '1' and sticky_bit = '1') or
                       (round_bit = '1' and sticky_bit = '0' and norm_man(53) = '1') then
                        rounded_man <= std_logic_vector(unsigned(rounded_man) + 1);
                    end if;
                    -- Controlla overflow del mantissa (carry nel bit 53)
                    if rounded_man(52) = '1' then
                        ieee_mantissa <= rounded_man(51 downto 0); -- taglia il bit implicito
                        final_exp <= norm_exp(10 downto 0);
                    else
                        -- se carry ha causato un bit extra, shiftiamo
                        ieee_mantissa <= rounded_man(50 downto 0) & '0';
                        final_exp <= std_logic_vector(unsigned(norm_exp(10 downto 0)) + 1);
                    end if;
                    -- Componi il double IEEE-754: sign | exp | mantissa
                    result <= acc_sign & final_exp & ieee_mantissa;
                    c <= result;
                    state <= ENDED;
                when ENDED =>
                    DOUT <= c;
                    DONE <= '1';
                    state <= IDLE;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end v0;
