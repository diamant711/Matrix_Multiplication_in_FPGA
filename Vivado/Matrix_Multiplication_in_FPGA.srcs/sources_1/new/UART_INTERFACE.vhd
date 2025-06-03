library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_INTERFACE is
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
end UART_INTERFACE;

architecture V0 of UART_INTERFACE is
type SM1_stati is (SM1_iDLE, SM1_RECEIVE_DATA, SM1_RECEIVE_STOP_BIT);
signal SM1_stato: SM1_stati;
type SM2_stati is (SM2_RESET, SM2_SEND_START_BIT, SM2_SEND_DATA, SM2_SEND_STOP_BIT, SM2_IDLE);
signal SM2_stato: SM2_stati;
type SM3_stati is (SM3_WAIT_FOR_TX_COMMAND, SM3_WAIT_FOR_ACK);
signal SM3_stato: SM3_stati;

signal UART_SEND_TX_reg : std_logic;
signal SM2_Bits_to_send : unsigned(2 downto 0);
signal UART_RX_VECT, TX_VECT, TX_FIFO : std_logic_vector(7 downto 0);
signal TX_FIFO_LOADED : std_logic;
signal UART_TX_Ack, UART_TX_Ack_reg : std_logic;
signal UART_Sync_RX, UART_Sync_TX : std_logic;
signal UART_Sync_counter : unsigned(UART_SYNC'length-1 downto 0);
signal UART_OS_counter : unsigned(UART_OS'length-1 downto 0);
signal UART_RX_reg, UART_RX_reg1 : std_logic;

signal UART_OS_s1, UART_OS_s2, UART_OS_s3, UART_RX_IN, UART_RX_IN_reg, UART_RX_IN_valid : std_logic; 
signal SM1_Bits_to_receive : unsigned(2 downto 0);
begin

P0_receiver_over_sampler : process (Clock)
begin
    if rising_edge(Clock) then
        UART_RX_IN_valid <= '0';
        if (UART_SYNC_RX = '1') then
            case UART_OS_counter is
                when "11" =>
                    UART_OS_s3 <= UART_RX_reg;
                when "10" =>
                    UART_OS_s2 <= UART_RX_reg;
                when "01" =>
                    UART_OS_s1 <= UART_RX_reg;
                when others =>
                    UART_RX_IN <= (UART_OS_s1 and UART_OS_s2) or (UART_OS_s1 and UART_OS_s3) or (UART_OS_s2 and UART_OS_s3);
                    UART_RX_IN_valid <= '1';
            end case;        
        end if;
    end if;
end process P0_receiver_over_sampler;

P0_receiver_logic : process (Clock)
begin
    if rising_edge(Clock) then
        if (Reset = '1') then
            UART_RX_DATA <= (others => '0');
            UART_RX_DONE <= '0';
            SM1_stato <= SM1_IDLE;
            SM1_Bits_to_receive <= to_unsigned(7, 3);
            UART_RX_IN_reg <= '0';
            UART_RX_VECT <= (others => '0');
        else
            UART_RX_DONE <= '0';
            if (UART_RX_IN_valid = '1') then
                UART_RX_IN_reg <= UART_RX_IN;
                case SM1_stato is
                when SM1_IDLE =>
                    SM1_stato <= SM1_IDLE;
                    if (UART_RX_IN_reg = '1' and UART_RX_IN = '0') then
                        SM1_Bits_to_receive <= to_unsigned(7, 3);
                        SM1_stato <= SM1_RECEIVE_DATA;
                    end if;
                when SM1_RECEIVE_DATA =>
                    SM1_stato <= SM1_RECEIVE_DATA;
                    UART_RX_VECT <= UART_RX_IN & UART_RX_VECT(7 downto 1);
                    if (SM1_Bits_to_receive = 0) then
                        SM1_Bits_to_receive <= to_unsigned(7,3);
                        SM1_stato <= SM1_RECEIVE_STOP_BIT;
                    else
                        SM1_Bits_to_receive <= SM1_Bits_to_receive - 1;
                    end if;
                when SM1_RECEIVE_STOP_BIT =>
                    SM1_stato <= SM1_IDLE;
                    if (UART_RX_IN = '1') then
                        UART_RX_DATA <= UART_RX_VECT;
                        UART_RX_DONE <= '1';
                    end if;                                      
                    when others =>
                        SM1_stato <= SM1_IDLE;
            end case;
            end if;
        end if;    
    end if;
end process;

P1_UART_Clock : process (Clock)
begin
    if rising_edge(Clock) then
        if (Reset = '1') then
            UART_Sync_counter <= UART_SYNC;
            UART_OS_counter <= UART_OS;
            UART_Sync_RX <= '0';
            UART_Sync_TX <= '0';
        else
            UART_RX_reg <= D_IN;
            UART_RX_reg1 <= UART_RX_reg;
            UART_Sync_RX <= '0';
            UART_Sync_TX <= '0';
            if (UART_RX_reg = '0' and UART_RX_reg1 = '1') then
                UART_Sync_RX <= '1';
                UART_Sync_TX <= '1';
                UART_Sync_counter <= UART_SYNC;
                UART_OS_counter <= UART_OS;
            else
                if (UART_Sync_counter = 0) then
                    UART_Sync_RX <= '1'; 
                    UART_Sync_counter <= UART_SYNC;
                    if (UART_OS_counter = 0) then
                        UART_Sync_TX <= '1';
                        UART_OS_counter <= UART_OS;
                    else
                        UART_OS_counter <= UART_OS_counter - 1;
                    end if;
                else
                    UART_Sync_counter <= UART_Sync_counter - 1;
                end if;
            end if;
        end if;
     end if;
 end process P1_UART_Clock;

P2_transmitter : process (Clock)
begin
    if rising_edge(Clock) then
        if (Reset = '1') then
            SM2_stato <= SM2_RESET;
            UART_TX_Ack <= '0';
            D_OUT <= '0';
            SM2_Bits_to_send <= to_unsigned(7, 3);
            TX_VECT <= (others => '0');
        else
            D_OUT <= '1';
            UART_TX_Ack <= '0';
            case SM2_stato is
                when SM2_RESET =>
                    SM2_stato <= SM2_RESET;
                    if (Reset = '0') then
                        SM2_stato <= SM2_IDLE;
                        SM2_Bits_to_send <= to_unsigned(7, 3);
                    end if;
                when SM2_IDLE =>
                    SM2_stato <= SM2_IDLE;
                    if (TX_FIFO_LOADED = '1') then
                        SM2_stato <= SM2_SEND_START_BIT;    
                    end if;
                when SM2_SEND_START_BIT =>
                    SM2_stato <= SM2_SEND_START_BIT;
                    SM2_Bits_to_send <= to_unsigned(7, 3);
                    TX_VECT <= TX_FIFO;
                    UART_TX_Ack <= '1';
                    D_OUT <= '0';
                    if (UART_Sync_TX = '1') then
                    SM2_stato <= SM2_SEND_DATA;
                    end if;
                 when SM2_SEND_DATA =>       
                    SM2_stato <= SM2_SEND_DATA;
                    D_OUT <= TX_VECT(0);
                    if (UART_Sync_TX = '1') then
                        if (SM2_Bits_to_send = 0) then
                            SM2_stato <= SM2_SEND_STOP_BIT;
                        else
                            TX_VECT <= '0' & TX_VECT(7 downto 1);
                            SM2_Bits_to_send <= SM2_Bits_to_send - 1;
                        end if;
                    end if;
                 when SM2_SEND_STOP_BIT =>
                    SM2_stato <= SM2_SEND_STOP_BIT;
                    if (UART_Sync_TX = '1') then
                        if (TX_FIFO_LOADED = '1') then
                            SM2_stato <= SM2_SEND_START_BIT;
                        else
                            SM2_stato <= SM2_IDLE;
                        end if;
                    end if;
                  when others =>
                    SM2_stato <= SM2_RESET;
            end case;
        end if;
    end if;    
end process P2_transmitter;

P3 : process(Clock)
begin
    if rising_edge(Clock) then
        UART_SEND_TX_reg <= UART_SEND_TX;
        UART_TX_Ack_reg <= UART_TX_Ack;
        UART_TX_READY <= not TX_FIFO_LOADED;
        if (Reset = '1') then
            TX_FIFO_LOADED <= '0';
            TX_FIFO <= (others => '0');
            SM3_stato <= SM3_WAIT_FOR_TX_COMMAND;
        else
            case SM3_stato is
                when SM3_WAIT_FOR_TX_COMMAND =>
                    TX_FIFO_LOADED <= '0';
                    SM3_stato <= SM3_WAIT_FOR_TX_COMMAND;
                    if ((UART_SEND_TX = '1') and (UART_SEND_TX_reg = '0')) then
                        SM3_stato <= SM3_WAIT_FOR_ACK;
                         TX_FIFO <= UART_TX_DATA;
                    end if;                    
                when SM3_WAIT_FOR_ACK =>
                    TX_FIFO_LOADED <= '1';
                    SM3_stato <= SM3_WAIT_FOR_ACK;
                    if ((UART_TX_Ack = '1') and (UART_TX_Ack_reg = '0')) then
                        SM3_stato <= SM3_WAIT_FOR_TX_COMMAND;
                    end if;
                when others =>
                    SM3_stato <= SM3_WAIT_FOR_TX_COMMAND;
             end case;       
        end if;
    end if;   
end process;
end V0;