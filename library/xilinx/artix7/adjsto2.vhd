library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjsto is
	generic (
		GEAR     : natural);
	port (
		iod_clk  : in  std_logic;
		sys_req  : in  std_logic;
		sys_rdy  : out std_logic;
		imdr_rst : out std_logic;
		imdr_inv : out std_logic;
		ddr_clk  : in  std_logic;
		ddr_smp  : in  std_logic_vector(0 to GEAR-1);
		ddr_sti  : in  std_logic;
		ddr_sto  : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of adjsto is

	constant bl     : natural := 8/2;
	signal   st     : std_logic;
	signal   inc    : std_logic;
	signal   dly    : std_logic_vector(bl-1 downto 1);
	signal   sel    : std_logic_vector(0 to unsigned_num_bits(dly'length-1)-1);
	signal   start  : std_logic;
	signal   finish : std_logic;

begin

	process (ddr_clk)
		variable cnt : unsigned(0 to (unsigned_num_bits(GEAR-1)-1)+3-1);
		variable d   : std_logic_vector(0 to 0);
	begin
		if rising_edge(ddr_clk) then
			if start='0' then
				cnt := (others => '0');
				inc <= '0';
			elsif st='1' then
				for i in 0 to GEAR/2-1 loop
					if ddr_smp(i*GEAR/2)='1' or ddr_smp(i*GEAR/2+1)='1' then
						cnt := cnt + 1;
					end if;
				end loop;
			else
				inc <= not cnt(0);
				cnt := (others => '0');
			end if;
			d := word2byte(reverse(dly & ddr_sti), sel);
			st  <= d(0);
			dly <= dly(dly'left-1 downto 1) & ddr_sti;
		end if;
	end process;
	ddr_sto <= st;

	process (sys_req, ddr_clk)
	begin
		if sys_req='0' then
			start <= '0';
		elsif rising_edge(ddr_clk) then
			if ddr_sti='0' then
				start <= '1';
			end if;
		end if;
	end process;

	process (start, iod_clk)
		variable tmr      : unsigned(0 to 4-1);
		variable rst_imdr : std_logic;
	begin
		if start='0' then
			tmr      := (others => '0');
			sel      <= (others => '0');
			finish   <= '0';
			imdr_rst <= '1';
			rst_imdr := '0'';
		elsif rising_edge(iod_clk) then
			if finish='0' then 
				if start='1' then
					if sel(0)='0' then
						if tmr(0)='1' then
							if inc='1' then
								tmr := (others => '0');
								sel <= std_logic_vector(unsigned(sel)+1);
							else
								finish <= '1';
							end if;
						else
							tmr := tmr + 1;
						end if;
						imdr_rst <= '0';
					elsif rst_imdr='1' then
						if tmr(0)='1' then
							if inc='1' then
								tmr := (others => '0');
								sel <= std_logic_vector(unsigned(sel)+1);
							else
								finish <= '1';
							end if;
						else
							tmr := tmr + 1;
						end if;
						imdr_rst <= '0';
					else
						imdr_rst <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
	sys_rdy <= finish;
	imdr_inv <= sel(0);
end;
