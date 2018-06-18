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

entity miitx_dll is
	port (
		mii_txc   : in  std_logic;
		dmac_ena  : out  std_logic;
		dmac_rxd  : in  std_logic_vector;
		smac_ena  : out std_logic;
		smac_rxd  : in  std_logic_vector;
		mii_rxdv  : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_txdv  : out std_logic;
		mii_txd   : out std_logic_vector);
end;

architecture mix of miitx_dll is
	constant crc32_size   : natural := 32;

	signal miipre_txd  : std_logic_vector(mii_txd'range);
	signal miipre_txdv : std_logic;

	signal minpkt_txdv : std_logic;
	signal minpkt_txd  : std_logic;

	signal miibuf_txdv : std_logic;
	signal miibuf_txd  : std_logic_vector(mii_txd'range);

	signal crc32_txd   : std_logic_vector(mii_txd'range);
	signal crc32_txdv  : std_logic;
	signal mii_ptr     : unsigned(0 to 6*8/mii_txd'length);
begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_ptr(0)/='0' then
				if mii_rxdv='0' then
					mii_ptr <= to_unsigned(crc32_size/mii_txd'length, mii_ptr'length);
				end if;
			else
				mii_ptr <= mii_ptr + 1;
			end if;
		end if;
	end process;

	miitx_pre_e  : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(x"5555_5555_5555_55d5", 8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_rxdv,
		mii_txdv => miipre_txdv,
		mii_txd  => miipre_txd);

	minpkt_txd <= mii_rxd when mii_rxdv='1' else '0';
	miishr_txd_e : entity hdl4fpga.align
	generic map (
		n  => mii_txd'length,
		d  => (1 to mii_txd'length => mii_pre'length/mii_txd'length))
	port map (
		clk => mii_txc,
		di  => mii_rxd,
		do  => miibuf_rxd);

	minpkt_txdv <= mii_rxdv or not mii_ptr(0);
	miishr_txdv_e : entity hdl4fpga.align
	generic map (
		n  => 1,
		d  => (1 to 1 => mii_pre'length/mii_txd'length))
	port map (
		clk   => mii_txc,
		di(0) => mii_rxdv,
		do(0) => miibuf_rxdv);

	crc32_e : entity hdl4fpga.mii_crc32
	port map (
		mii_txc  => mii_txc,
		mii_rxd  => miibuf_txd,
		mii_rxdv => miibuf_txdv,
		mii_txdv => crc32_txdv,
		mii_txd  => crc32_txd);

	mii_txd  <= miipre_txdv or crc32_txdv or miipre_txdv;
	mii_txdv <= wirebus (
		miipre_txd  & miibuf_txd & crc32_txd,
		miipre_txdv & miibuf_txdv & crc32_txdv);

end;
