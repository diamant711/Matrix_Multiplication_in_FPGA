----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06/09/2025 05:06:57 PM
-- Design Name:
-- Module Name: CACHE_LOADER - v0
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
entity CACHE_LOADER is
    Port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        start        : in  std_logic;
        row_select   : in  unsigned(6 downto 0); -- 7 bit per 0..99
        col_select   : in  unsigned(6 downto 0); -- 7 bit per 0..99
        ended         : out std_logic;

        -- Interfaccia lettura matrice A (100x100)
        A_data       : in  std_logic_vector(63 downto 0);
        A_addr       : out unsigned(13 downto 0); -- 14 bit per 100*100 = 10,000 celle

        -- Interfaccia lettura matrice B (100x100)
        B_data       : in  std_logic_vector(63 downto 0);
        B_addr       : out unsigned(13 downto 0);

        -- Interfaccia scrittura ROW (100 word)
        ROW_we       : out std_logic;
        ROW_addr     : out unsigned(6 downto 0);
        ROW_data     : out std_logic_vector(63 downto 0);

        -- Interfaccia scrittura COL (100 word)
        COL_we       : out std_logic;
        COL_addr     : out unsigned(6 downto 0);
        COL_data     : out std_logic_vector(63 downto 0)
    );
end CACHE_LOADER;

architecture v0 of CACHE_LOADER is

    type state_type is (IDLE, LOAD_ROW, LOAD_COL, DONE);
    signal state        : state_type := IDLE;

    signal index        : unsigned(6 downto 0) := (others => '0');

begin

    process(clk, rst)
    begin
        if rst = '1' then
            state     <= IDLE;
            index     <= (others => '0');
            ended      <= '0';

            A_addr    <= (others => '0');
            B_addr    <= (others => '0');
            ROW_we    <= '0';
            COL_we    <= '0';
            ROW_data  <= (others => '0');
            COL_data  <= (others => '0');

        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    ended <= '0';
                    if start = '1' then
                        index <= (others => '0');
                        state <= LOAD_ROW;
                    end if;

                when LOAD_ROW =>
                    -- Calcolo indirizzo per A: riga = row_select, col = index
                    A_addr   <= row_select * 100 + index;
                    ROW_data <= A_data;
                    ROW_addr <= index;
                    ROW_we   <= '1';

                    if index = to_unsigned(99, 7) then
                        index <= (others => '0');
                        state <= LOAD_COL;
                    else
                        index <= index + 1;
                    end if;

                when LOAD_COL =>
                    -- Calcolo indirizzo per B: riga = index, col = col_select
                    B_addr   <= index * 100 + col_select;
                    COL_data <= B_data;
                    COL_addr <= index;
                    COL_we   <= '1';

                    if index = to_unsigned(99, 7) then
                        state <= DONE;
                    else
                        index <= index + 1;
                    end if;

                when DONE =>
                    -- Credo che duri solo un ciclo di CLK il ended <= '1' da verificare in simulazione
                    ended    <= '1';
                    ROW_we  <= '0';
                    COL_we  <= '0';
                    state   <= IDLE;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end v0;
