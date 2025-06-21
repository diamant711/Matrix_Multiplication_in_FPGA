----------------------------------------------------------------------------------
-- Company: Unimi
-- Engineer: Riccardo Osvaldo Nana, Stefano Pilosio
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
        ended        : out std_logic;
        full         : in std_logic; 

        -- Interfaccia lettura matrice A (100x100)
        A_data       : in  std_logic_vector(63 downto 0);
        A_addr       : out unsigned(13 downto 0); -- 14 bit per 100*100 = 10,000 celle
        GETA         : out std_logic;
        READYA       : in std_logic;

        -- Interfaccia lettura matrice B (100x100)
        B_data       : in  std_logic_vector(63 downto 0);
        B_addr       : out unsigned(13 downto 0);
        GETB         : out std_logic;
        READYB       : in std_logic;

        -- Interfaccia scrittura ROW (100 word)
        ROW_we       : out std_logic;
        ROW_addr     : out unsigned(6 downto 0);
        ROW_data     : out std_logic_vector(63 downto 0);
        ROW_done     : in std_logic;

        -- Interfaccia scrittura COL (100 word)
        COL_we       : out std_logic;
        COL_addr     : out unsigned(6 downto 0);
        COL_data     : out std_logic_vector(63 downto 0);
        COL_done     : in std_logic
    );
end CACHE_LOADER;

architecture v0 of CACHE_LOADER is

    constant row_size : unsigned := to_unsigned(100, 7);
    constant col_size : unsigned := row_size;
    
    type state_type is (IDLE, GET, LOAD, DONE);
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
            GETA <= '0';
            GETB <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = '1' then
                        index     <= (others => '0');
                        ended      <= '0';
                        A_addr    <= (others => '0');
                        B_addr    <= (others => '0');
                        ROW_we    <= '0';
                        COL_we    <= '0';
                        ROW_data  <= (others => '0');
                        COL_data  <= (others => '0');
                        GETA <= '1'; -- Questo va posto a 1 quando si inizia a leggere
                        GETB <= '1'; -- Questo va posto a 1 quando si inizia a leggere
                        state <= GET;
                    else
                        state <= IDLE;
                    end if;
                when GET =>
                    if READYA = '1' and READYB = '1' then                       
                        -- Carico nella riga il valore attuale della cella A
                        ROW_data <= A_data;
                        -- Carico nella colonna il valore attuale di B
                        COL_data <= B_data;

                        -- Al ciclo di clock successivo anche l'indirizzo di row e col vengono portati al valore attuale di index
                        ROW_addr <= index;
                        COL_addr <= index; 

                        -- Non voglio pi`u leggere i dati al ciclo di clock successivo che sar`a il load.
                        GETA <= '0';
                        GETB <= '0';
                        -- Per`o la  cella di memoria per la colonna e la riga possono essere abilitate alla lettura.
                        ROW_we <= '1';
                        COL_we <= '1';
                    
                        -- Seleziono l'indirizzo di memoria per lo step successivo di A
                        A_addr <= row_select * row_size + index; 
                        -- Seleziono l'indirizzo di memoria per lo step successivo di B
                        B_addr <= index * col_size + col_select;
                                        
                        -- Passo allo stato in cui carico nella cache interna del moltiplicatore.
                        state <= LOAD;
                    else
                        state <= GET;
                    end if;
                when LOAD =>
                    if full = '0' then
                        if COL_done = '1' and ROW_done = '1' then
                            -- Accetto nuovi numeri da leggere
                            GETA <= '1';
                            GETB <= '1';
                            -- Chiudo la possibilit`a di leggere alle celle di memoria
                            ROW_we <= '0';                            
                            COL_we <= '0';                            
                            
                            -- incremento l'indice di 1 per spostarmi all'elemento successivo da copiare
                            index <= index + 1;
                            -- Passo allo stato per ottenere nuove informazioni
                            state <= GET;
                        else
                            state <= LOAD;
                        end if;                      
                    else
                        state <= DONE;
                    end if;
                when DONE =>
                    ended <= '1';
                    state <= IDLE;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end v0;
