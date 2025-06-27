library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity UART_RECEIVER is
Port (
    Clock : in std_logic;
    Reset : in std_logic;
    
    UART_RX_DATA : in std_logic_vector(7 downto 0);
    UART_RX_DONE : in std_logic;
    UART_TX_DATA : out std_logic_vector(7 downto 0);
    UART_TX_READY : in std_logic;
    UART_SEND_TX : out std_logic;    
    
    MEM_ADDRESS_OUT : out std_logic_vector(13 downto 0);
    MEM_DATA_OUT : out std_logic_vector(63 downto 0);
    MEM_DATA_IN_A, MEM_DATA_IN_B, MEM_DATA_IN_C, MEM_DATA_IN_D : in std_logic_vector(63 downto 0);
    MEM_A_EN, MEM_B_EN, MEM_C_EN, MEM_D_EN : out std_logic;
    MEM_Write_en : out std_logic
    );
end UART_RECEIVER;

architecture V0 of UART_RECEIVER is

type SM_stati is (SM_Reset, SM_Receive, SM_Validate, SM_MEM_access, SM_MEM_wait, SM_MEM_done, SM_Reply, SM_UART_Send);
signal SM_stato: SM_stati;

signal Counter_1_MHz : unsigned(6 downto 0); -- da 0 a 99
signal WD_Counter : unsigned(10 downto 0); -- da 0 a 2048 (2 ms)
signal SM_WD, Clock_1_MHz : std_logic;

signal SM_Counter : unsigned(3 downto 0);

signal UART_HEADER : std_logic_vector(7 downto 0);
signal MEM_ADDRESS : std_logic_vector(15 downto 0);
signal MEM_DATA : std_logic_vector(63 downto 0);
signal UART_CHKSUM, UART_CALCULATED_CHKSUM, UART_DATA : std_logic_vector(7 downto 0);

begin

WD_Manager : process(Clock)
begin
    if rising_edge(Clock) then
        Clock_1_MHz <= '0';
        SM_WD <= '0';
        if (Reset = '1') then
            Counter_1_MHz <= (others => '0');
            WD_Counter <= (others => '0');
        else
            if Counter_1_MHz = to_unsigned(99, Counter_1_MHz'length) then
                Counter_1_MHz <= (others => '0');
                Clock_1_MHz <= '1';
            else
                Counter_1_MHz <= Counter_1_MHz + 1;
            end if;
            if (UART_RX_DONE = '1') then
                WD_Counter <= (others =>'0');
            else
                if (Clock_1_MHz = '1') then
                    if WD_Counter = "11111111111" then
                        SM_WD <= '1';
                    else
                        WD_Counter <= WD_Counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;


UART_Receiver : process(Clock)
begin
    if rising_edge(Clock) then
        MEM_Write_en <= '0';
        MEM_A_EN <= '0';
        MEM_B_EN <= '0';
        MEM_C_EN <= '0';
        MEM_D_EN <= '0';
        UART_SEND_TX <= '0';
        if (Reset = '1' or SM_WD = '1') then
            SM_stato <= SM_Reset;
        else
            case SM_stato is
                when SM_Reset =>
                    SM_stato <= SM_Receive;
                    SM_Counter <= (others => '0');
					UART_CALCULATED_CHKSUM <= (others => '0');
                when SM_Receive =>
                    SM_stato <= SM_Receive;
                    if (UART_RX_DONE = '1') then
                        UART_CALCULATED_CHKSUM <= UART_CALCULATED_CHKSUM xor UART_RX_DATA;
						if (SM_Counter = "1011") then
                            SM_stato <= SM_Validate;
                        else 
                            SM_Counter <= SM_Counter + 1;
                        end if;
                        case SM_Counter is
							when "0000" => 
								UART_HEADER <= UART_RX_DATA;
							when "0001" =>	
								MEM_ADDRESS(15 downto 8) <= UART_RX_DATA;
							when "0010" => 
								MEM_ADDRESS(7 downto 0) <= UART_RX_DATA;        
							when "0011" => 
								MEM_DATA(63 downto 56) <= UART_RX_DATA;
                            when "0100" => 
                                MEM_DATA(55 downto 48) <= UART_RX_DATA;
                            when "0101" => 
                                MEM_DATA(47 downto 40) <= UART_RX_DATA;
                            when "0110" => 
                                MEM_DATA(39 downto 32) <= UART_RX_DATA;
                            when "0111" => 
                                MEM_DATA(31 downto 24) <= UART_RX_DATA;
                            when "1000" => 
                                MEM_DATA(23 downto 16) <= UART_RX_DATA;
                            when "1001" => 
                                MEM_DATA(15 downto 8) <= UART_RX_DATA;
                            when "1010" => 
                                MEM_DATA(7 downto 0) <= UART_RX_DATA;
							when others =>
								UART_CHKSUM <= UART_RX_DATA;
						end case;
                    end if;
				when SM_Validate =>
					if (UART_CHKSUM = UART_CALCULATED_CHKSUM) then
						SM_Stato <= SM_MEM_access;
					else
						SM_Stato <= SM_Reset;
					end if;
				when SM_MEM_access =>
					SM_Stato <= SM_MEM_wait;
                    SM_Counter <= (others => '0');
                    MEM_ADDRESS_OUT <= MEM_ADDRESS(13 downto 0);
                    MEM_DATA_OUT <= MEM_DATA;
                    MEM_Write_en <= UART_HEADER(0);
					if MEM_ADDRESS(15 downto 14) = "00" then
					   MEM_A_EN <= '1';
					end if;
					if MEM_ADDRESS(15 downto 14) = "01" then
					   MEM_B_EN <= '1';
					end if;
					if MEM_ADDRESS(15 downto 14) = "10" then
					   MEM_C_EN <= '1';
					end if;
					if MEM_ADDRESS(15 downto 14) = "11" then
					   MEM_D_EN <= '1';
					end if;
				when SM_MEM_wait =>
                    SM_Stato <= SM_MEM_wait;
                    if (SM_Counter = "0010") then
						SM_Stato <= SM_MEM_done;
                    else
                        SM_Counter <= SM_Counter + 1;
                    end if;
                when SM_MEM_done =>
                    if UART_HEADER(1) = '0' then -- write
                        SM_Stato <= SM_Reset;
                    else
                        SM_Stato <= SM_Reply;
                        case MEM_ADDRESS(15 downto 14) is
                            when "00" =>
                                MEM_DATA <= MEM_DATA_IN_A;
                            when "01" =>
                                MEM_DATA <= MEM_DATA_IN_B;
                            when "10" =>
                                MEM_DATA <= MEM_DATA_IN_C;
                            when others =>
                                MEM_DATA <= MEM_DATA_IN_D;
                         end case;
                        SM_Counter <= (others => '0');
                        UART_CHKSUM <= (others => '0');
                        UART_TX_DATA <= "00000000";
                    end if;
                when SM_Reply =>
					SM_stato <= SM_Reply;
                    if (UART_TX_READY = '1') then
						SM_Stato <= SM_UART_Send;
						if (SM_Counter = "1011") then
                            SM_stato <= SM_Reset;
                        else 
                            SM_Counter <= SM_Counter + 1;
                        end if;
                        case SM_Counter is
							when "0000" => 
								UART_DATA <= "00000000"; -- header
								UART_CALCULATED_CHKSUM <= "00000000";
							when "0001" => 
								UART_DATA <= MEM_ADDRESS(15 downto 8);
							when "0010" => 
								UART_DATA <= MEM_ADDRESS(7 downto 0);
							when "0011" => 
								UART_DATA <= MEM_DATA(63 downto 56); 
							when "0100" => 
								UART_DATA <= MEM_DATA(55 downto 48);
							when "0101" => 
								UART_DATA <= MEM_DATA(47 downto 40); 
							when "0110" => 
								UART_DATA <= MEM_DATA(39 downto 32); 
							when "0111" => 
								UART_DATA <= MEM_DATA(31 downto 24); 
							when "1000" => 
								UART_DATA <= MEM_DATA(23 downto 16); 
							when "1001" => 
								UART_DATA <= MEM_DATA(15 downto 8); 
							when "1010" => 
								UART_DATA <= MEM_DATA(7 downto 0);
							when others => 
								UART_DATA <= UART_CALCULATED_CHKSUM;
						end case;
					end if;
				when SM_UART_Send =>
				    SM_Stato <= SM_Reply;
	                UART_SEND_TX <= '1';
	                UART_TX_DATA <= UART_DATA;
	                UART_CALCULATED_CHKSUM <= UART_CALCULATED_CHKSUM xor UART_DATA;			    
				when others =>
					SM_stato <= SM_Reset;
            end case;
        end if;
    end if;
end process;
end V0;