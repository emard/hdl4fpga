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
use hdl4fpga.ethpkg.all;

package ipoepkg is

	constant octect_size  : natural := 8;

	constant llc_ip4 : std_logic_vector := x"0800";
	constant llc_arp : std_logic_vector := x"0806";

	constant arp_htype : natural := 0;
	constant arp_ptype : natural := 1;
	constant arp_hlen  : natural := 2;
	constant arp_plen  : natural := 3;
	constant arp_oper  : natural := 4;
	constant arp_sha   : natural := 5;
	constant arp_spa   : natural := 6;
	constant arp_tha   : natural := 7;
	constant arp_tpa   : natural := 8;

	constant arp_frame : natural_vector := (
		arp_htype => 2*octect_size,
		arp_ptype => 2*octect_size,
		arp_hlen  => 1*octect_size,
		arp_plen  => 1*octect_size,
		arp_oper  => 2*octect_size,
		arp_sha   => 6*octect_size,
		arp_spa   => 4*octect_size,
		arp_tha   => 6*octect_size,
		arp_tpa   => 4*octect_size);

	constant arprply_pfx : std_logic_vector :=
		x"0001" & -- htype 
		x"0800" & -- ptype 
		x"06"   & -- hlen  
		x"04"   & -- plen  
		x"0002";  -- oper  
	   
	constant ip4_llc     : natural :=  0;
	constant ip4_verihl  : natural :=  1;
	constant ip4_tos     : natural :=  2;
	constant ip4_len     : natural :=  3;
	constant ip4_ident   : natural :=  4;
	constant ip4_flgsfrg : natural :=  5;
	constant ip4_ttl     : natural :=  6;
	constant ip4_proto   : natural :=  7;
	constant ip4_chksum  : natural :=  8;
	constant ip4_sa      : natural :=  9;
	constant ip4_da      : natural :=  10;

	constant ip4hdr_frame : natural_vector := (
		ip4_llc     => llc_ip4'length,
		ip4_verihl  => 1*octect_size,
		ip4_tos     => 1*octect_size,
		ip4_len     => 2*octect_size,
		ip4_ident   => 2*octect_size,
		ip4_flgsfrg => 2*octect_size,
		ip4_ttl     => 1*octect_size,
		ip4_proto   => 1*octect_size,
		ip4_chksum  => 2*octect_size,
		ip4_sa      => 4*octect_size,
		ip4_da      => 4*octect_size);
		
	constant ip4_shdr : std_logic_vector := (
		x"4500" &    -- Version, TOS
		x"0000" &    -- Length
		x"0000" &    -- Identification, Fragmentation
		x"0511"        -- TTL, protocol
		); 

	constant udp4_sp   : natural :=  0;
	constant udp4_dp   : natural :=  1;
	constant udp4_len  : natural :=  2;
	constant udp4_cksm : natural :=  3;

	constant udp4hdr_frame : natural_vector := (
		udp4_sp   => 2*octect_size,
		udp4_dp   => 2*octect_size,
		udp4_len  => 2*octect_size,
		udp4_cksm => 2*octect_size);
		
	constant dhcp4_op     : natural :=  0;
	constant dhcp4_htype  : natural :=  1;
	constant dhcp4_hlen   : natural :=  2;
	constant dhcp4_hops   : natural :=  3;
	constant dhcp4_xid    : natural :=  4;
	constant dhcp4_secs   : natural :=  5;
	constant dhcp4_flags  : natural :=  6;
	constant dhcp4_ciaddr : natural :=  7;
	constant dhcp4_yiaddr : natural :=  8;
	constant dhcp4_siaddr : natural :=  9;
	constant dhcp4_giaddr : natural := 10;
	constant dhcp4_chaddr : natural := 11;
	constant dhcp4_shname : natural := 12;
	constant dhcp4_fbname : natural := 13;
	constant dhcp4_cookie : natural := 14;
                                       
	constant dhcp4hdr_frame : natural_vector := (
		dhcp4_op     =>   1*octect_size,
		dhcp4_htype  =>   1*octect_size,
		dhcp4_hlen   =>   1*octect_size,
		dhcp4_hops   =>   1*octect_size,
		dhcp4_xid    =>   4*octect_size,
		dhcp4_secs   =>   2*octect_size,
		dhcp4_flags  =>   2*octect_size,
		dhcp4_ciaddr =>   4*octect_size,
		dhcp4_yiaddr =>   4*octect_size,
		dhcp4_siaddr =>   4*octect_size,
		dhcp4_giaddr =>   4*octect_size,
		dhcp4_chaddr =>  16*octect_size,
		dhcp4_shname =>  64*octect_size,
		dhcp4_fbname => 128*octect_size,
		dhcp4_cookie =>   4*octect_size);
end;
