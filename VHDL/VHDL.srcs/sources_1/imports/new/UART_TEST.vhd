library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TEST is
    Port ( UART_D_IN : in STD_LOGIC;
           UART_D_OUT, UART_W_Rneg : out STD_LOGIC;
           Reset : in STD_LOGIC;
           Clock_100MHz : in STD_LOGIC);
end UART_TEST;

architecture V0 of UART_TEST is
component UART_INTERFACE
    Generic (
        constant UART_SYNC : unsigned(7 downto 0) := to_unsigned(216,8); -- 115200 baud con 100 MHz clock
        constant UART_OS : unsigned(1 downto 0) := to_unsigned(3,2)
    );
    Port ( Clock, D_IN : in STD_LOGIC; 
           Reset, UART_SEND_TX : in STD_LOGIC;
           UART_RX_DONE, UART_TX_READY, D_OUT : out STD_LOGIC;
           UART_TX_DATA : in STD_LOGIC_VECTOR(7 downto 0);
           UART_RX_DATA : out STD_LOGIC_VECTOR(7 downto 0)
           );
end component;

signal UART_SEND_TX, UART_RX_DONE : std_logic; 
signal UART_TX_DATA, UART_RX_DATA : std_logic_vector(7 downto 0);
signal Counter : unsigned(9 downto 0);
signal Counter_1MHz : unsigned(6 downto 0);
signal Sync_1MHz : std_logic;

type SM_stati is (Read, Write, Reserve_bus_1, Reserve_bus_2, Release_bus);
signal SM_stato: SM_stati;

begin

DUT1 : UART_INTERFACE
    port map 
    (
        Clock => Clock_100MHz,
        D_IN => UART_D_IN,
        Reset => Reset,
        D_OUT => UART_D_OUT,
        UART_SEND_TX => UART_SEND_TX, 
        UART_TX_READY => open,
        UART_RX_DONE => UART_RX_DONE, 
        UART_TX_DATA => UART_TX_DATA, 
        UART_RX_DATA => UART_RX_DATA
    );

PSync_1MHz : process(Clock_100MHz)
begin
    if rising_edge(Clock_100MHz) then
      if (Reset = '1') then
        Sync_1MHz <= '0';
        Counter_1MHz <= to_unsigned(99,Counter_1MHz'length);
      else
        if (Counter_1MHz = 0) then
            Counter_1MHz <= to_unsigned(99,Counter_1MHz'length);
            Sync_1MHz <= '1';
        else
            Counter_1MHz <= Counter_1MHz - 1;
            Sync_1MHz <= '0';
        end if;
      end if;
    end if;
end process;
            
P0_echo : process(Clock_100MHz)
begin
    if rising_edge(Clock_100MHz) then
      if (Reset = '1') then
            SM_stato <= Read;
            UART_W_Rneg <= '0';
            UART_SEND_TX <= '0';
            UART_TX_DATA <= (others=>'0');
            Counter <= (others => '0');
        else
            UART_SEND_TX <= '0';
            UART_W_Rneg <= '0';
            case SM_stato is
                when Read =>
                    SM_stato <= Read;
                    if UART_RX_DONE = '1' then
                        SM_stato <= Reserve_bus_1;
                        Counter <= to_unsigned(999,Counter'length);
                        UART_TX_DATA <= UART_RX_DATA;
                    end if;
                when Reserve_bus_1 =>
                    SM_stato <= Reserve_bus_1;
                    if (Sync_1MHz = '1') then
                        if (Counter = 0) then
                            SM_stato <= Reserve_bus_2;
                            Counter <= to_unsigned(999,Counter'length);
                        else
                            Counter <= Counter - 1;
                        end if;
                     end if;
                when Reserve_bus_2 =>
                    SM_stato <= Reserve_bus_2;
                    UART_W_Rneg <= '1';
                    if (Sync_1MHz = '1') then
                        if (Counter = 0) then
                            SM_stato <= Write;
                        else
                            Counter <= Counter - 1;
                        end if;
                    end if;
                when Write =>
                    SM_stato <= Release_bus;
                    UART_W_Rneg <= '1';
                    UART_SEND_TX <= '1'; 
                    Counter <= to_unsigned(999,Counter'length);
                when Release_bus =>
                    SM_stato <= Release_bus;
                    UART_W_Rneg <= '1';
                    if (Sync_1MHz = '1') then
                        if (Counter = 0) then
                            SM_stato <= Read;
                        else
                            Counter <= Counter - 1;
                        end if;
                    end if;
                when others =>
                    SM_stato <= Read;
            end case;
        end if;
    end if;
end process;
end V0;
