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
           WE : in STD_LOGIC;
           WDONE: out STD_LOGIC;
           DIN : in STD_LOGIC_VECTOR (63 downto 0);
           DOUT : out STD_LOGIC_VECTOR (63 downto 0);
           MPTY : out STD_LOGIC;
           FLL : out STD_LOGIC;
           DREADY: out STD_LOGIC; -- Data Ready to be read
           NE : in STD_LOGIC);    -- Next Element Parallel input Serial Output
end CACHE;

architecture v0 of CACHE is

    type state_type is (IDLE, LOAD, UNLOAD, FULL, EMPTY);
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
            WDONE <= '0';
            DREADY <= '0';
            DOUT <= (others => '0');
            memory <= (others => (others => '0'));
        elsif rising_edge(CLOCK) then
            case state is
                when IDLE =>
                    WDONE <= '0';
                    DREADY <= '0';
                    if WE = '0' and count > 0 and NE = '1' then
                        state <= UNLOAD;
                    elsif WE = '1' and count < 100 then
                        state <= LOAD;
                    elsif count = 100 then
                        MPTY <= '0';
                        FLL <= '1';
                        state <= IDLE;
                    elsif count = 0 then
                        MPTY <= '1';
                        FLL <= '0';
                        state <= IDLE;
                    else 
                        state <= IDLE;
                    end if;
                when LOAD =>
                    memory(count) <= DIN;
                    count <= count + 1;
                    MPTY <= '0';
                    FLL <= '0';
                    WDONE <= '1';
                    state <= IDLE;
                when UNLOAD =>
                    DOUT <= memory(count - 1);
                    memory(count - 1) <= (others => '0');
                    count <= count - 1;
                    MPTY <= '0';
                    FLL <= '0';
                    DREADY <= '1';
                    state <= IDLE;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end v0;
