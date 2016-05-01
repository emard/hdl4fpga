library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjsto is
	port (
		sti : in std_logic;
		sto : out std_logic;
		smp : in  std_logic;
		sys_clk0 : in std_logic;
		iod_clk  : in std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		iod_rst : out std_logic;
		iod_ce  : out std_logic;
		iod_inc : out std_logic);
end;

library hdl4fpga;

architecture def of adjsto is
	signal cnt : unsigned()
	signal st : std_logic;
	signal inc : std_logic;
begin

	process (sys_clk0)
	begin
		if rising_edge(sys_clk0) then
			if sti='1' then
				if smp='1'  then
					cnt <= cnt + 1;
				end if;
			else
				inc <= cnt(0);
				cnt <= ('0', others => '1');
			end if;
		end if;
	end process;

	process (iod_clk)
		variable q : std_logic;
	begin
		if rising_edge(iod_clk) then
			smp1 <= smp;
		end if;
	end process;

	process (iod_clk)
		variable ce  : unsigned(0 to 3-1);
	begin
		if rising_edge(iod_clk) then
			if req='0' then
				sync <= '0';
				iod_inc <= '0';
				iod_ce  <= '0';
				rdy <= '0';
			elsif sync='0' then
				if smp0=('0' xor pp) then
					if smp1=('1' xor pp) then
						sync  <= '1';
					end if;
				else 
				end if;
				iod_ce  <= ce(0);
			else
				rdy <= not ce(ce'right);
			end if;
		end if;
	end process;
	iod_rst <= not req;
end;
