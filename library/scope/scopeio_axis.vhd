library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_axis is
	port (
		clk     : in  std_logic;

		hz_req  : in  std_logic;
		hz_rdy  : out std_logic;
		hz_pnt  : in  std_logic_vector;
		hz_tick : in std_logic_vector;
		hz_val  : out  std_logic_vector;

		vt_req  : in  std_logic;
		vt_rdy  : out std_logic;
		vt_pnt  : in  std_logic_vector;
		vt_tick : in  std_logic_vector;
		vt_val  : out std_logic_vector);

end;

architecture def of scopeio_axis is
	constant vt_len : unsigned(0 to 3-1) := to_unsigned(6, 3);
	constant hz_len : unsigned(0 to 3-1) := to_unsigned(4, 3);

	signal tick  : std_logic_vector(6-1 downto 0);
	signal value : std_logic_vector(8*4-1 downto 0);
	signal vt_dv : std_logic;
	signal hz_dv : std_logic;
	signal hz_step : std_logic_vector(0 to 5);
	signal hz_from : std_logic_vector(0 to 5);
	signal vt_step : std_logic_vector(0 to 5);
	signal vt_from : std_logic_vector(0 to 5);
begin


	scopeio_axisticks_e : entity work.scopeio_axisticks
	port map (
		clk    => clk,

		hz_len => std_logic_vector(hz_len),
		hz_step => hz_step,
		hz_from => hz_from,
		hz_req => hz_req,
		hz_rdy => hz_rdy,
		hz_pnt => hz_pnt,
		hz_dv  => hz_dv,

		vt_len => std_logic_vector(vt_len),
		vt_step => vt_step,
		vt_from => vt_from,
		vt_req => vt_req,
		vt_rdy => vt_rdy,
		vt_pnt => vt_pnt,
		vt_dv  => vt_dv,

		tick   => tick,
		value  => value);

	hz_mem_e : entity hdl4fpga.dpram
	port map (
		wr_ena  => hz_dv,
		wr_addr => tick(6-1 downto 0),
		wr_data => value,

		rd_addr => vt_tick,
		rd_data => hz_val);

	vt_mem_e : entity hdl4fpga.dpram
	port map (
		wr_ena  => vt_dv,
		wr_addr => tick(4-1 downto 0),
		wr_data => value,

		rd_addr => vt_tick,
		rd_data => vt_val);

	video_b : block
	rom_e : entity hdl4fpga.cga_rom
	generic map (
		font_bitrom => psf1cp850x8x16,
		font_height => 2**3,
		font_width  => 2**3)
	port map (
		clk       => video_clk,
		char_col  => font_col,
		char_row  => font_row,
		char_code => cga_rdata,
		char_dot  => char_dot);

end;
