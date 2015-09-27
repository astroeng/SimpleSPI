--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: SPI_Core.vhd
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

entity SPI_Core is

    port (Clock             : in    SPI_Bit_Type;
          Reset             : in    SPI_Bit_Type;
          SPI_MOSI          :   out SPI_Bit_Type;
          SPI_MISO          : in    SPI_Bit_Type;
          SPI_Clock         :   out SPI_Bit_Type;
          SPI_Enable        :   out SPI_Bit_Type;
          Data_To_Transmit  : in    SPI_Data_Type;
          Data_Received     :   out SPI_Data_Type;
          Data_Pulse        : in    SPI_Bit_Type;
          SPI_Clock_Divider : in    SPI_Clock_Divider_Type;
          Count_Port        :   out SPI_Bit_Count_Type;
          State_Port        :   out SPI_State_Type;
          SPI_Status        :   out SPI_Status_Array_Type);

end SPI_Core;

architecture architecture_SPI_Core of SPI_Core is

    --type SPI_State_Type is (Wait_State, Enable_State, Setup_State, Data_State, Stop_State);

begin

    process (Clock)

        variable Count           : SPI_Bit_Count_Type; -- (2 downto 0);
        variable Data_Reg        : SPI_Data_Type;
        variable Data_In_Reg     : SPI_Data_Type;
        variable SPI_Status_Reg  : SPI_Status_Array_Type;
        variable SPI_Clock_Timer : SPI_Clock_Divider_Type;
        variable SPI_State_Reg   : SPI_State_Type;

    begin

        Count_Port    <= Count;
        State_Port    <= SPI_State_Reg;

        SPI_Status    <= SPI_Status_Reg;
        Data_Received <= Data_In_Reg;

        if rising_edge(Clock) then

            if Reset = SPI_Reset_Polarity then

                Count                      := SPI_Data_MSB;
                SPI_Status_Reg(Data_Ready) := not SPI_Status_Polarity;
                SPI_Status_Reg(Ready)      := SPI_Status_Polarity;
                SPI_Status_Reg(Error)      := not SPI_Status_Polarity;
                SPI_Clock_Timer            := SPI_Clock_Divider;

            end if;

            case SPI_State_Reg is

                when Wait_State =>

                    if Data_Pulse = SPI_Enable_Polarity then

                        Count                      := SPI_Data_MSB;
                        Data_Reg                   := Data_To_Transmit;
                        SPI_Status_Reg(Ready)      := not SPI_Status_Polarity;
                        SPI_Status_Reg(Data_Ready) := not SPI_Status_Polarity;
                        SPI_State_Reg              := Enable_State;

                    else
                
                        SPI_Status_Reg(Ready) := SPI_Status_Polarity;
                        SPI_Enable            <= not SPI_Enable_Polarity;
                        SPI_Clock             <= SPI_Clock_Polarity;
                        SPI_MOSI              <= SPI_MOSI_Polarity;

                    end if;

                when Enable_State => 

                    SPI_Enable <= SPI_Enable_Polarity;

                    if SPI_Clock_Timer > 0 then
                        SPI_Clock_Timer := SPI_Clock_Timer - 1;
                    else
                        SPI_Clock_Timer := SPI_Clock_Divider;
                        SPI_State_Reg := Setup_State;
                    end if;

                when Setup_State => 
                    
                    SPI_Clock       <= not SPI_Clock_Polarity;
                    SPI_MOSI        <= Data_Reg(Count);

                    if SPI_Clock_Timer > 0 then
                        SPI_Clock_Timer := SPI_Clock_Timer - 1;
                    else
                        SPI_Clock_Timer := SPI_Clock_Divider;
                        SPI_State_Reg   := Data_State;
                    end if;

                when Data_State =>

                    SPI_Clock       <= SPI_Clock_Polarity;
                    Data_Reg(Count) := SPI_MISO;

                    if SPI_Clock_Timer > 0 then
                        SPI_Clock_Timer := SPI_Clock_Timer - 1;
                    else
                        SPI_Clock_Timer := SPI_Clock_Divider;

                        if Count = 0 then
                            SPI_State_Reg := Stop_State;
                        else
                            Count := Count - 1;
                            SPI_State_Reg := Setup_State;
                        end if;
                    end if;

                when Stop_State =>

                    Data_In_Reg                := Data_Reg;
                    SPI_Status_Reg(Data_Ready) := SPI_Status_Polarity;
                    
                    if SPI_Clock_Timer > 0 then
                        SPI_Clock_Timer := SPI_Clock_Timer - 1;
                    else
                        SPI_Clock_Timer := SPI_Clock_Divider;
                        SPI_State_Reg   := Wait_State;
                    end if;

            end case;

        end if;

    end process;

end architecture_SPI_Core;
