--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: SPI_Slave.vhd
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


entity SPI_Slave is

    port (Clock             : in    SPI_Bit_Type;
          Reset             : in    SPI_Bit_Type;
          SPI_MOSI          : in    SPI_Bit_Type;
          SPI_MISO          :   out SPI_Bit_Type;
          SPI_Clock         : in    SPI_Bit_Type;
          SPI_Enable        : in    SPI_Bit_Type;
          Data_To_Transmit  : in    SPI_Data_Type;
          Data_Received     :   out SPI_Data_Type;
          Count_Port        :   out SPI_Bit_Count_Type;
          State_Port        :   out SPI_State_Type;
          SPI_Status        :   out SPI_Status_Array_Type);

end SPI_Slave;


architecture architecture_SPI_Slave of SPI_Slave is

begin

    process (Clock)

        variable SPI_State      : SPI_State_Type;
        variable SPI_Data       : SPI_Data_Type;
        variable SPI_Data_In    : SPI_Data_Type;
        variable SPI_Status_Reg : SPI_Status_Array_Type;
        variable Count          : SPI_Bit_Count_Type;

    begin
    
        Count_Port    <= Count;
        State_Port    <= SPI_State;

        SPI_Status    <= SPI_Status_Reg;
        Data_Received <= SPI_Data_In;

        if rising_edge (Clock) then

            if Reset = SPI_Reset_Polarity then

                SPI_State              := Wait_State;
                SPI_Data               := (others => SPI_MISO_Default);
                SPI_Data_In            := (others => SPI_MISO_Default);
                SPI_MISO               <= SPI_MISO_Default;
                SPI_Status_Reg(Ready)      := SPI_Status_Polarity;
                SPI_Status_Reg(Data_Ready) := not SPI_Status_Polarity;
                SPI_Status_Reg(Error)      := not SPI_Status_Polarity;

            elsif SPI_Enable = not SPI_Enable_Polarity then

                SPI_State              := Wait_State;
                SPI_Data               := (others => SPI_MISO_Default);
                SPI_MISO               <= SPI_MISO_Default;

                SPI_Status_Reg(Ready)      := SPI_Status_Polarity;
                SPI_Status_Reg(Data_Ready) := not SPI_Status_Polarity;
                SPI_Status_Reg(Error)      := not SPI_Status_Polarity;

            else

                case SPI_State is

                    when Wait_State =>

                        if SPI_Enable = SPI_Enable_Polarity then

                            SPI_Data              := Data_To_Transmit;
                            SPI_Status_Reg(Ready) := not SPI_Status_Polarity;
                            Count                 := SPI_Data_MSB;

                            SPI_State         := Enable_State;

                        else
    
                            SPI_Status_Reg(Ready)      := SPI_Status_Polarity;
                            SPI_Status_Reg(Data_Ready) := not SPI_Status_Polarity;
                            SPI_Status_Reg(Error)      := not SPI_Status_Polarity;
                            SPI_MISO <= SPI_MISO_Default;
                            
                        end if;

                    when Enable_State =>

                        if SPI_Clock = not SPI_Clock_Polarity then

                            SPI_State                  := Setup_State;
                            SPI_Status_Reg(Data_Ready) := not SPI_Status_Polarity;

                        end if;

                    when Setup_State =>

                        if SPI_Clock = SPI_Clock_Polarity then

                            SPI_State := Data_State;

                        else

                            SPI_MISO <= SPI_Data(Count);

                        end if;

                    when Data_State =>

                        if SPI_Clock = not SPI_Clock_Polarity then

                            if Count > 0 then

                                SPI_State := Setup_State;
                                Count     := Count - 1;

                            end if;

                        else

                            if Count = 0 then

                                SPI_State   := Stop_State;
                                
                            end if;

                            SPI_Data(Count) := SPI_MOSI;

                        end if;

                    when Stop_State =>

                        SPI_Data_In                := SPI_Data;
                        SPI_Status_Reg(Data_Ready) := SPI_Status_Polarity;
                        SPI_State                  := Wait_State;

                end case;

            end if;

        end if;

    end process;

end architecture_SPI_Slave;
