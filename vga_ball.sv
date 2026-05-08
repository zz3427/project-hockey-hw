/*
    * VGA Air Hockey peripheral
    *
    * Register map, 32-bit Avalon MM slave, word addressing:
    *
    *   Verilog Address   Byte Offset   Dir   Description
    *   0                 0x00          R     STATUS:
    *                                        bit[0] = VSYNC_READY
    *
    *   1                 0x04          W     SOUND_CONTROL:
    *                                        bits[2:0] = SOUND_EVENT
    *
    *   2                 0x08          W     P1_POS:
    *                                        bits[15:0]  = P1_X
    *                                        bits[31:16] = P1_Y
    *
    *   3                 0x0C          W     P2_POS:
    *                                        bits[15:0]  = P2_X
    *                                        bits[31:16] = P2_Y
    *
    *   4                 0x10          W     PUCK_POS:
    *                                        bits[15:0]  = PUCK_X
    *                                        bits[31:16] = PUCK_Y
    *
    *   5                 0x14          W     SCORE:
    *                                        bits[2:0] = SCORE_P1
    *                                        bits[5:3] = SCORE_P2
    *
    * Fmax (Slow 1100mV 85C): TBD after synthesis
    */

module vga_ball(
   input  logic        clk,
   input  logic        reset,

   // Avalon MM slave
   input  logic        chipselect,
   input  logic        write,
   input  logic [2:0]  address,
   input  logic [31:0] writedata,
   output logic [31:0] readdata,

   // VGA
   output logic [7:0]  VGA_R, VGA_G, VGA_B,
   output logic        VGA_CLK, VGA_HS, VGA_VS,
                       VGA_BLANK_n,
   output logic        VGA_SYNC_n,

   output logic        SOUND_OUT
);


   logic [10:0] hcount;
   logic [9:0]  vcount;

   vga_counters counters(.clk50(clk), .*);

   logic [9:0] px, py;
   assign px = hcount[10:1];
   assign py = vcount;

   // -------------------------------------------------------
   // Hardware/software interface registers
   // -------------------------------------------------------

   logic [2:0] sound_event;

   logic [9:0] p1_x, p1_y;
   logic [9:0] p2_x, p2_y;

   //puck position register
   logic [9:0] puck_x, puck_y;

   logic [2:0] score_p1, score_p2;

   always_ff @(posedge clk or posedge reset) begin
      if (reset) begin
         sound_event <= 3'd0;

         // Player 1 paddle reset position
         p1_x <= 10'd120;
         p1_y <= 10'd240;

         // Player 2 paddle reset position
         p2_x <= 10'd520;
         p2_y <= 10'd240;

         // Puck register exists but is not drawn yet
         puck_x <= 10'd320;
         puck_y <= 10'd240;

         score_p1 <= 3'd0;
         score_p2 <= 3'd0;
      end else if (chipselect && write) begin
         case (address)

            // 0x04: SOUND_CONTROL
            3'd1: begin
               sound_event <= writedata[2:0];
            end

            // 0x08: P1_POS
            3'd2: begin
               p1_x <= writedata[9:0];
               p1_y <= writedata[25:16];
            end

            // 0x0C: P2_POS
            3'd3: begin
               p2_x <= writedata[9:0];
               p2_y <= writedata[25:16];
            end

            // 0x10: PUCK_POS
            // Kept for design-doc compatibility, but not drawn yet.
            3'd4: begin
               puck_x <= writedata[9:0];
               puck_y <= writedata[25:16];
            end

            // 0x14: SCORE
            3'd5: begin
               score_p1 <= writedata[2:0];
               score_p2 <= writedata[5:3];
            end

            default: begin
               // Do nothing
            end
         endcase
      end
   end

   // -------------------------------------------------------
   // Avalon read logic
   // -------------------------------------------------------

   logic vsync_ready;
   assign vsync_ready = (vcount >= 10'd480);

   always_comb begin
      readdata = 32'd0;

      case (address)
         // 0x00: STATUS
         3'd0: begin
            readdata = {31'd0, vsync_ready};
         end

         default: begin
            readdata = 32'd0;
         end
      endcase
   end

   // -------------------------------------------------------
   // Rink geometry
   // -------------------------------------------------------

   localparam WL = 10;
   localparam WR = 629;
   localparam WT = 10;
   localparam WB = 469;

   localparam WW = 4;

   localparam GT = 190;
   localparam GB = 290;

   localparam C_LO = 24'd2116;  // 46^2
   localparam C_HI = 24'd2916;  // 54^2

   localparam PADDLE_R2 = 24'd900;  // radius 30 px
   localparam PUCK_R2   = 24'd400;  // puck radius 20 px
    
   // Score display positions
   localparam SCORE_Y  = 10'd30;
   localparam P1_SCORE_X = 10'd145;  // top of left side
   localparam P2_SCORE_X = 10'd465;  // top of right side

   localparam DIGIT_W = 10'd30;
   localparam DIGIT_H = 10'd50;

   // -------------------------------------------------------
   // Centre circle distance squared
   // -------------------------------------------------------

   logic signed [11:0] cdx, cdy;
   logic [23:0] cdist2;

   assign cdx    = $signed({2'b00, px}) - 12'sd320;
   assign cdy    = $signed({2'b00, py}) - 12'sd240;
   assign cdist2 = cdx * cdx + cdy * cdy;

   // -------------------------------------------------------
   // Paddle 1 distance squared
   // -------------------------------------------------------

   logic signed [11:0] p1dx, p1dy;
   logic [23:0] p1dist2;

   assign p1dx    = $signed({2'b00, px}) - $signed({2'b00, p1_x});
   assign p1dy    = $signed({2'b00, py}) - $signed({2'b00, p1_y});
   assign p1dist2 = p1dx * p1dx + p1dy * p1dy;

   // -------------------------------------------------------
   // Paddle 2 distance squared
   // -------------------------------------------------------

   logic signed [11:0] p2dx, p2dy;
   logic [23:0] p2dist2;

   assign p2dx    = $signed({2'b00, px}) - $signed({2'b00, p2_x});
   assign p2dy    = $signed({2'b00, py}) - $signed({2'b00, p2_y});
   assign p2dist2 = p2dx * p2dx + p2dy * p2dy;
   // -------------------------------------------------------
   // Puck distance squared
   // -------------------------------------------------------

   logic signed [11:0] puck_dx, puck_dy;
   logic [23:0] puck_dist2;

   assign puck_dx    = $signed({2'b00, px}) - $signed({2'b00, puck_x});
   assign puck_dy    = $signed({2'b00, py}) - $signed({2'b00, puck_y});
   assign puck_dist2 = puck_dx * puck_dx + puck_dy * puck_dy;


   // -------------------------------------------------------
   // Sound generator
   // -------------------------------------------------------

   sound_generator sound_gen (
      .clk(clk),
      .reset(reset),
      .event_valid(chipselect && write && address == 3'd1),
      .event_code(writedata[2:0]),
      .sound_out(SOUND_OUT)
   );


   // -------------------------------------------------------
   // Seven-segment score digit, supports 0-7
   // local x range: 0..29
   // local y range: 0..49
   // -------------------------------------------------------

   function automatic logic score_digit_on(
      input logic [2:0] digit,
      input logic [9:0] x,
      input logic [9:0] y
   );
      logic a, b, c, d, e, f, g;
      logic seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g;
   begin
      // Segment geometry
      seg_a = (y < 10'd5)  && (x >= 10'd5)  && (x < 10'd25);
      seg_b = (x >= 10'd25) && (x < 10'd30) && (y >= 10'd5)  && (y < 10'd23);
      seg_c = (x >= 10'd25) && (x < 10'd30) && (y >= 10'd27) && (y < 10'd45);
      seg_d = (y >= 10'd45) && (y < 10'd50) && (x >= 10'd5)  && (x < 10'd25);
      seg_e = (x < 10'd5)  && (y >= 10'd27) && (y < 10'd45);
      seg_f = (x < 10'd5)  && (y >= 10'd5)  && (y < 10'd23);
      seg_g = (y >= 10'd23) && (y < 10'd28) && (x >= 10'd5)  && (x < 10'd25);

      // Default: all segments off
      a = 1'b0;
      b = 1'b0;
      c = 1'b0;
      d = 1'b0;
      e = 1'b0;
      f = 1'b0;
      g = 1'b0;

      case (digit)
         3'd0: begin a=1; b=1; c=1; d=1; e=1; f=1; g=0; end
         3'd1: begin a=0; b=1; c=1; d=0; e=0; f=0; g=0; end
         3'd2: begin a=1; b=1; c=0; d=1; e=1; f=0; g=1; end
         3'd3: begin a=1; b=1; c=1; d=1; e=0; f=0; g=1; end
         3'd4: begin a=0; b=1; c=1; d=0; e=0; f=1; g=1; end
         3'd5: begin a=1; b=0; c=1; d=1; e=0; f=1; g=1; end
         3'd6: begin a=1; b=0; c=1; d=1; e=1; f=1; g=1; end
         3'd7: begin a=1; b=1; c=1; d=0; e=0; f=0; g=0; end
         default: begin a=0; b=0; c=0; d=0; e=0; f=0; g=0; end
      endcase

      score_digit_on =
         (a && seg_a) ||
         (b && seg_b) ||
         (c && seg_c) ||
         (d && seg_d) ||
         (e && seg_e) ||
         (f && seg_f) ||
         (g && seg_g);
   end
   endfunction

      // -------------------------------------------------------
   // Score display pixel detection
   // -------------------------------------------------------

   logic p1_score_on, p2_score_on;

   always_comb begin
      p1_score_on = 1'b0;
      p2_score_on = 1'b0;

      if (px >= P1_SCORE_X && px < P1_SCORE_X + DIGIT_W &&
          py >= SCORE_Y    && py < SCORE_Y + DIGIT_H) begin
         p1_score_on = score_digit_on(score_p1, px - P1_SCORE_X, py - SCORE_Y);
      end

      if (px >= P2_SCORE_X && px < P2_SCORE_X + DIGIT_W &&
          py >= SCORE_Y    && py < SCORE_Y + DIGIT_H) begin
         p2_score_on = score_digit_on(score_p2, px - P2_SCORE_X, py - SCORE_Y);
      end
   end

   // -------------------------------------------------------
   // VGA renderer
   // -------------------------------------------------------

   always_comb begin
      {VGA_R, VGA_G, VGA_B} = 24'h000000;

      if (VGA_BLANK_n) begin

         // 1. Navy blue border/background
         {VGA_R, VGA_G, VGA_B} = 24'h1a1a2e;

         // 2. Ice surface inside walls
         if (px >= WL + WW && px <= WR - WW &&
             py >= WT + WW && py <= WB - WW)
            {VGA_R, VGA_G, VGA_B} = 24'hC8E8FF;

         // 3. Goal zones
         if (px >= WL && px < WL + WW && py > GT && py < GB)
            {VGA_R, VGA_G, VGA_B} = 24'hFF8080;

         if (px > WR - WW && px <= WR && py > GT && py < GB)
            {VGA_R, VGA_G, VGA_B} = 24'h8080FF;

         // 4. Centre line
         if ((px == 319 || px == 320) &&
             py >= WT + WW && py <= WB - WW)
            {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

         // 5. Centre circle ring
         if (cdist2 >= C_LO && cdist2 <= C_HI)
            {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

         // 6. Player 1 paddle, red
         if (p1dist2 <= PADDLE_R2)
            {VGA_R, VGA_G, VGA_B} = 24'hFF0000;

         // 7. Player 2 paddle, blue
         if (p2dist2 <= PADDLE_R2)
            {VGA_R, VGA_G, VGA_B} = 24'h0000FF;

         // 8. Puck, yellow
         if (puck_dist2 <= PUCK_R2)
            {VGA_R, VGA_G, VGA_B} = 24'hFFFF00;

         // Score display, drawn on top
         if (p1_score_on)
            {VGA_R, VGA_G, VGA_B} = 24'hFF0000;

         if (p2_score_on)
            {VGA_R, VGA_G, VGA_B} = 24'h0000FF;
      end
   end

endmodule

// -------------------------------------------------------
// VGA timing generator — unchanged from lab3 skeleton
// -------------------------------------------------------
module vga_counters(
   input  logic         clk50, reset,
   output logic [10:0]  hcount,
   output logic [9:0]   vcount,
   output logic         VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);

   parameter HACTIVE      = 11'd 1280,
             HFRONT_PORCH = 11'd 32,
             HSYNC        = 11'd 192,
             HBACK_PORCH  = 11'd 96,
             HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC + HBACK_PORCH;

   parameter VACTIVE      = 10'd 480,
             VFRONT_PORCH = 10'd 10,
             VSYNC        = 10'd 2,
             VBACK_PORCH  = 10'd 33,
             VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC + VBACK_PORCH;

   logic endOfLine;

   always_ff @(posedge clk50 or posedge reset)
      if (reset)          hcount <= 0;
      else if (endOfLine) hcount <= 0;
      else                hcount <= hcount + 11'd1;

   assign endOfLine = hcount == HTOTAL - 1;

   logic endOfField;

   always_ff @(posedge clk50 or posedge reset)
      if (reset)          vcount <= 0;
      else if (endOfLine)
         if (endOfField)  vcount <= 0;
         else             vcount <= vcount + 10'd1;

   assign endOfField = vcount == VTOTAL - 1;

   assign VGA_HS = !( (hcount[10:8] == 3'b101) &
                      !(hcount[7:5] == 3'b111));
   assign VGA_VS = !( vcount[9:1] == (VACTIVE + VFRONT_PORCH) / 2);

   assign VGA_SYNC_n  = 1'b0;

   assign VGA_BLANK_n = !( hcount[10] & (hcount[9] | hcount[8]) ) &
                        !( vcount[9] | (vcount[8:5] == 4'b1111) );

   assign VGA_CLK = hcount[0];

endmodule

// -------------------------------------------------------
// Simple sound generator
// event_code:
//   0 = no sound
//   1 = puck hit wall
//   2 = puck hit paddle
//   3 = goal scored
// -------------------------------------------------------
module sound_generator(
   input  logic       clk,
   input  logic       reset,
   input  logic       event_valid,
   input  logic [2:0] event_code,
   output logic       sound_out
);

   // Assuming 50 MHz clock
   localparam [31:0] WALL_DUR   = 32'd2_500_000;   // 0.05 s
   localparam [31:0] PADDLE_DUR = 32'd3_000_000;   // 0.06 s
   localparam [31:0] GOAL_DUR   = 32'd25_000_000;  // 0.50 s

   // Half-period counts for square-wave tone generation
   // Smaller number = higher pitch
   localparam [15:0] WALL_HALF_PERIOD   = 16'd35_714;  // about 700 Hz
   localparam [15:0] PADDLE_HALF_PERIOD = 16'd25_000;  // about 1000 Hz
   localparam [15:0] GOAL_HALF_PERIOD   = 16'd20_833;  // about 1200 Hz

   logic [31:0] remaining;
   logic [15:0] half_period;
   logic [15:0] div_count;
   logic        tone;

   always_ff @(posedge clk or posedge reset) begin
      if (reset) begin
         remaining   <= 32'd0;
         half_period <= 16'd0;
         div_count   <= 16'd0;
         tone        <= 1'b0;
      end else begin

         // New sound event immediately replaces the old one
         if (event_valid) begin
            case (event_code)

               // 1: puck hit wall
               3'd1: begin
                  remaining   <= WALL_DUR;
                  half_period <= WALL_HALF_PERIOD;
                  div_count   <= WALL_HALF_PERIOD;
                  tone        <= 1'b0;
               end

               // 2: puck hit paddle
               3'd2: begin
                  remaining   <= PADDLE_DUR;
                  half_period <= PADDLE_HALF_PERIOD;
                  div_count   <= PADDLE_HALF_PERIOD;
                  tone        <= 1'b0;
               end

               // 3: goal scored
               3'd3: begin
                  remaining   <= GOAL_DUR;
                  half_period <= GOAL_HALF_PERIOD;
                  div_count   <= GOAL_HALF_PERIOD;
                  tone        <= 1'b0;
               end

               // 0 or anything else: no sound
               default: begin
                  remaining   <= 32'd0;
                  half_period <= 16'd0;
                  div_count   <= 16'd0;
                  tone        <= 1'b0;
               end
            endcase
         end

         // Continue current sound
         else if (remaining != 32'd0) begin
            remaining <= remaining - 32'd1;

            if (div_count == 16'd0) begin
               div_count <= half_period;
               tone <= ~tone;
            end else begin
               div_count <= div_count - 16'd1;
            end
         end

         // No active sound
         else begin
            tone <= 1'b0;
         end
      end
   end

   assign sound_out = tone;

endmodule