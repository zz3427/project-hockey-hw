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

   output logic        SOUND_VALID,
   output logic [2:0]  SOUND_CODE
   
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

   // Centre circles (two concentric rings)
   localparam CCR_LO = 24'd756;   // inner red  ring: r ≈ 30, lo = 27.5²
   localparam CCR_HI = 24'd1056;  //                  hi = 32.5²
   localparam CCB_LO = 24'd2756;  // outer blue ring: r ≈ 55, lo = 52.5²
   localparam CCB_HI = 24'd3306;  //                  hi = 57.5²

   // Goal arcs: circle centred at left/right wall mid, r = 90 ± 3 px
   localparam ARC_LO = 24'd7569;  // 87²
   localparam ARC_HI = 24'd8649;  // 93²

   // Paddle dome: 2-level radial gradient (r² thresholds)
   localparam PAD_L1 = 24'd196;    // r ≤  14  bright
   localparam PAD_L2 = 24'd256;   // r ≤ 16  inside border
   localparam PAD_L3 = 24'd784;  // r ≤ 28  dark
   localparam PAD_R2 = 24'd900;  // r ≤ 30  border

   // Puck dome: 2-level radial gradient (r² thresholds)
   localparam PUCK_L1 = 24'd256;   // r ≤  16  bright
   localparam PUCK_L2 = 24'd289;  // r ≤ 17  inside border
   localparam PUCK_L3 = 24'd361;  // r ≤ 19  dark
   localparam PUCK_R2 = 24'd400;  // r ≤ 20  border

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
   // Goal arc distance squared (centre = wall mid-point, r = 90 px)
   // -------------------------------------------------------

   logic signed [11:0] lax, lay;
   logic [23:0] larc_dist2;
   assign lax       = $signed({2'b00, px}) - 12'sd10;
   assign lay       = $signed({2'b00, py}) - 12'sd240;
   assign larc_dist2 = lax * lax + lay * lay;

   logic signed [11:0] rax, ray;
   logic [23:0] rarc_dist2;
   assign rax       = $signed({2'b00, px}) - 12'sd629;
   assign ray       = $signed({2'b00, py}) - 12'sd240;
   assign rarc_dist2 = rax * rax + ray * ray;

   // -------------------------------------------------------
   // Sound event pulse
   // -------------------------------------------------------

   // always_ff @(posedge clk or posedge reset) begin
   //    if (reset) begin
   //       SOUND_VALID <= 1'b0;
   //    end else begin
   //       // default: only pulse for one clock cycle
   //       SOUND_VALID <= 1'b0;

   //       if (chipselect && write && address == 3'd1 && writedata[2:0] != 3'd0) begin
   //          SOUND_VALID <= 1'b1;
   //       end
   //    end
   // end

   always_ff @(posedge clk or posedge reset) begin
      if (reset) begin
         SOUND_VALID <= 1'b0;
         SOUND_CODE  <= 3'd0;
      end else begin
         SOUND_VALID <= 1'b0;

         if (chipselect && write && address == 3'd1 && writedata[2:0] != 3'd0) begin
            SOUND_VALID <= 1'b1;
            SOUND_CODE  <= writedata[2:0];
         end
      end
   end


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

         // 1. Dark board border
         {VGA_R, VGA_G, VGA_B} = 24'h222222;

         // 2. Ice surface inside walls
         if (px >= WL + WW && px <= WR - WW &&
             py >= WT + WW && py <= WB - WW)
            {VGA_R, VGA_G, VGA_B} = 24'hF0F4FF;

         // 3. Goal slot openings in wall
         if (px >= WL && px < WL + WW && py > GT && py < GB)
            {VGA_R, VGA_G, VGA_B} = 24'hCC1414;
         if (px > WR - WW && px <= WR && py > GT && py < GB)
            {VGA_R, VGA_G, VGA_B} = 24'h1432CC;

         // 4. Goal arcs (ring centred on wall mid, r = 90 px)
         if (larc_dist2 >= ARC_LO && larc_dist2 <= ARC_HI && px >= WL + WW)
            {VGA_R, VGA_G, VGA_B} = 24'hCC1414;
         if (rarc_dist2 >= ARC_LO && rarc_dist2 <= ARC_HI && px <= WR - WW)
            {VGA_R, VGA_G, VGA_B} = 24'h1432CC;

         // 5. Centre line (red)
         if ((px == 319 || px == 320) &&
             py >= WT + WW && py <= WB - WW)
            {VGA_R, VGA_G, VGA_B} = 24'hCC2020;

         // 6. Centre circles: inner red ring, outer blue ring
         if (cdist2 >= CCR_LO && cdist2 <= CCR_HI)
            {VGA_R, VGA_G, VGA_B} = 24'hCC2020;
         if (cdist2 >= CCB_LO && cdist2 <= CCB_HI)
            {VGA_R, VGA_G, VGA_B} = 24'h2020CC;

         // 7. Puck: 2-level gray radial dome
         if (puck_dist2 <= PUCK_R2) begin
            if      (puck_dist2 <= PUCK_L1) {VGA_R, VGA_G, VGA_B} = 24'h484848;
            else if (puck_dist2 <= PUCK_L2) {VGA_R, VGA_G, VGA_B} = 24'h000000;
            else if (puck_dist2 <= PUCK_L3) {VGA_R, VGA_G, VGA_B} = 24'h484848;
            else                             {VGA_R, VGA_G, VGA_B} = 24'h000000;
         end

         // 8. Paddle 1: 2-level red radial dome
         if (p1dist2 <= PAD_R2) begin
            if      (p1dist2 <= PAD_L1) {VGA_R, VGA_G, VGA_B} = 24'hFF2200;
            else if (p1dist2 <= PAD_L2) {VGA_R, VGA_G, VGA_B} = 24'h000000;
            else if (p1dist2 <= PAD_L3) {VGA_R, VGA_G, VGA_B} = 24'hCC1100;
            else                         {VGA_R, VGA_G, VGA_B} = 24'h000000;
         end

         // 9. Paddle 2: 2-level blue radial dome
         if (p2dist2 <= PAD_R2) begin
            if      (p2dist2 <= PAD_L1) {VGA_R, VGA_G, VGA_B} = 24'h0033FF;
            else if (p2dist2 <= PAD_L2) {VGA_R, VGA_G, VGA_B} = 24'h000000;
            else if (p2dist2 <= PAD_L3) {VGA_R, VGA_G, VGA_B} = 24'h0020CC;
            else                         {VGA_R, VGA_G, VGA_B} = 24'h000000;
         end

         // 10. Score display: red for P1, blue for P2
         if (p1_score_on) {VGA_R, VGA_G, VGA_B} = 24'hFF2200;
         if (p2_score_on) {VGA_R, VGA_G, VGA_B} = 24'h0033FF;
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

