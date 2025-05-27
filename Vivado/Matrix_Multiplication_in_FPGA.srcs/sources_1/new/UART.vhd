----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05/23/2025 11:31:05 AM
-- Design Name:
-- Module Name: UART_INTERFACE - V0
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

entity UART_INTERFACE is
    Generic (
        constant UART_SPEED : integer := 100;
        constant UART_SPEED_COUNTER_WIDTH : integer := 14
    );
    Port ( Clock, D_IN : in STD_LOGIC;
           Reset : in STD_LOGIC;
           UART_RX_DONE : out STD_LOGIC;
           UART_RX_DATA : out STD_LOGIC_VECTOR(7 downto 0)
           );
end UART_INTERFACE;

architecture V0 of UART_INTERFACE is
type SM1_stati is (SM1_RESET, SM1_WAIT_FOR_START, SM1_WAIT_FOR_SAMPLE, SM1_SAMPLE, SM1_WAIT_AFTER_SAMPLE);
signal SM1_stato: SM1_stati;
signal D_IN_reg : std_logic;
signal SM1_counter : unsigned(UART_SPEED_COUNTER_WIDTH-1 downto 0);
signal Bits_to_receive : unsigned(3 downto 0);
signal RX_VECT : std_logic_vector(7 downto 0);

begin

P0: process (Clock)
begin
    if rising_edge(Clock) then
        UART_RX_Done <= '0';
        D_IN_reg <= D_IN;
        if (Reset = '1') then
            SM1_stato <= SM1_RESET;
        else
            case SM1_stato is
                when SM1_RESET =>
                    if (Reset = '0') then
                        SM1_stato <= SM1_WAIT_FOR_START;
                        Bits_to_receive <= to_unsigned(8, 4);
                    else
                        SM1_stato <= SM1_RESET;
                    end if;
                when SM1_WAIT_FOR_START =>
                    if (D_IN = '1' and D_IN_reg = '0') then
                        SM1_counter <= to_unsigned(UART_SPEED, UART_SPEED_COUNTER_WIDTH);
                        SM1_stato <= SM1_WAIT_FOR_SAMPLE;
                    else
                        SM1_stato <= SM1_WAIT_FOR_START;
                    end if;
                when SM1_WAIT_FOR_SAMPLE =>
                    if (SM1_counter = 0) then    
                        SM1_counter <= to_unsigned(UART_SPEED, UART_SPEED_COUNTER_WIDTH);
                        SM1_stato <= SM1_SAMPLE;
                    else
                        SM1_counter <= SM1_counter - 1;
                        SM1_stato <= SM1_WAIT_FOR_SAMPLE;
                    end if;
                 when SM1_SAMPLE =>       
                        RX_VECT <= RX_VECT(6 downto 0) & D_IN_reg;
                        SM1_stato <= SM1_WAIT_AFTER_SAMPLE;
                 when SM1_WAIT_AFTER_SAMPLE =>       
                        if (SM1_counter = 0) then  
                            SM1_counter <= to_unsigned(UART_SPEED, UART_SPEED_COUNTER_WIDTH);
                            if (Bits_to_receive = 0) then
                                UART_RX_DATA <= RX_VECT;
                                UART_RX_Done <= '1';
                                SM1_stato <= SM1_WAIT_FOR_START;
                            else
                                Bits_to_receive <= Bits_to_receive - 1;
                                SM1_stato <= SM1_WAIT_FOR_SAMPLE;
                            end if;
                        else
                            SM1_counter <= SM1_counter - 1;
                            SM1_stato <= SM1_WAIT_AFTER_SAMPLE;
                        end if;                                
                    when others =>
                        SM1_stato <= SM1_RESET;
            end case;
        end if;
    end if;    
end process;

end V0;