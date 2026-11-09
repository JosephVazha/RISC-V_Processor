`include "program_counter.sv"
`include "decoder.sv"
`include "register_file.sv"
`include "alu_control.sv"
`include "alu.sv"

// still needs data memory module (to select what data goes into destination register)
// we should probably make a finite state machine
// fetching instruction, decoding instruction, execute (calculate address),
// write into / read from data memory, write to register

module controller (
    input logic clk,
    input logic rst,
    input logic [31:0] instr
);

    logic sel_op1;
    logic sel_op2;
    logic [1:0] rd_sel;

    logic [31:0] pc_in = 32'b0;
    logic [31:0] pc_out;

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] funct7;
    logic [31:0] imm_val;

    logic wren = 1'b0;
    logic [31:0] rs1v;
    logic [31:0] rs2v;
    logic [31:0] rdv;

    logic [31:0] op1;
    logic [31:0] op2;
    logic [3:0] alu_ctrl;
    logic [31:0] alu_out;

    program_counter u1 (
        // inputs
        .clk        (clk),
        .reset      (rst),
        // outputs
        .PC_in      (pc_in),
        .PC_out     (pc_out)
    );

    decoder u2 (
        // inputs
        .clk        (clk),
        .rst        (rst),
        .instr      (instr),
        // outputs
        .opcode     (opcode),
        .rd         (rd),
        .funct3     (funct3),
        .rs1        (rs1),
        .rs2        (rs2),
        .funct7     (funct7),
        .imm_val    (imm_val)
    );

    register_file u3 (
        // inputs
        .clk        (clk),
        .rst        (rst),
        .wren       (wren),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .rdv        (rdv),
        // outputs
        .rs1v       (rs1v),
        .rs2v       (rs2v)
    );

    alu_control u4 (
        // inputs
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        // outputs
        .alu_ctrl   (alu_ctrl)
    );

    alu u5 (
        // inputs
        .clk        (clk),
        .rst        (rst),
        .op1        (op1),
        .op2        (op2),
        .alu_ctrl   (alu_ctrl),
        // outputs
        .alu_out    (alu_out)
    );

    // sel_op1
    always_comb begin
        if (sel_op1) begin
            op1 = pc_out;
        end
        else begin
            op1 = rs1v;
        end
    end

    // sel_op2
    always_comb begin
        if (sel_op2) begin
            op2 = imm_val;
        end
        else begin
            op2 = rs2v;
        end
    end

    // choose what to write to destination register
    always_comb begin
        unique case (rd_sel)
            2'b00:
                rdv = alu_out;
            2'b01:
                rdv = dmem_out;
            2'b10:
                rdv = pc_out;
            2'b11:
                rdv = imm_val;
        endcase
    end

endmodule
