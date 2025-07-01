library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_TOP is
end TB_TOP;

architecture Behavioral of TB_TOP is

    -- Component declaration for the Unit Under Test (UUT)
    component TOP
        Port (
            UART_D_IN : in STD_LOGIC;
            UART_D_OUT : out STD_LOGIC;
            Reset : in STD_LOGIC;
            Clock_100MHz : in STD_LOGIC;
            INNER_PROD_DONE : out STD_LOGIC
        );
    end component;

    signal UART_D_IN       : STD_LOGIC := '1';
    signal UART_D_OUT      : STD_LOGIC;
    signal Reset           : STD_LOGIC := '0';
    signal Clock_100MHz    : STD_LOGIC := '0';
    signal INNER_PROD_DONE : STD_LOGIC;

    constant BIT_PERIOD : time := 8.68 us; -- 1 / 115200 baud

    -- Conversion function for hex print
    function to_hex_char(val : std_logic_vector(3 downto 0)) return character is
        variable result : character;
    begin
        case to_integer(unsigned(val)) is
            when 0  => result := '0';
            when 1  => result := '1';
            when 2  => result := '2';
            when 3  => result := '3';
            when 4  => result := '4';
            when 5  => result := '5';
            when 6  => result := '6';
            when 7  => result := '7';
            when 8  => result := '8';
            when 9  => result := '9';
            when 10 => result := 'A';
            when 11 => result := 'B';
            when 12 => result := 'C';
            when 13 => result := 'D';
            when 14 => result := 'E';
            when others => result := 'F';
        end case;
        return result;
    end;

begin

    uut: TOP
        port map (
            UART_D_IN => UART_D_IN,
            UART_D_OUT => UART_D_OUT,
            Reset => Reset,
            Clock_100MHz => Clock_100MHz,
            INNER_PROD_DONE => INNER_PROD_DONE
        );

    -- Clock generation
    clock_process : process
    begin
        while true loop
            Clock_100MHz <= '0';
            wait for 5 ns;
            Clock_100MHz <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Stimulus
    stim_proc: process
        procedure uart_send_byte(data : std_logic_vector(7 downto 0)) is
        begin
            -- Start bit
            UART_D_IN <= '0';
            wait for BIT_PERIOD;

            -- Data bits (LSB first)
            for i in 0 to 7 loop
                UART_D_IN <= data(i);
                wait for BIT_PERIOD;
            end loop;

            -- Stop bit
            UART_D_IN <= '1';
            wait for BIT_PERIOD;
        end procedure;




    begin
        -- Reset
        Reset <= '1';
        wait for 100 ns;
        Reset <= '0';
        wait for 2 ms;

        -- ============ WRITE 1 to Mem A @ 0x0000 ============

        -- Byte 0: FF (Write command)
        uart_send_byte(x"FF");

        -- Byte 1: Address LSB = 00
        uart_send_byte(x"00");

        -- Byte 2: Address MSB (bits 14-15 = 00 for Mem A)
        uart_send_byte(x"00");

        -- Bytes 3-10: 64-bit data = 0x0000000000000001
        uart_send_byte(x"00");
        uart_send_byte(x"00");
        uart_send_byte(x"00");
        uart_send_byte(x"00");
        uart_send_byte(x"00");
        uart_send_byte(x"00");
        uart_send_byte(x"00");
        uart_send_byte(x"01");

        -- Byte 11: Checksum XOR dei byte precedenti
        uart_send_byte(x"FF" xor x"00" xor x"00" xor x"00" xor x"00" xor x"00" xor x"00" xor x"00" xor x"00" xor x"00" xor x"01");

        wait for 1 ms;

        -- ============ READ Mem A @ 0x0000 ============

        -- Byte 0: 00 (Read command)
        uart_send_byte(x"00");

        -- Byte 1: Address LSB = 00
        uart_send_byte(x"00");

        -- Byte 2: Address MSB = 00 (Mem A)
        uart_send_byte(x"00");

        -- Byte 3: Checksum
        uart_send_byte(x"00" xor x"00" xor x"00");

        -- Wait and decode UART response
        --uart_read_response;

        wait;
    end process;

    uart_read_response: process
        type byte_array is array (0 to 10) of std_logic_vector(7 downto 0);
        variable received_packet : byte_array;
        variable msg : string(1 to 100);
        variable idx : integer := 17;  -- partiamo da dopo "UART Received: "
    begin
        msg(1 to 16) := "UART Received:  ";
        for byte_idx in 0 to 10 loop
            --Attesa start bit
            wait until UART_D_OUT = '0';
            wait for BIT_PERIOD / 2;
            --Legge i bit LSB first
            for bit_idx in 0 to 7 loop
                wait for BIT_PERIOD;
                received_packet(byte_idx)(bit_idx) := UART_D_OUT;
            end loop;
            --Attesa stop bit
            wait for BIT_PERIOD;
        end loop;
        -- Composizione stringa esadecimale
        for i in 0 to 10 loop
            msg(idx)     := to_hex_char(received_packet(i)(7 downto 4)); -- high nibble
            msg(idx + 1) := to_hex_char(received_packet(i)(3 downto 0)); -- low nibble
            msg(idx + 2) := ' ';
            idx := idx + 3;
        end loop;
        report msg(1 to idx - 1) severity NOTE;
    end process;
    
    uart_send_response: process
        type byte_array is array (0 to 10) of std_logic_vector(7 downto 0);
        variable received_packet : byte_array;
        variable msg : string(1 to 100);
        variable idx : integer := 17;  -- partiamo da dopo "UART Received: "
    begin
        msg(1 to 16) := "UART Received:  ";
        for byte_idx in 0 to 10 loop
            --Attesa start bit
            wait until UART_D_IN = '0';
            wait for BIT_PERIOD / 2;
            --Legge i bit LSB first
            for bit_idx in 0 to 7 loop
                wait for BIT_PERIOD;
                received_packet(byte_idx)(bit_idx) := UART_D_IN;
            end loop;
            --Attesa stop bit
            wait for BIT_PERIOD;
        end loop;
        -- Composizione stringa esadecimale
        for i in 0 to 10 loop
            msg(idx)     := to_hex_char(received_packet(i)(7 downto 4)); -- high nibble
            msg(idx + 1) := to_hex_char(received_packet(i)(3 downto 0)); -- low nibble
            msg(idx + 2) := ' ';
            idx := idx + 3;
        end loop;
        report msg(1 to idx - 1) severity NOTE;
    end process;

end Behavioral;
