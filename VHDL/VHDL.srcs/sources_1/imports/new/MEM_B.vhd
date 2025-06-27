library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity MEM_B is
Port (
    Clock : in std_logic;
    Reset : in std_logic;
    
    DATA_OUT : out std_logic_vector(63 downto 0);
    DATA_OUT_ADDR : in std_logic_vector(13 downto 0);
    DATA_OUT_VALID : out std_logic;
    DATA_OUT_ADDR_VALID : in std_logic;
    
    MEM_DATA_IN : in std_logic_vector(63 downto 0);
    MEM_DATA_OUT : out std_logic_vector(63 downto 0);
    MEM_ADDR : in std_logic_vector(13 downto 0);
    MEM_Write_en, MEM_en : in std_logic
     );
end MEM_B;

architecture V0 of MEM_B is
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(63 DOWNTO 0) 
  );
END COMPONENT;

signal Counter : unsigned(1 downto 0);

type SM_stati is (SM_Reset, SM_Idle, SM_Wait_for_data, SM_Data_Valid);
signal SM_stato: SM_stati;

begin

A_MEM : blk_mem_gen_0
  PORT MAP (
    clka => Clock,
    ena => MEM_en,
    wea(0) => MEM_Write_en,
    addra => MEM_ADDR,
    dina => MEM_DATA_IN,
    douta => MEM_DATA_OUT,
    clkb => Clock,
    enb => '1',
    web => "0",
    addrb => DATA_OUT_ADDR,
    dinb => (others => '0'),
    doutb => DATA_OUT
  );

Controller : process(Clock)
begin
    if rising_edge(Clock) then
        DATA_OUT_VALID <= '0';
        if (Reset = '1') then
            SM_stato <= SM_Idle;
            Counter <= "00";
        else
            case SM_stato is
                when SM_Idle =>
                    SM_stato <= SM_Idle;
                    if (DATA_OUT_ADDR_VALID = '1') then
                        Counter <= "11";    
                        SM_stato <= SM_Wait_for_data;
                    end if;
                when SM_Wait_for_data=>
                    SM_stato <= SM_Wait_for_data;
                    if (Counter = 0) then
                        SM_stato <= SM_Data_Valid;
                    else
                        Counter <= Counter - 1;
                    end if;
                when SM_Data_Valid=>
                    SM_stato <= SM_Data_Valid;
                    DATA_OUT_VALID <= '1';
                    if (DATA_OUT_ADDR_VALID = '0') then
                        SM_stato <= SM_Idle;
                    end if;
                when others =>
                    SM_stato <= SM_Reset;
            end case;
        end if;
    end if;
end process;
end V0;