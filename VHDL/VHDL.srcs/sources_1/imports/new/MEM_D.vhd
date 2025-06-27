library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM_D is
Port (
    Clock : in std_logic;
    Reset : in std_logic;
    
    DATA_OUT : out std_logic_vector(63 downto 0);
    
    MEM_DATA_IN : in std_logic_vector(63 downto 0);
    MEM_DATA_OUT : out std_logic_vector(63 downto 0);
    MEM_Write_en, MEM_en : in std_logic);
end MEM_D;

architecture V0 of MEM_D is
signal MEMORY : std_logic_vector(63 downto 0);

begin

Controller : process(Clock)
begin
    if rising_edge(Clock) then
        DATA_OUT <= MEMORY;
        MEM_DATA_OUT <= MEMORY;
        if (Reset = '1') then
            MEMORY <= (others => '0');
        else
            if (MEM_en = '1' and MEM_Write_en = '1') then
                MEMORY <= MEM_DATA_IN;
            end if;
        end if;
    end if;
end process;
end V0;