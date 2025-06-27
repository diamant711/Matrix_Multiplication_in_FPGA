library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity PC_INTERFACE is
Port (
    Clock : in std_logic;
    Reset : in std_logic;
    
    DATA_OUT_A : out std_logic_vector(63 downto 0);
    DATA_ADDR_A : in std_logic_vector(13 downto 0);
    DATA_VALID_A : out std_logic;
    DATA_ADDR_VALID_A : in std_logic;
    
    DATA_OUT_B : out std_logic_vector(63 downto 0);
    DATA_ADDR_B : in std_logic_vector(13 downto 0);
    DATA_VALID_B : out std_logic;
    DATA_ADDR_VALID_B : in std_logic;
    
    DATA_IN_C : in std_logic_vector(63 downto 0);
    DATA_ADDR_C : in std_logic_vector(13 downto 0);
    DATA_VALID_C : out std_logic;
    DATA_ADDR_VALID_C : in std_logic;
    
    DATA_OUT_D : out std_logic_vector(63 downto 0);
    
    D_IN : in STD_LOGIC; 
    D_OUT : out std_logic
    );
    
end PC_INTERFACE;

architecture V0 of PC_INTERFACE is

component UART_INTERFACE
Generic 
(
    constant UART_SYNC : unsigned(7 downto 0) := to_unsigned(216,8); -- 115200 baud con 100 MHz clock
    constant UART_OS : unsigned(1 downto 0) := to_unsigned(3,2)
);
Port 
( 
    Clock, D_IN : in STD_LOGIC; 
    Reset, UART_SEND_TX : in STD_LOGIC;
    UART_RX_DONE, UART_TX_READY, D_OUT : out STD_LOGIC;
    UART_TX_DATA : in STD_LOGIC_VECTOR(7 downto 0);
    UART_RX_DATA : out STD_LOGIC_VECTOR(7 downto 0)
);
end component;

component UART_RECEIVER
Port 
(
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
end component;

component MEM_A
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
end component;

component MEM_B
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
end component;

component MEM_C
Port (
    Clock : in std_logic;
    Reset : in std_logic;
    
    DATA_IN : in std_logic_vector(63 downto 0);
    DATA_IN_ADDR : in std_logic_vector(13 downto 0);
    DATA_IN_VALID : out std_logic;
    DATA_IN_ADDR_VALID : in std_logic;
    
    MEM_DATA_IN : in std_logic_vector(63 downto 0);
    MEM_DATA_OUT : out std_logic_vector(63 downto 0);
    MEM_ADDR : in std_logic_vector(13 downto 0);
    MEM_Write_en, MEM_en : in std_logic
     );
end component;

component MEM_D
Port (
    Clock : in std_logic;
    Reset : in std_logic;
    
    DATA_OUT : out std_logic_vector(63 downto 0);
    
    MEM_DATA_IN : in std_logic_vector(63 downto 0);
    MEM_DATA_OUT : out std_logic_vector(63 downto 0);
    MEM_Write_en, MEM_en : in std_logic);
end component;

signal UART_RX_DATA, UART_TX_DATA : std_logic_vector(7 downto 0);
signal UART_RX_DONE : std_logic;
signal MEM_DATA_IN_A, MEM_DATA_IN_B, MEM_DATA_IN_C, MEM_DATA_IN_D, MEM_DATA_OUT : std_logic_vector(63 downto 0);
signal MEM_ADDR : std_logic_vector(13 downto 0);
signal MEM_Write_en : std_logic;
signal MEM_A_EN, MEM_B_EN, MEM_C_EN, MEM_D_EN : std_logic;
signal UART_TX_READY, UART_SEND_TX : std_logic;

begin
-- PC TO UART
D1 : UART_INTERFACE
port map 
(
    Clock => Clock,
    Reset => Reset,
    
    D_IN => D_IN,
    D_OUT => D_OUT,
    UART_SEND_TX => UART_SEND_TX, 
    UART_TX_READY => UART_TX_READY,
    UART_RX_DONE => UART_RX_DONE, 
    UART_TX_DATA => UART_TX_DATA, 
    UART_RX_DATA => UART_RX_DATA
);


-- UART TO CONTROLLER
D2 : UART_RECEIVER
Port map 
(
    Clock => Clock,
    Reset => Reset,
    
    UART_RX_DATA  => UART_RX_DATA,
    UART_RX_DONE => UART_RX_DONE,
    UART_TX_DATA => UART_TX_DATA,
    UART_TX_READY => UART_TX_READY,
    UART_SEND_TX => UART_SEND_TX,    
    
    MEM_ADDRESS_OUT => MEM_ADDR,
    MEM_DATA_OUT => MEM_DATA_OUT,
    MEM_DATA_IN_A => MEM_DATA_IN_A,
    MEM_DATA_IN_B => MEM_DATA_IN_B,
    MEM_DATA_IN_C => MEM_DATA_IN_C,
    MEM_DATA_IN_D => MEM_DATA_IN_D,
    MEM_A_EN => MEM_A_EN,
    MEM_B_EN => MEM_B_EN,
    MEM_C_EN => MEM_C_EN,
    MEM_D_EN => MEM_D_EN,
    MEM_Write_en  => MEM_Write_en
    );

-- UART_CONTROLLER TO MEM_A
D3 : MEM_A
Port map(
    Clock => Clock,
    Reset => Reset,
    
    DATA_OUT => DATA_OUT_A,
    DATA_OUT_ADDR => DATA_ADDR_A,
    DATA_OUT_VALID => DATA_VALID_A,
    DATA_OUT_ADDR_VALID => DATA_ADDR_VALID_A,
    
    MEM_DATA_IN => MEM_DATA_OUT,
    MEM_DATA_OUT => MEM_DATA_IN_A,
    MEM_ADDR => MEM_ADDR,
    MEM_Write_en => MEM_Write_en,
    MEM_en => MEM_A_EN
);

-- UART_CONTROLLER TO MEM_B
D4 : MEM_B
Port map(
    Clock => Clock,
    Reset => Reset,
    
    DATA_OUT => DATA_OUT_B,
    DATA_OUT_ADDR => DATA_ADDR_B,
    DATA_OUT_VALID => DATA_VALID_B,
    DATA_OUT_ADDR_VALID => DATA_ADDR_VALID_B,
    
    MEM_DATA_IN => MEM_DATA_OUT,
    MEM_DATA_OUT => MEM_DATA_IN_B,
    MEM_ADDR => MEM_ADDR,
    MEM_Write_en => MEM_Write_en,
    MEM_en => MEM_B_EN
);

-- UART CONTROLLER TO MEM_D
D5 : MEM_D
Port map(
    Clock => Clock,
    Reset => Reset,
    
    DATA_OUT => DATA_OUT_D,
    
    MEM_DATA_IN => MEM_DATA_OUT,
    MEM_DATA_OUT => MEM_DATA_IN_D,
    MEM_Write_en => MEM_Write_en,
    MEM_en => MEM_D_EN
);

-- UART CONTROLLER TO MEM_C
D6 : MEM_C
Port map(
    Clock => Clock,
    Reset => Reset,
    
    DATA_IN => DATA_IN_C,
    DATA_IN_ADDR => DATA_ADDR_C,
    DATA_IN_VALID => DATA_VALID_C,
    DATA_IN_ADDR_VALID => DATA_ADDR_VALID_C,
    
    MEM_DATA_IN => MEM_DATA_OUT,
    MEM_DATA_OUT => MEM_DATA_IN_C,
    MEM_ADDR => MEM_ADDR,
    MEM_Write_en => MEM_Write_en,
    MEM_en => MEM_C_EN
);
end V0;