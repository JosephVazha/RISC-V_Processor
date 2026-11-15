module top #(
   parameter IMem = "sim/program"
   ) (
   input logic clk,
   input logic reset
   );
   logic          branch_taken;
   logic [31:0]   branch_target;
   logic [31:0]   pc;
   logic [31:0]   instruction;

      
   logic [31:0] rs1v, rs2v, rdv;
   logic [4:0] rs1, rs2, rd;
   logic [6:0] opcode, funct7;
   logic [2:0] funct3, rd_sel;
   logic sel_op1, sel_op2;
   
   logic wr_en;

   
   program_counter program_counter (
      .clk              (clk),
      .reset            (reset),
      .pc_sel           (branch_taken),
      .branch_target    (branch_target),
      .PC_in   (pc),
      .PC_out  (pc)
   );

   memory #(
      .IMEM_INIT_FILE_PREFIX (IMem)
   ) memory_unit (
      .clk           (clk),
      .funct3         (3'b000),
      .dmem_wren     (1'b0),
      .dmem_address  (32'b0),
      .dmem_data_in  (32'b0),
      .imem_address  (pc),
      .imem_data_out (instruction),
      .dmem_data_out (unuse),
      .reset         (),
      .led           (),
      .red           (),
      .green         (),
      .blue          ()
   );

   decoder decoder (
      .clk           (clk),
      .rst           (reset),
      .instr         (instruction),
      .opcode        (opcode),
      .rd            (rd),
      .funct3        (funct3),
      .rs1           (rs1),
      .rs2           (rs2),
      .funct7        (funct7),
      .imm_val       (imm_val)
   );
   
   register_file register_file (
      .clk           (clk),
      .rst           (reset),
      .wren          (wr_en),

      .rs1           (rs1),
      .rs2           (rs2),
      .rd            (rd),
      .rdv           (rdv),
      .rs1v           (rs1v),
      .rs2v           (rs2v)
   );
   
   alu_control alu_control_unit (
      .opcode        (opcode),
      .funct3        (funct3),
      .funct7        (funct7),
      .alu_control   (alu_ctrl),
   );
endmodule
