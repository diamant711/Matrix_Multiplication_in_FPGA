library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity TB_UART_TEST is
end TB_UART_TEST;

architecture V0 of TB_UART_TEST is
component UART_TEST
    Port ( UART_D_IN : in STD_LOGIC;
           UART_D_OUT, UART_W_Rneg : out STD_LOGIC;
           Reset : in STD_LOGIC;
           Clock_100MHz : in STD_LOGIC);
end component;

signal TB_UART_D_IN, TB_UART_D_OUT, TB_UART_W_Rneg, TB_Reset, TB_Clock_100MHz : STD_LOGIC;
constant PERIOD : time := 10 ns;
begin
DUT1 : UART_TEST
    Port map
    (
        UART_D_IN => TB_UART_D_IN, 
        UART_D_OUT => TB_UART_D_OUT, 
        UART_W_Rneg => TB_UART_W_Rneg, 
        Reset => TB_Reset, 
        Clock_100MHz => TB_Clock_100MHz
    );

--clock 100 MHZ
P0_100_MHZ_Clock : process
begin
    TB_Clock_100MHz <= '0';
    wait for PERIOD/2;
    TB_Clock_100MHz <= '1';
    wait for PERIOD/2;
end process;    
        
P1_Reset : process
begin
    TB_Reset <= '0';
    wait for PERIOD;
    TB_Reset <= '1';
    wait for PERIOD;
    TB_Reset <= '0';
    wait;
end process;            
        
P2_Test : process
begin
TB_UART_D_IN <= '1';
wait for 86810 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '1';

wait for 600000 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '1';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '1';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '1';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '1';
wait for 8681 ns;
TB_UART_D_IN <= '0';
wait for 8681 ns;
TB_UART_D_IN <= '1';



wait;
end process;

end V0;
