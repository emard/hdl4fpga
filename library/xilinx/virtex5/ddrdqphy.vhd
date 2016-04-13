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

library unisim;
use unisim.vcomponents.all;

entity ddrdqphy is
	generic (
		registered_dout : boolean;
		loopback : boolean;
		gear : natural;
		byte_size : natural;
		iddron : boolean := false);
	port (
		sys_rst : in std_logic;
		sys_clk0 : in  std_logic;
		sys_clk90 : in  std_logic;
		sys_wlreq : in std_logic := '0';
		sys_wlrdy : out std_logic;
		sys_dmt  : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_dmi  : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_sti  : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_sto  : out std_logic_vector(0 to gear-1);
		sys_dqo  : in  std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(gear-1 downto 0);
		sys_dqi  : out std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqso : in  std_logic_vector(0 to gear-1);
		sys_dqst : in  std_logic_vector(0 to gear-1);
		sys_dqsibuf : in std_logic;
		sys_iod_rst : out std_logic;
		sys_iod_clk : in  std_logic;
		sys_dqiod_ce   : out std_logic_vector(byte_size-1 downto 0);
		sys_dqiod_inc  : out std_logic_vector(byte_size-1 downto 0);
		sys_dqsiod_ce  : out std_logic;
		sys_dqsiod_inc : out std_logic;

		ddr_dmt  : out std_logic;
		ddr_dmo  : out std_logic;
		ddr_sto  : out std_logic;
		ddr_dqsi : in  std_logic;
		ddr_dqi  : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt  : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo  : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqst : out std_logic;
		ddr_dqso : out std_logic);

end;

library hdl4fpga;

architecture virtex of ddrdqphy is

	signal dqi  : std_logic_vector(sys_dqi'range);
	signal dqt  : std_logic_vector(sys_dqt'range);
	signal dqst : std_logic_vector(sys_dqst'range);
	signal dqso : std_logic_vector(sys_dqso'range);
	signal adjdqs_req : std_logic;
	signal adjdqs_rdy : std_logic;
	signal adjdqi_req : std_logic;
	signal adjdqi_rdy : std_logic_vector(ddr_dqi'range);


	signal dqsiod_inc : std_logic;
	signal dqsiod_ce  : std_logic;
begin

	sys_iod_rst    <= adjdqs_req;
	sys_dqsiod_ce  <= dqsiod_ce;
	sys_dqsiod_inc <= dqsiod_inc;

	iddr_g : for i in 0 to byte_size-1 generate
		signal dqiod_inc : std_logic;
		signal dqiod_ce  : std_logic;
	begin
		iddron_g : if iddron generate
			signal q0 : std_logic;
			signal q1 : std_logic;
		begin
			iddr_i : iddr
			generic map (
				DDR_CLK_EDGE => "SAME_EDGE")
			port map (
				c  => ddr_dqsi,
				ce => '1',
				d  => ddr_dqi(i),
				q1 => q0,
				q2 => q1);

			sys_dqi(0*byte_size+i) <= q0;
			sys_dqi(1*byte_size+i) <= q1;
		
			adjdqi_req <= adjdqs_rdy;
			adjdqi_e : entity hdl4fpga.adjdqi
			port map (
				sys_clk0 => sys_clk0,
				d0 => q0,
				d1 => q1,
				req => adjdqi_req,
				rdy => adjdqi_rdy(i),
				iod_clk => sys_iod_clk,
				iod_ce  => dqiod_ce,
				iod_inc => dqiod_inc);
		end generate;

		sys_dqiod_ce(i)  <= dqiod_ce  or dqsiod_ce;
		sys_dqiod_inc(i) <= dqiod_inc when adjdqi_req='1' else dqsiod_inc;
		iddroff_g : if not iddron generate
			phase_g : for j in  gear-1 downto 0 generate
				sys_dqi(j*byte_size+i) <= ddr_dqi(i);
			end generate;
		end generate;
	end generate;

	oddr_g : for i in 0 to byte_size-1 generate
		signal dqo  : std_logic_vector(0 to gear-1);
		signal rdqo : std_logic_vector(0 to gear-1);
		signal clks : std_logic_vector(0 to gear-1);
	begin
		clks <= (0 => sys_clk90, 1 => not sys_clk90);

		registered_g : for j in clks'range generate
			process (clks(j))
			begin
				if rising_edge(clks(j)) then
					rdqo(j) <= sys_dqo(j*byte_size+i);
				end if;
			end process;
			dqo(j) <= rdqo(j) when registered_dout else sys_dqo(j*byte_size+i);
		end generate;

		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clk90,
			d => sys_dqt(0),
			q => ddr_dqt(i));

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk90,
			dr  => dqo(0),
			df  => dqo(1),
			q   => ddr_dqo(i));
	end generate;

	dmo_g : block
		signal dmt  : std_logic_vector(sys_dmt'range);
		signal dmi  : std_logic_vector(sys_dmi'range);
		signal rdmi : std_logic_vector(sys_dmi'range);
		signal clks : std_logic_vector(0 to gear-1);
	begin

		clks <= (0 => sys_clk90, 1 => not sys_clk90);
		registered_g : for i in clks'range generate
			signal d, t, s : std_logic;
		begin
			dmt(i) <= sys_dmt(i) when not loopback else '0';

			rdmi(i) <= s when t='1' and not loopback else d;
			process (clks(i))
			begin
				if rising_edge(clks(i)) then
					t <= sys_dmt(i);
					d <= sys_dmi(i);
					s <= sys_sti(i);
				end if;
			end process;

			dmi(i) <=
				rdmi(i)    when registered_dout else 
				sys_sti(i) when sys_dmt(i)='1' else
				sys_dmi(i);

		end generate;

		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clk90,
			d => dmt(0),
			q => ddr_dmt);

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk90,
			dr  => dmi(0),
			df  => dmi(1),
			q   => ddr_dmo);
	end block;

	sto_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clk90,
		dr  => sys_sti(0),
		df  => sys_sti(1),
		q   => ddr_sto);

	dqso_b : block 
	begin

		adjdqs_req <= sys_wlreq and sys_sti(0);
		adjdqs_e : entity hdl4fpga.adjdqs
		port map (
			sys_clk0 => sys_clk0,
			din => sys_dqsibuf,
			req => adjdqs_req,
			rdy => adjdqs_rdy,
			iod_clk => sys_iod_clk,
			iod_ce  => dqsiod_ce,
			iod_inc => dqsiod_inc);

		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clk0,
			d => sys_dqst(1),
			q => ddr_dqst);

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk0,
			dr  => '0',
			df  => sys_dqso(0),
			q   => ddr_dqso);

	end block;
end;
