//============================================================================
//  Arcade: Stargate
//
//  Port to MiSTer
//  Copyright (C) 2018 
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [44:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        VGA_CLK,

	//Multiple resolutions are supported using different VGA_CE rates.
	//Must be based on CLK_VIDEO
	output        VGA_CE,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)

	//Base video clock. Usually equals to CLK_SYS.
	output        HDMI_CLK,

	//Multiple resolutions are supported using different HDMI_CE rates.
	//Must be based on CLK_VIDEO
	output        HDMI_CE,

	output  [7:0] HDMI_R,
	output  [7:0] HDMI_G,
	output  [7:0] HDMI_B,
	output        HDMI_HS,
	output        HDMI_VS,
	output        HDMI_DE,   // = ~(VBlank | HBlank)
	output  [1:0] HDMI_SL,   // scanlines fx

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	output  [7:0] HDMI_ARX,
	output  [7:0] HDMI_ARY,

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S    // 1 - signed audio samples, 0 - unsigned
);

assign LED_USER  = ioctl_download;
assign LED_DISK  = 0;
assign LED_POWER = 0;

assign HDMI_ARX = status[1] ? 8'd16 : 8'd4;
assign HDMI_ARY = status[1] ? 8'd9  : 8'd3;

`include "build_id.v" 
localparam CONF_STR = {
	"A.STARGATE;;", 
	"-;",
	"O1,Aspect Ratio,Original,Wide;",
	"O35,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"-;",
	"R0,Reset;",
	"J1,Fire,Smartbomb,Reverse,Inviso,Hyperspace,Start 1P,Start 2P;",
	"V,v",`BUILD_DATE
};

////////////////////   CLOCKS   ///////////////////

wire clk_sys, clk_12;
wire clk_1p79;
wire clk_0p89;

pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),
	.outclk_1(clk_12),
	.outclk_2(clk_1p79),
	.outclk_3(clk_0p89)
);


///////////////////////////////////////////////////

wire [31:0] status;
wire  [1:0] buttons;

wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;

wire [10:0] ps2_key;

wire [15:0] joy_0, joy_1;

wire        forced_scandoubler;

hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),

	.buttons(buttons),
	.status(status),
	.forced_scandoubler(forced_scandoubler),

	.ioctl_download(ioctl_download),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),

	.joystick_0(joy_0),
	.joystick_1(joy_1),
	.ps2_key(ps2_key)
);

wire       pressed = ps2_key[9];
wire [8:0] code    = ps2_key[8:0];
always @(posedge clk_sys) begin
	reg old_state;
	old_state <= ps2_key[10];
	
	if(old_state != ps2_key[10]) begin
		casex(code)
			'h023: btn_hyperspace	<= pressed; // D
			'h01D: btn_fire  			<= pressed; // W
			'h01C: btn_smartbomb    <= pressed; // A
			'h01b: btn_thrust	   	<= pressed; // s
			'h009: advance			   <= pressed; // F10
			'h001: autoup			   <= pressed; // F9
			'h076: slam				   <= pressed; // ESC
			'h083: HSreset			   <= pressed; // F7

			'h005: btn_one_player  <= pressed; // F1
			'h006: btn_two_players <= pressed; // F2
			'h004: lcoin	        <= pressed; // F3
			'h00C: rcoin		     <= pressed; // F4	

			'h016: btn_one_player  <= pressed; // 1
			'h01e: btn_two_players <= pressed; // 2
			'h02e: rcoin	        <= pressed; // 5 coin			
	
			'hX6B: btn_thrust      <= pressed; // left
			'hX74: btn_thrust	     <= pressed; // right
			'hX75: btn_up          <= pressed; // up
			'hX72: btn_down        <= pressed; // down

			'h014: btn_fire        <= pressed; // ctrl
			'h011: btn_smartbomb   <= pressed; // alt			
			'h029: btn_reverse     <= pressed; // space
			'h012: btn_inviso   	  <= pressed; // l shift
			'h059: btn_inviso      <= pressed; // r shift			
		endcase
	end
end

reg dummy =0;
reg btn_hyperspace=0;
reg btn_fire=0;
reg btn_smartbomb=0;
reg btn_thrust=0;
reg btn_reverse=0;
reg btn_inviso=0;

reg HSreset = 0;
reg lcoin = 0;
reg rcoin = 0;
reg slam = 0;
reg autoup = 0;
reg advance = 0;
reg btn_one_player = 0;
reg btn_two_players = 0;
reg btn_down = 0;
reg btn_up = 0;

wire [15:0] joy = joy_0 | joy_1;

wire [7:0] sw = {btn_one_player | joy[9], slam, rcoin | lcoin | joy[9] | joy[10], dummy, dummy, HSreset, advance, autoup};

wire [8:0] jc = 
       {btn_two_players | joy[10], btn_inviso    | joy[7], btn_up     | joy[3], btn_down | joy[2], btn_reverse | joy[6],
        btn_hyperspace  | joy[8],  btn_smartbomb | joy[5], btn_thrust | joy[0] | joy[1], btn_fire | joy[4]};			  

///////////////////////////////////////////////////////////////////

wire [2:0] r,g;
wire [1:0] b;

arcade_fx #(360,8) arcade_video
(
	.*,

	.clk_video(clk_sys),
	.ce_pix(!pcnt[1:0]),

	.RGB_in({r,g,b}),
	.HBlank(HBlank),
	.VBlank(VBlank),
	.HSync(HSync),
	.VSync(VSync),

	.fx(status[5:3])
);

wire [7:0] audio;
assign AUDIO_L = {audio, audio};
assign AUDIO_R = AUDIO_L;
assign AUDIO_S = 0;

williams_cpu williams_cpu
(
	.clk_sys(clk_sys),
	.CLK12(clk_12),
	.clk_1p79(clk_1p79),
	.clk_0p89(clk_0p89),

	.I_RESET(RESET | status[0] | buttons[1] | ioctl_download),

	.dn_addr(ioctl_addr[15:0]),
	.dn_data(ioctl_dout),
	.dn_wr(ioctl_wr),

	.vgaR(ri),
	.vgaG(gi),
	.vgaB(bi),
	.Hsync(hs),
	.Vsync(vs),
	.JA(jc),
	.JB(jc),
	.SW(sw),
	.audio_out(audio)

);

wire [2:0] ri,gi;
wire [1:0] bi;
wire vs,hs;

// scanhalver :)
dpram #(9) line
(
	.clock_a(clk_12),
	.address_a(pcnti),
	.data_a({ri,gi,bi}),
	.wren_a(~lcnt[0]),

	.clock_b(clk_sys),
	.address_b(pcnt[11:2]),
	.q_b({r,g,b})
);

reg  [9:0] pcnti;
always @(posedge clk_12) begin
	reg old_hs;

	old_hs <= hs;
	if(~&pcnti) pcnti <= pcnti + 1'd1;

	if(old_hs & ~hs) pcnti <= 0;
end

reg HSync;
reg VSync;
reg HBlank;
reg VBlank;
reg [10:0] lcnt;
reg [11:0] pcnt;
always @(posedge clk_sys) begin
	reg old_vs, old_hs;
	reg vs1, hs1;

	hs1 <= hs;
	vs1 <= vs;

	if(~&pcnt) pcnt <= pcnt + 1'd1;

	old_hs <= hs1;
	if(old_hs & ~hs1) begin
		if(lcnt[0]) pcnt <= 0;
		if(~&lcnt) lcnt <= lcnt + 1'd1;

		old_vs <= vs1;
		if(old_vs & ~vs1) lcnt <= 0;
	end

	if (pcnt[11:2] == 348) HBlank <= 1;
	if (pcnt[11:2] == 370) HSync  <= 1;
	if (pcnt[11:2] == 014) HSync  <= 0;
	if (pcnt[11:2] == 052) HBlank <= 0;

	if (lcnt == 494) VBlank <= 1;
	if (lcnt == 496) VSync  <= 1;
	if (lcnt == 000) VSync  <= 0;
	if (lcnt == 014) VBlank <= 0;
end

endmodule
