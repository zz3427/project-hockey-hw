// ==================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ==================================================================
//
// Modified 2019 by Stephen A. Edwards
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera
//   Development Kits made by Terasic.  Other use of this code,
//   including the selling ,duplication, or modification of any
//   portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design
//   reference which illustrates how these types of functions can be
//   implemented.  It is the user's responsibility to verify their
//   design for consistency and functionality through the use of
//   formal verification methods.  Terasic provides no warranty
//   regarding the use or functionality of this code.
//
// ===============================================================
//           
//  Terasic Technologies Inc

//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
module soc_system_top(
                      
 ///////// ADC /////////
 inout         ADC_CS_N,
 output        ADC_DIN,
 input         ADC_DOUT,
 output        ADC_SCLK,

 ///////// AUD /////////
 input         AUD_ADCDAT,
 inout         AUD_ADCLRCK,
 //inout         AUD_BCLK,
 output        AUD_BCLK,
 output        AUD_DACDAT,
 //inout         AUD_DACLRCK,
 output        AUD_DACLRCK,
 output        AUD_XCK,

 ///////// CLOCK2 /////////
 input         CLOCK2_50,

 ///////// CLOCK3 /////////
 input         CLOCK3_50,

 ///////// CLOCK4 /////////
 input         CLOCK4_50,

 ///////// CLOCK /////////
 input         CLOCK_50,

 ///////// DRAM /////////
 output [12:0] DRAM_ADDR,
 output [1:0]  DRAM_BA,
 output        DRAM_CAS_N,
 output        DRAM_CKE,
 output        DRAM_CLK,
 output        DRAM_CS_N,
 inout [15:0]  DRAM_DQ,
 output        DRAM_LDQM,
 output        DRAM_RAS_N,
 output        DRAM_UDQM,
 output        DRAM_WE_N,

 ///////// FAN /////////
 output        FAN_CTRL,

 ///////// FPGA /////////
 output        FPGA_I2C_SCLK,
 inout         FPGA_I2C_SDAT,

 ///////// GPIO /////////
 inout [35:0]  GPIO_0,
 inout [35:0]  GPIO_1,

 ///////// HEX0 /////////
 output [6:0]  HEX0,

 ///////// HEX1 /////////
 output [6:0]  HEX1,

 ///////// HEX2 /////////
 output [6:0]  HEX2,

 ///////// HEX3 /////////
 output [6:0]  HEX3,

 ///////// HEX4 /////////
 output [6:0]  HEX4,

 ///////// HEX5 /////////
 output [6:0]  HEX5,

 ///////// HPS /////////
 inout         HPS_CONV_USB_N,
 output [14:0] HPS_DDR3_ADDR,
 output [2:0]  HPS_DDR3_BA,
 output        HPS_DDR3_CAS_N,
 output        HPS_DDR3_CKE,
 output        HPS_DDR3_CK_N,
 output        HPS_DDR3_CK_P,
 output        HPS_DDR3_CS_N,
 output [3:0]  HPS_DDR3_DM,
 inout [31:0]  HPS_DDR3_DQ,
 inout [3:0]   HPS_DDR3_DQS_N,
 inout [3:0]   HPS_DDR3_DQS_P,
 output        HPS_DDR3_ODT,
 output        HPS_DDR3_RAS_N,
 output        HPS_DDR3_RESET_N,
 input         HPS_DDR3_RZQ,
 output        HPS_DDR3_WE_N,
 output        HPS_ENET_GTX_CLK,
 inout         HPS_ENET_INT_N,
 output        HPS_ENET_MDC,
 inout         HPS_ENET_MDIO,
 input         HPS_ENET_RX_CLK,
 input [3:0]   HPS_ENET_RX_DATA,
 input         HPS_ENET_RX_DV,
 output [3:0]  HPS_ENET_TX_DATA,
 output        HPS_ENET_TX_EN,
 inout         HPS_GSENSOR_INT,
 inout         HPS_I2C1_SCLK,
 inout         HPS_I2C1_SDAT,
 inout         HPS_I2C2_SCLK,
 inout         HPS_I2C2_SDAT,
 inout         HPS_I2C_CONTROL,
 inout         HPS_KEY,
 inout         HPS_LED,
 inout         HPS_LTC_GPIO,
 output        HPS_SD_CLK,
 inout         HPS_SD_CMD,
 inout [3:0]   HPS_SD_DATA,
 output        HPS_SPIM_CLK,
 input         HPS_SPIM_MISO,
 output        HPS_SPIM_MOSI,
 inout         HPS_SPIM_SS,
 input         HPS_UART_RX,
 output        HPS_UART_TX,
 input         HPS_USB_CLKOUT,
 inout [7:0]   HPS_USB_DATA,
 input         HPS_USB_DIR,
 input         HPS_USB_NXT,
 output        HPS_USB_STP,

 ///////// IRDA /////////
 input         IRDA_RXD,
 output        IRDA_TXD,

 ///////// KEY /////////
 input [3:0]   KEY,

 ///////// LEDR /////////
 output [9:0]  LEDR,

 ///////// PS2 /////////
 inout         PS2_CLK,
 inout         PS2_CLK2,
 inout         PS2_DAT,
 inout         PS2_DAT2,

 ///////// SW /////////
 input [9:0]   SW,

 ///////// TD /////////
 input         TD_CLK27,
 input [7:0]   TD_DATA,
 input         TD_HS,
 output        TD_RESET_N,
 input         TD_VS,


 ///////// VGA /////////
 output [7:0]  VGA_B,
 output        VGA_BLANK_N,
 output        VGA_CLK,
 output [7:0]  VGA_G,
 output        VGA_HS,
 output [7:0]  VGA_R,
 output        VGA_SYNC_N,
 output        VGA_VS
);

   logic sound_out;

   logic signed [15:0] audio_sample;
   logic sound_out_prev;
   logic sound_trigger;

   always_ff @(posedge CLOCK_50) begin
     sound_out_prev <= sound_out;
   end

   assign sound_trigger = sound_out && !sound_out_prev;

   soc_system soc_system0(
     .clk_clk                      ( CLOCK_50 ),
     .reset_reset_n                ( 1'b1 ),
                          
     .hps_ddr3_mem_a               ( HPS_DDR3_ADDR ),
     .hps_ddr3_mem_ba              ( HPS_DDR3_BA ),
     .hps_ddr3_mem_ck              ( HPS_DDR3_CK_P ),
     .hps_ddr3_mem_ck_n            ( HPS_DDR3_CK_N ),
     .hps_ddr3_mem_cke             ( HPS_DDR3_CKE ),
     .hps_ddr3_mem_cs_n            ( HPS_DDR3_CS_N ),
     .hps_ddr3_mem_ras_n           ( HPS_DDR3_RAS_N ),
     .hps_ddr3_mem_cas_n           ( HPS_DDR3_CAS_N ),
     .hps_ddr3_mem_we_n            ( HPS_DDR3_WE_N ),
     .hps_ddr3_mem_reset_n         ( HPS_DDR3_RESET_N ),
     .hps_ddr3_mem_dq              ( HPS_DDR3_DQ ),
     .hps_ddr3_mem_dqs             ( HPS_DDR3_DQS_P ),
     .hps_ddr3_mem_dqs_n           ( HPS_DDR3_DQS_N ),
     .hps_ddr3_mem_odt             ( HPS_DDR3_ODT ),
     .hps_ddr3_mem_dm              ( HPS_DDR3_DM ),
     .hps_ddr3_oct_rzqin           ( HPS_DDR3_RZQ ),
     
     .hps_hps_io_emac1_inst_TX_CLK ( HPS_ENET_GTX_CLK ),
     .hps_hps_io_emac1_inst_TXD0   ( HPS_ENET_TX_DATA[0] ),
     .hps_hps_io_emac1_inst_TXD1   ( HPS_ENET_TX_DATA[1] ),
     .hps_hps_io_emac1_inst_TXD2   ( HPS_ENET_TX_DATA[2] ),
     .hps_hps_io_emac1_inst_TXD3   ( HPS_ENET_TX_DATA[3] ),
     .hps_hps_io_emac1_inst_RXD0   ( HPS_ENET_RX_DATA[0] ),
     .hps_hps_io_emac1_inst_MDIO   ( HPS_ENET_MDIO  ),
     .hps_hps_io_emac1_inst_MDC    ( HPS_ENET_MDC   ),
     .hps_hps_io_emac1_inst_RX_CTL ( HPS_ENET_RX_DV ),
     .hps_hps_io_emac1_inst_TX_CTL ( HPS_ENET_TX_EN ),
     .hps_hps_io_emac1_inst_RX_CLK ( HPS_ENET_RX_CLK ),
     .hps_hps_io_emac1_inst_RXD1   ( HPS_ENET_RX_DATA[1]  ),
     .hps_hps_io_emac1_inst_RXD2   ( HPS_ENET_RX_DATA[2]  ),
     .hps_hps_io_emac1_inst_RXD3   ( HPS_ENET_RX_DATA[3]  ),
              
     .hps_hps_io_sdio_inst_CMD     ( HPS_SD_CMD          ),
     .hps_hps_io_sdio_inst_D0      ( HPS_SD_DATA[0]      ),
     .hps_hps_io_sdio_inst_D1      ( HPS_SD_DATA[1]      ),
     .hps_hps_io_sdio_inst_CLK     ( HPS_SD_CLK          ),
     .hps_hps_io_sdio_inst_D2      ( HPS_SD_DATA[2]      ),
     .hps_hps_io_sdio_inst_D3      ( HPS_SD_DATA[3]      ),
     
     .hps_hps_io_usb1_inst_D0      ( HPS_USB_DATA[0]     ),
     .hps_hps_io_usb1_inst_D1      ( HPS_USB_DATA[1]     ),
     .hps_hps_io_usb1_inst_D2      ( HPS_USB_DATA[2]     ),
     .hps_hps_io_usb1_inst_D3      ( HPS_USB_DATA[3]     ),
     .hps_hps_io_usb1_inst_D4      ( HPS_USB_DATA[4]     ),
     .hps_hps_io_usb1_inst_D5      ( HPS_USB_DATA[5]     ),
     .hps_hps_io_usb1_inst_D6      ( HPS_USB_DATA[6]     ),
     .hps_hps_io_usb1_inst_D7      ( HPS_USB_DATA[7]     ),
     .hps_hps_io_usb1_inst_CLK     ( HPS_USB_CLKOUT      ),
     .hps_hps_io_usb1_inst_STP     ( HPS_USB_STP         ),
     .hps_hps_io_usb1_inst_DIR     ( HPS_USB_DIR         ),
     .hps_hps_io_usb1_inst_NXT     ( HPS_USB_NXT         ),
     
     .hps_hps_io_spim1_inst_CLK    ( HPS_SPIM_CLK  ),
     .hps_hps_io_spim1_inst_MOSI   ( HPS_SPIM_MOSI ),
     .hps_hps_io_spim1_inst_MISO   ( HPS_SPIM_MISO ),
     .hps_hps_io_spim1_inst_SS0    ( HPS_SPIM_SS   ),
     
     .hps_hps_io_uart0_inst_RX     ( HPS_UART_RX     ),
     .hps_hps_io_uart0_inst_TX     ( HPS_UART_TX     ),
     
     .hps_hps_io_i2c0_inst_SDA     ( HPS_I2C1_SDAT     ),
     .hps_hps_io_i2c0_inst_SCL     ( HPS_I2C1_SCLK     ),
     
     .hps_hps_io_i2c1_inst_SDA     ( HPS_I2C2_SDAT     ),
     .hps_hps_io_i2c1_inst_SCL     ( HPS_I2C2_SCLK     ),
     
     .hps_hps_io_gpio_inst_GPIO09  ( HPS_CONV_USB_N ),
     .hps_hps_io_gpio_inst_GPIO35  ( HPS_ENET_INT_N ),
     .hps_hps_io_gpio_inst_GPIO40  ( HPS_LTC_GPIO ),

     .hps_hps_io_gpio_inst_GPIO48  ( HPS_I2C_CONTROL ),
     .hps_hps_io_gpio_inst_GPIO53  ( HPS_LED ),
     .hps_hps_io_gpio_inst_GPIO54  ( HPS_KEY ),
     .hps_hps_io_gpio_inst_GPIO61  ( HPS_GSENSOR_INT ),
.vga_r (VGA_R),
.vga_g (VGA_G),
.vga_b (VGA_B),
.vga_clk (VGA_CLK),
.vga_hs (VGA_HS),
.vga_vs (VGA_VS),
.vga_blank_n (VGA_BLANK_N),
.vga_sync_n (VGA_SYNC_N),

.sound_sound_out (sound_out)
  );

   // The following quiet the "no driver" warnings for output
   // pins and should be removed if you use any of these peripherals

   assign ADC_CS_N = SW[1] ? SW[0] : 1'bZ;
   assign ADC_DIN = SW[0];
   assign ADC_SCLK = SW[0];
   
   //assign AUD_ADCLRCK = SW[1] ? SW[0] : 1'bZ;
   //assign AUD_BCLK = SW[1] ? SW[0] : 1'bZ;
   //assign AUD_DACDAT = SW[0];
   //assign AUD_DACLRCK = SW[1] ? SW[0] : 1'bZ;
   //assign AUD_XCK = SW[0];      

   assign AUD_ADCLRCK = 1'bZ;

  sample_player #(
    .SAMPLE_COUNT(9355)
  ) paddle_player (
    .clk50(CLOCK_50),
    .reset(1'b0),
    .trigger(sound_trigger),
    .sample(audio_sample)
  );


// Simple AUX/audio-jack test output
  simple_audio_out audio_out (
    .clk50(CLOCK_50),
    .reset(1'b0),
    .audio_sample(audio_sample),
    .AUD_XCK(AUD_XCK),
    .AUD_BCLK(AUD_BCLK),
    .AUD_DACLRCK(AUD_DACLRCK),
    .AUD_DACDAT(AUD_DACDAT)
  );

   assign DRAM_ADDR = { 13{ SW[0] } };
   assign DRAM_BA = { 2{ SW[0] } };
   assign DRAM_DQ = SW[1] ? { 16{ SW[0] } } : { 16{ 1'bZ } };
   assign {DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N,
           DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N} = { 8{SW[0]} };

   assign FAN_CTRL = SW[0];

   //assign FPGA_I2C_SCLK = SW[0];
   //assign FPGA_I2C_SDAT = SW[1] ? SW[0] : 1'bZ;
   wm8731_config audio_codec_config (
    .clk50(CLOCK_50),
    .reset(1'b0),
    .I2C_SCLK(FPGA_I2C_SCLK),
    .I2C_SDAT(FPGA_I2C_SDAT)
  );

   assign GPIO_0 = SW[1] ? { 36{ SW[0] } } : { 36{ 1'bZ } };
   //assign GPIO_0[0]    = sound_out;
   //assign GPIO_0[35:1] = SW[1] ? { 35{ SW[0] } } : { 35{ 1'bZ } };
   assign GPIO_1 = SW[1] ? { 36{ SW[0] } } : { 36{ 1'bZ } };

   assign HEX0 = { 7{ SW[1] } };
   assign HEX1 = { 7{ SW[2] } };
   assign HEX2 = { 7{ SW[3] } };
   assign HEX3 = { 7{ SW[4] } };
   assign HEX4 = { 7{ SW[5] } };
   assign HEX5 = { 7{ SW[6] } };

   assign IRDA_TXD = SW[0];

   assign LEDR = { 10{SW[7]} };

   assign PS2_CLK = SW[1] ? SW[0] : 1'bZ;
   assign PS2_CLK2 = SW[1] ? SW[0] : 1'bZ;
   assign PS2_DAT = SW[1] ? SW[0] : 1'bZ;
   assign PS2_DAT2 = SW[1] ? SW[0] : 1'bZ;

   assign TD_RESET_N = SW[0];

                                                                  
endmodule


// -------------------------------------------------------
// Simple audio output test module
//
// This converts a 1-bit tone signal into serial audio-style
// output for the DE1-SoC audio codec pins.
//
// NOTE:
// This assumes the audio codec is already configured.
// If the codec is not configured through I2C, the AUX jack
// may still be silent even if these signals toggle correctly.
// -------------------------------------------------------
module simple_audio_out(
   input  logic clk50,
   input  logic reset,
   input  logic signed [15:0] audio_sample,

   output logic AUD_XCK,
   output logic AUD_BCLK,
   output logic AUD_DACLRCK,
   output logic AUD_DACDAT
);

   logic [9:0] div;
   logic bclk_prev;
   logic [4:0] bit_pos;
   logic signed [15:0] frame_sample;

   assign AUD_XCK  = div[1];   // 12.5 MHz
   assign AUD_BCLK = div[4];   // 1.5625 MHz

   wire bclk_falling = bclk_prev && !div[4];

   always_ff @(posedge clk50 or posedge reset) begin
      if (reset) begin
         div <= 10'd0;
         bclk_prev <= 1'b0;
         bit_pos <= 5'd0;
         frame_sample <= 16'sd0;
         AUD_DACLRCK <= 1'b0;
         AUD_DACDAT <= 1'b0;
      end else begin
         div <= div + 10'd1;
         bclk_prev <= div[4];

         if (bclk_falling) begin
            if (bit_pos == 5'd0) begin
               frame_sample <= audio_sample;
            end

            if (bit_pos < 5'd16) begin
               AUD_DACLRCK <= 1'b0; // left channel
               AUD_DACDAT <= frame_sample[15 - bit_pos];
            end else begin
               AUD_DACLRCK <= 1'b1; // right channel
               AUD_DACDAT <= frame_sample[31 - bit_pos];
            end

            if (bit_pos == 5'd31)
               bit_pos <= 5'd0;
            else
               bit_pos <= bit_pos + 5'd1;
         end
      end
   end

endmodule


// -------------------------------------------------------
// WM8731 audio codec I2C configuration
//
// Sends a basic startup sequence to the DE1-SoC audio codec.
// This enables DAC output so AUD_DACDAT/AUD_BCLK/AUD_DACLRCK
// can produce sound through the AUX/headphone jack.
// -------------------------------------------------------
module wm8731_config(
   input  logic clk50,
   input  logic reset,

   output logic I2C_SCLK,
   inout        I2C_SDAT
);

   // WM8731 7-bit I2C address is usually 0x1A.
   localparam [6:0] CODEC_ADDR = 7'h1A;

   // I2C clock divider: 50 MHz / 500 = 100 kHz-ish
   localparam integer CLK_DIV = 250;

   logic [15:0] clk_count;
   logic tick;

   always_ff @(posedge clk50 or posedge reset) begin
      if (reset) begin
         clk_count <= 16'd0;
         tick <= 1'b0;
      end else begin
         if (clk_count == CLK_DIV - 1) begin
            clk_count <= 16'd0;
            tick <= 1'b1;
         end else begin
            clk_count <= clk_count + 16'd1;
            tick <= 1'b0;
         end
      end
   end

   // Open-drain style I2C data line
   logic sdat_out_en;
   logic sdat_out;

   assign I2C_SDAT = sdat_out_en ? sdat_out : 1'bZ;

   // We drive SCLK directly.
   // Idle high.
   logic scl;

   assign I2C_SCLK = scl;

   // WM8731 register write format:
   // First byte:  {7-bit device address, write bit 0}
   // Then 16 data bits:
   //   [15:9] register address
   //   [8:0]  register data
   //
   // Common config sequence:
   // R15 reset
   // R6  power up
   // R4  analog path: DAC select
   // R5  digital path
   // R7  digital audio interface: I2S, 16-bit
   // R8  sampling control
   // R9  active

   logic [3:0] rom_index;
   logic [15:0] rom_data;

   always_comb begin
      case (rom_index)
         4'd0: rom_data = {7'd15, 9'h000}; // reset
         4'd1: rom_data = {7'd6,  9'h000}; // power up everything
         4'd2: rom_data = {7'd2,  9'h079}; // left headphone volume
         4'd3: rom_data = {7'd3,  9'h079}; // right headphone volume
         4'd4: rom_data = {7'd4,  9'h012}; // analog path: DAC selected
         4'd5: rom_data = {7'd5,  9'h000}; // digital path
         4'd6: rom_data = {7'd7,  9'h000}; // I2S, 16-bit
         4'd7: rom_data = {7'd8,  9'h000}; // normal mode sampling
         4'd8: rom_data = {7'd9,  9'h001}; // activate codec
         default: rom_data = 16'h0000;
      endcase
   end

   typedef enum logic [4:0] {
      ST_IDLE,
      ST_START_1,
      ST_START_2,
      ST_SEND_ADDR,
      ST_ACK_ADDR,
      ST_SEND_HIGH,
      ST_ACK_HIGH,
      ST_SEND_LOW,
      ST_ACK_LOW,
      ST_STOP_1,
      ST_STOP_2,
      ST_DONE
   } state_t;

   state_t state;

   logic [7:0] byte_to_send;
   logic [2:0] bit_index;
   logic phase;
   logic [15:0] wait_count;

   always_ff @(posedge clk50 or posedge reset) begin
      if (reset) begin
         state <= ST_IDLE;
         rom_index <= 4'd0;
         scl <= 1'b1;
         sdat_out_en <= 1'b1;
         sdat_out <= 1'b1;
         byte_to_send <= 8'd0;
         bit_index <= 3'd7;
         phase <= 1'b0;
         wait_count <= 16'd0;
      end else if (tick) begin
         case (state)

            ST_IDLE: begin
               scl <= 1'b1;
               sdat_out_en <= 1'b1;
               sdat_out <= 1'b1;
               wait_count <= wait_count + 16'd1;

               // Small startup delay
               if (wait_count == 16'd1000) begin
                  wait_count <= 16'd0;
                  state <= ST_START_1;
               end
            end

            // I2C start: SDA goes low while SCL high
            ST_START_1: begin
               scl <= 1'b1;
               sdat_out_en <= 1'b1;
               sdat_out <= 1'b0;
               state <= ST_START_2;
            end

            ST_START_2: begin
               scl <= 1'b0;
               byte_to_send <= {CODEC_ADDR, 1'b0}; // write
               bit_index <= 3'd7;
               phase <= 1'b0;
               state <= ST_SEND_ADDR;
            end

            ST_SEND_ADDR: begin
               if (phase == 1'b0) begin
                  scl <= 1'b0;
                  sdat_out_en <= 1'b1;
                  sdat_out <= byte_to_send[bit_index];
                  phase <= 1'b1;
               end else begin
                  scl <= 1'b1;
                  phase <= 1'b0;
                  if (bit_index == 3'd0)
                     state <= ST_ACK_ADDR;
                  else
                     bit_index <= bit_index - 3'd1;
               end
            end

            ST_ACK_ADDR: begin
               if (phase == 1'b0) begin
                  scl <= 1'b0;
                  sdat_out_en <= 1'b0; // release SDA for ACK
                  phase <= 1'b1;
               end else begin
                  scl <= 1'b1;
                  phase <= 1'b0;
                  byte_to_send <= rom_data[15:8];
                  bit_index <= 3'd7;
                  state <= ST_SEND_HIGH;
               end
            end

            ST_SEND_HIGH: begin
               if (phase == 1'b0) begin
                  scl <= 1'b0;
                  sdat_out_en <= 1'b1;
                  sdat_out <= byte_to_send[bit_index];
                  phase <= 1'b1;
               end else begin
                  scl <= 1'b1;
                  phase <= 1'b0;
                  if (bit_index == 3'd0)
                     state <= ST_ACK_HIGH;
                  else
                     bit_index <= bit_index - 3'd1;
               end
            end

            ST_ACK_HIGH: begin
               if (phase == 1'b0) begin
                  scl <= 1'b0;
                  sdat_out_en <= 1'b0;
                  phase <= 1'b1;
               end else begin
                  scl <= 1'b1;
                  phase <= 1'b0;
                  byte_to_send <= rom_data[7:0];
                  bit_index <= 3'd7;
                  state <= ST_SEND_LOW;
               end
            end

            ST_SEND_LOW: begin
               if (phase == 1'b0) begin
                  scl <= 1'b0;
                  sdat_out_en <= 1'b1;
                  sdat_out <= byte_to_send[bit_index];
                  phase <= 1'b1;
               end else begin
                  scl <= 1'b1;
                  phase <= 1'b0;
                  if (bit_index == 3'd0)
                     state <= ST_ACK_LOW;
                  else
                     bit_index <= bit_index - 3'd1;
               end
            end

            ST_ACK_LOW: begin
               if (phase == 1'b0) begin
                  scl <= 1'b0;
                  sdat_out_en <= 1'b0;
                  phase <= 1'b1;
               end else begin
                  scl <= 1'b1;
                  phase <= 1'b0;
                  state <= ST_STOP_1;
               end
            end

            // I2C stop: SDA goes high while SCL high
            ST_STOP_1: begin
               scl <= 1'b0;
               sdat_out_en <= 1'b1;
               sdat_out <= 1'b0;
               state <= ST_STOP_2;
            end

            ST_STOP_2: begin
               scl <= 1'b1;
               sdat_out_en <= 1'b1;
               sdat_out <= 1'b1;

               if (rom_index == 4'd8) begin
                  state <= ST_DONE;
               end else begin
                  rom_index <= rom_index + 4'd1;
                  state <= ST_START_1;
               end
            end

            ST_DONE: begin
               scl <= 1'b1;
               sdat_out_en <= 1'b1;
               sdat_out <= 1'b1;
            end

            default: begin
               state <= ST_IDLE;
            end

         endcase
      end
   end

endmodule

module sample_player #(
   parameter SAMPLE_COUNT = 8000
)(
   input  logic clk50,
   input  logic reset,
   input  logic trigger,

   output logic signed [15:0] sample
);

   localparam integer SAMPLE_DIV = 1024; 

   logic [15:0] sample_rom [0:SAMPLE_COUNT-1];
   logic [31:0] div_count;
   logic [$clog2(SAMPLE_COUNT)-1:0] index;
   logic playing;

   initial begin
      $readmemh("sounds/paddle.mem", sample_rom);
   end

   always_ff @(posedge clk50 or posedge reset) begin
      if (reset) begin
         div_count <= 32'd0;
         index <= '0;
         sample <= 16'sd0;
         playing <= 1'b0;
      end else begin
         if (trigger && !playing) begin
            playing <= 1'b1;
            index <= '0;
            div_count <= 32'd0;
            sample <= sample_rom[0];
         end else if (playing) begin
            if (div_count == SAMPLE_DIV - 1) begin
               div_count <= 32'd0;
               sample <= sample_rom[index];

               if (index == SAMPLE_COUNT - 1) begin
                  playing <= 1'b0;
                  sample <= 16'sd0;
               end else begin
                  index <= index + 1'b1;
               end
            end else begin
               div_count <= div_count + 1'b1;
            end
         end else begin
            sample <= 16'sd0;
         end
      end
   end

endmodule