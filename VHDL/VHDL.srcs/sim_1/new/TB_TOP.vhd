library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_TOP is
end TB_TOP;

architecture Behavioral of TB_TOP is

    -- Componenti
    component TOP
        Port (
            UART_D_IN       : in  std_logic;
            UART_D_OUT      : out std_logic;
            Reset           : in  std_logic;
            Clock_100MHz    : in  std_logic;
            INNER_PROD_DONE : out std_logic
        );
    end component;

    -- Segnali
    signal UART_D_IN       : std_logic := '1';
    signal UART_D_OUT      : std_logic;
    signal Reset           : std_logic := '0';
    signal Clock_100MHz    : std_logic := '0';
    signal INNER_PROD_DONE : std_logic;

    constant BIT_PERIOD : time := 8.68 us;

begin
    -- Istanza UUT
    uut: TOP
        port map (
            UART_D_IN       => UART_D_IN,
            UART_D_OUT      => UART_D_OUT,
            Reset           => Reset,
            Clock_100MHz    => Clock_100MHz,
            INNER_PROD_DONE => INNER_PROD_DONE
        );

    -- Clock 100 MHz
    clock_process : process
    begin
        while true loop
            Clock_100MHz <= '0';
            wait for 5 ns;
            Clock_100MHz <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Stimulus process: invia 12 byte via UART
    stim_proc : process
        procedure uart_send_byte(data : std_logic_vector(7 downto 0)) is
        begin
            UART_D_IN <= '0';  -- Start bit
            wait for BIT_PERIOD;
            for i in 0 to 7 loop
                UART_D_IN <= data(i);
                wait for BIT_PERIOD;
            end loop;
            UART_D_IN <= '1';  -- Stop bit
            wait for BIT_PERIOD;
        end procedure;
        procedure uart_send_packet(data : std_logic_vector(11*8-1 downto 0)) is
            variable checksum : std_logic_vector(7 downto 0) := (others => '0');
        begin
            -- Comando WRITE in Mem A @0x0000
            checksum := data(11*8-1 downto 10*8) xor 
                        data(10*8-1 downto  9*8) xor 
                        data( 9*8-1 downto  8*8) xor 
                        data( 8*8-1 downto  7*8) xor 
                        data( 7*8-1 downto  6*8) xor 
                        data( 6*8-1 downto  5*8) xor 
                        data( 5*8-1 downto  4*8) xor 
                        data( 4*8-1 downto  3*8) xor 
                        data( 3*8-1 downto  2*8) xor 
                        data( 2*8-1 downto  1*8) xor 
                        data( 1*8-1 downto  0*8);
            uart_send_byte(data(11*8-1 downto 10*8));  -- Command
            uart_send_byte(data(10*8-1 downto 9*8));  -- Addr MSB
            uart_send_byte(data( 9*8-1 downto 8*8));  -- Addr LSB
            uart_send_byte(data( 8*8-1 downto 7*8));
            uart_send_byte(data( 7*8-1 downto 6*8));
            uart_send_byte(data( 6*8-1 downto 5*8));
            uart_send_byte(data( 5*8-1 downto 4*8));
            uart_send_byte(data( 4*8-1 downto 3*8));
            uart_send_byte(data( 3*8-1 downto 2*8));
            uart_send_byte(data( 2*8-1 downto 1*8));
            uart_send_byte(data( 1*8-1 downto 0*8));
            uart_send_byte(checksum);
        end procedure;
        variable addr : std_logic_vector(13 downto 0);  -- 14 bits for address
        variable full_addr : std_logic_vector(15 downto 0);
        variable packet : std_logic_vector(87 downto 0); -- FF + address + data
    begin
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 2 ms;

--        -- Memory A (0b00XXXXXXXXXXXXX)
--        for i in 0 to 99 loop
--            addr := std_logic_vector(to_unsigned(i, 14));
--            full_addr := "00" & addr;
--            packet := x"FF" & full_addr & x"3FF0000000000000";
--            uart_send_packet(packet);
--            wait for 10 ns;
--        end loop;
    
--        -- Memory B (0b01XXXXXXXXXXXXX)
--        for i in 0 to 99 loop
--            addr := std_logic_vector(to_unsigned(i, 14));
--            full_addr := "01" & addr;
--            packet := x"FF" & full_addr & x"3FF0000000000000";
--            uart_send_packet(packet);
--            wait for 10 ns;
--        end loop;
        addr := std_logic_vector(to_unsigned(0, 14));
        full_addr := "11" & addr;
        packet := x"FF" & full_addr & x"0000000000000001";
        uart_send_packet(packet);
        wait for 10 ns;
        wait;
    end process;

end Behavioral;