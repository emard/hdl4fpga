--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity mii_mux is
    port (
		mux_data : in  std_logic_vector;
        mii_txc  : in  std_logic;
        mii_rxdv : in  std_logic;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_mux is
	constant mux_length : natural := unsigned_num_bits(mux_data'length/mii_txd'length-1);
	subtype mux_range is natural range 1 to mux_length;

	signal mux_sel : std_logic_vector(mux_range);
	signal rdata  : std_logic_vector(mux_data'range);

begin

	process (mii_rxdv, mii_txc)
		variable cntr : unsigned(0 to mux_length);
	begin
		if rising_edge(mii_txc) then
			if mii_txd'length=mux_data'length then
				cntr := (others => '0');
			elsif mii_rxdv='0' then
				cntr := (others => '0');
			elsif cntr(0)='0' then
				cntr := cntr + 1;
			end if;
			mux_sel <= std_logic_vector(cntr(mux_range));
		end if;
		mii_txen <= mii_rxdv and not cntr(0);
	end process;

	rdata <= reverse(mux_data,8);

	mii_txd <= 
		rdata when mii_txd'length=rdata'length else
		word2byte(rdata, mux_sel, mii_txd'length) when rdata'ascending else 
		reverse(word2byte(rdata, not mux_sel, mii_txd'length));

end;
