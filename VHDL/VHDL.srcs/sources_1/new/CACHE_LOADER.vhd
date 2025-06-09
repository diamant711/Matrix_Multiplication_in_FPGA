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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CACHE_LOADER is
    Port ( RESET : in STD_LOGIC;
           CLK : in STD_LOGIC;
           DONE : out STD_LOGIC;
           ADDRA : out STD_LOGIC_VECTOR (13 downto 0);
           ADDRB : out STD_LOGIC_VECTOR (13 downto 0);
           ADDRCACHE : out STD_LOGIC_VECTOR (6 downto 0);
           SELCOL : in STD_LOGIC_VECTOR (6 downto 0);
           SELROW : in STD_LOGIC_VECTOR (6 downto 0);
           DINA : in STD_LOGIC_VECTOR (63 downto 0);
           DINB : in STD_LOGIC_VECTOR (63 downto 0);
           DOUTR : out STD_LOGIC_VECTOR (63 downto 0);
           DOUTC : out STD_LOGIC_VECTOR (63 downto 0));
end CACHE_LOADER;

architecture v0 of CACHE_LOADER is

begin


end v0;
