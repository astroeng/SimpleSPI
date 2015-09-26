--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: SPI_Core_Top.vhd
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

use work.SPI_Types.all;

entity SPI_Core_Top is

    port (Clock           : in    std_logic;
          Reset           : in    std_logic;
          SPI_Enable      :   out std_logic_vector(7 downto 0);
          SPI_Clock       :   out std_logic_vector(7 downto 0);
          SPI_MOSI        :   out std_logic_vector(7 downto 0);
          SPI_MISO        : in    std_logic_vector(7 downto 0);
          SPI_To_Transmit : in    std_logic_vector(7 downto 0);
          SPI_Received    :   out std_logic_vector(7 downto 0);
          SPI_Data_Pulse  : in    std_logic;
          SPI_Selection   : in    integer range 0 to 7;
          SPI_Status      :   out SPI_Status_Array_Type);

end SPI_Core_Top;

architecture architecture_SPI_Core_Top of SPI_Core_Top is

    type SPI_Received_Data_Type is array (0 to 7) of std_logic_vector(7 downto 0);
    type SPI_Status_Data_Type is array (0 to 7) of SPI_Status_Array_Type;

    signal SPI_Received_Data : SPI_Received_Data_Type;
    signal SPI_Status_Data : SPI_Status_Data_Type;

    constant SPI_Clock_Value : SPI_Clock_Divider_Type := 7; -- (40000000 / 2500000 / 2) - 1; 

begin

    SPI_Cores : for Channel in 0 to 7 generate

        SPI_Core : entity work.SPI_Core
            port map (Clock             => Clock,
                      Reset             => Reset,
                      SPI_MOSI          => SPI_MOSI(Channel),
                      SPI_MISO          => SPI_MISO(Channel),
                      SPI_Clock         => SPI_Clock(Channel),
                      SPI_Enable        => SPI_Enable(Channel),
                      Data_To_Transmit  => SPI_To_Transmit,
                      Data_Received     => SPI_Received_Data(Channel),
                      Data_Pulse        => SPI_Data_Pulse,
                      SPI_Clock_Divider => SPI_Clock_Value,
                      SPI_Status        => SPI_Status_Data(Channel));

    end generate;

    SPI_Status   <= SPI_Status_Data(SPI_Selection);
    SPI_Received <= SPI_Received_Data(SPI_Selection);

end architecture_SPI_Core_Top;
