----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2025 12:10:53 PM
-- Design Name: 
-- Module Name: top - Version0
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
---- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
---- library UNISIM;
---- use UNISIM.VComponents.all;

entity top is
    Port ( A : in STD_LOGIC;
           B : out STD_LOGIC;
           C : in STD_LOGIC_VECTOR (4 downto 0));
end top;

architecture Version0 of top is

component c_mio_sommatore
  PORT (
    A : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    CLK : IN STD_LOGIC;
    CE : IN STD_LOGIC;
    S : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
  );
end component;
signal CLK_top, CE_top: std_logic;
signal A_top, B_top: std_logic_vector(14 DOWNTO 0);

begin
s1: c_mio_sommatore
PORT MAP (
      A => A,
      B => B,
      CLK => CLK,
      ADD => '1',
      C_IN => '0',
      CE => CE,
      BYPASS => '0',
      SCLR => '0',
      SSET => '0',
      SINIT => '0',
      S => S
);

end Version0;
