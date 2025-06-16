----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/10/2025 10:37:39 AM
-- Design Name: 
-- Module Name: CACHE - v0
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

entity CACHE is
    Port ( RESET : in STD_LOGIC;
           CLOCK : in STD_LOGIC;
           ADDR : in STD_LOGIC_VECTOR (6 downto 0);
           WE : in STD_LOGIC;
           DIN : in STD_LOGIC_VECTOR (63 downto 0);
           DOUT : out STD_LOGIC_VECTOR (63 downto 0);
           MPTY : out STD_LOGIC;
           FLL : out STD_LOGIC;
           DREADY: out STD_LOGIC;
           NE : in STD_LOGIC);
end CACHE;

architecture v0 of CACHE is

    type state_type is (IDLE, LOAD, UNLOAD, EMPTY, FULL);
    signal state : state_type := IDLE;
    
    type mem_array is array (0 to 127) of std_logic_vector(63 downto 0);
    signal memory : mem_array := (others => (others => '0'));

    signal count : integer range 0 to 128 := 0;

begin

    process(CLOCK, RESET)
    begin
        if RESET = '1' then
            state <= IDLE;
            count <= 0;
            MPTY <= '1';
            FLL <= '0';
            DREADY <= '0';
            DOUT <= (others => '0');
            memory <= (others => (others => '0'));
        elsif rising_edge(CLOCK) then
            case state is
                when IDLE =>
                    if WE = '1' and count < 128 then
                        state <= LOAD;
                    elsif WE = '0' and count > 0 and rising_edge(NE) then
                        DREADY <= '0';
                        state <= UNLOAD;
                    else
                        state <= IDLE;
                    end if;
                when LOAD =>
                    memory(to_integer(unsigned(ADDR))) <= DIN;
                    MPTY <= '0';
                    FLL <= '0';
                    if count < 100 then
                        count <= count + 1;
                    end if;
                    if count + 1 = 100 then
                        state <= FULL;
                    else
                        state <= IDLE;
                    end if;
                when UNLOAD =>
                    DOUT <= memory(to_integer(unsigned(ADDR)));
                    DREADY <= '1';
                    MPTY <= '0';
                    FLL <= '0';
                    if count > 0 then
                        count <= count - 1;
                    end if;
                    if count - 1 = 0 then
                        state <= EMPTY;
                    else
                        state <= IDLE;
                    end if;
                when EMPTY =>
                    MPTY <= '1';
                    FLL <= '0';
                    if WE = '1' then
                        state <= LOAD;
                    else
                        state <= EMPTY;
                    end if;
                when FULL =>
                    FLL <= '1';
                    MPTY <= '0';
                    if WE = '0' then
                        state <= UNLOAD;
                    else
                        state <= FULL;
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end v0;
