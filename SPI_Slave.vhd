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
          SPI_Status        :   out SPI_Status_Array_Type);

end SPI_Slave;


architecture architecture_SPI_Slave of SPI_Slave is

    signal SPI_Clock_Net  : SPI_Bit_Type;
    signal SPI_MOSI_Net   : SPI_Bit_Type;
    signal SPI_Enable_Net : SPI_Bit_Type;

begin

    -- Alias the SPI clock so that it is stable during a system clock period.
    -- Alias the SPI MOSI pin so that it is stable during a system clock period.
    -- Alias the SPI Enable pin so that it is stable during a system clock period.

    Input_Alias : process (Clock)

        variable SPI_Clock_Alias  : SPI_Bit_Type;
        variable SPI_MOSI_Alias   : SPI_Bit_Type;
        variable SPI_Enable_Alias : SPI_Bit_Type;

    begin

        SPI_Clock_Net  <= SPI_Clock_Alias;
        SPI_MOSI_Net   <= SPI_MOSI_Alias;
        SPI_Enable_Net <= SPI_Enable_Alias;

        if rising_edge (Clock) then

            SPI_Clock_Alias  := SPI_Clock;
            SPI_MOSI_Alias   := SPI_MOSI;
            SPI_Enable_Alias := SPI_Enable;          

        end if;

    end process;



    SPI_Slave_State_Machine : process (Clock)

        variable SPI_State      : SPI_State_Type;
        variable SPI_Data       : SPI_Data_Type;
        variable SPI_Data_In    : SPI_Data_Type;
        variable SPI_Status_Reg : SPI_Status_Array_Type;
        variable Count          : SPI_Bit_Count_Type;

    begin

        SPI_Status    <= SPI_Status_Reg;
        Data_Received <= SPI_Data_In;

        if rising_edge (Clock) then

            if Reset = SPI_Reset_Polarity then

                Count := 0;

                SPI_State              := Wait_State;
                SPI_Data               := (others => '0');
                SPI_Data_In            := (others => '0');
                SPI_MISO               <= SPI_MISO_Default;

                SPI_Status_Reg(Ready)      := SPI_Status_Polarity;
                SPI_Status_Reg(Data_Ready) := not SPI_Status_Polarity;
                SPI_Status_Reg(Error)      := not SPI_Status_Polarity;

            elsif SPI_Enable_Net = not SPI_Enable_Polarity then

                -- If the SPI Slave module is not enabled reset the module to a good
                -- starting condition for when the line does drop low.

                SPI_State              := Wait_State;
                SPI_Data               := (others => '0');
                SPI_MISO               <= SPI_MISO_Default;

                SPI_Status_Reg(Ready)      := SPI_Status_Polarity;
                SPI_Status_Reg(Error)      := not SPI_Status_Polarity;

            else

                case SPI_State is

                    when Wait_State =>

                        -- Leave the wait state if the enable polarity is active Techically this
                        -- check is not needed since the above elsif is guaranteed to trap the 
                        -- state of the SPI Slave module if the SPI_Enable signal is the inactive.

                        --if SPI_Enable_Net = SPI_Enable_Polarity then

                            
                            SPI_Status_Reg(Ready) := not SPI_Status_Polarity;

                            SPI_State             := Enable_State;
                            
                        --end if;

                    when Enable_State =>

                        -- Leave the enable state if the clock is low.
                        Count                 := SPI_Data_MSB;
                        SPI_Data              := Data_To_Transmit;

                        if SPI_Clock_Net = not SPI_Clock_Polarity then

                            SPI_State                  := Setup_State;
                            SPI_Status_Reg(Data_Ready) := not SPI_Status_Polarity;

                        end if;

                    when Setup_State =>

                        -- Leave the setup state if the clock is high. This is also where
                        -- the input data is sampled. Output data is set when the clock is
                        -- low.

                        if SPI_Clock_Net = SPI_Clock_Polarity then

                            SPI_State      := Data_State;
                            SPI_Data_In(0) := SPI_MOSI_Net;

                        else

                            SPI_MISO <= SPI_Data(7);

                        end if;

                    when Data_State =>

                        -- Leave the data state for the stop state if all of the data has
                        -- been received. Otherwise wait for the clock to fall, update the 
                        -- data registers as part of moving back to the setup state.

                        if Count = 0 then

                            SPI_State   := Stop_State;

                        elsif SPI_Clock_Net = not SPI_Clock_Polarity then

                            SPI_State := Setup_State;
                            Count     := Count - 1;
                            SPI_Data(7 downto 1)    := SPI_Data(6 downto 0);
                            SPI_Data_In(7 downto 1) := SPI_Data_In(6 downto 0);

                        end if;

                    when Stop_State =>

                        -- Set the data ready flag and go back to the enable state when 
                        -- the SPI clock is high.

                        SPI_Status_Reg(Data_Ready) := SPI_Status_Polarity;

                        -- This check is not needed either since the data state is during
                        -- the high clock cycle.

                        --if SPI_Clock_Net = SPI_Clock_Polarity then

                            SPI_State := Enable_State;

                        --end if;

                end case;

            end if;

        end if;

    end process;

end architecture_SPI_Slave;
