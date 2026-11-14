module processor_top (
   input    logic          clk,
   input    logic          reset,
   input    logic          branch_taken,
   input    logic [31:0]   branch_target,
   output   logic [31:0]   pc,
   output   logic [31:0]   inctruction
);
      
   logic [31:0] rs1v, rs2v;
   logic [4:0] rs1, rs2, rd;
   logic [6:0] opcode, funct7;
   logic [2:0] funct3;
   
   logic wr_en;
   logic
   
   program_counter pc (
      .clk           (clk),
      .reset         (reset),
      .pc_sel  (branch_taken),
      .PC_in   (branch_target),
      ,PC_out  (PC_out)
   );

   memory #(
      .Addr    (PC_out),
      .ir      (instruction)
   ) memory_unit (
      .clk           (clk),
      .func3         (3'b000),
      .dmem_wren     (1'b0),
      .dmem_address  (32'b0),
      .dmem_data_in  (32'b0),
      .imem_address  (pc),
      .imem_data_out (instruction),
      .dmem_data_out (unuse)
   )
   
   register_file register_file (
      .clk            (clk),
      .rst            (reset),
      .wren           (wr_en),

      .rs1            (rs1),
      .rs2            (rs2),
      .rd             (rd),
      .rdv
      .rs1v           (rs1v),
      .rs2v           (rs2v)
   )
   
   alu_control alu_control_unit (
      .opcode        (opcode),
      .funct3        (funct3),
      .funct7        (funct7),
      .alu_control   (alu_ctrl),
      .alu_out       (alu_result)
   );
endmodule
