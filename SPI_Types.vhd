--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: SPI_Types.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::ProASIC3> <Die::A3P250> <Package::256 FBGA>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package SPI_Types is

    constant SPI_Data_Size : integer := 8;
    constant SPI_Data_MSB  : integer := SPI_Data_Size - 1;

    type SPI_Status_Type is (Ready, Data_Ready, Error);
    type SPI_Status_Array_Type is array (SPI_Status_Type) of std_logic;

    subtype SPI_Bit_Type is std_logic;
    subtype SPI_Bit_Count_Type is integer range 0 to SPI_Data_MSB;
    subtype SPI_Clock_Divider_Type is unsigned (2 downto 0);
    subtype SPI_Data_Type is std_logic_vector (SPI_Data_MSB downto 0);

    constant SPI_Status_Polarity : std_logic := '1';

    constant SPI_Clock_Polarity  : std_logic := '1';
    constant SPI_MOSI_Polarity   : std_logic := '1';
    constant SPI_Enable_Polarity : std_logic := '0';
    constant SPI_Reset_Polarity  : std_logic := '0';

end SPI_Types;