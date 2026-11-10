module alu (
    input logic clk,
    input logic rst,

    input logic [31:0] op1,
    input logic [31:0] op2,
    input logic [3:0] alu_ctrl, // should be from controller

    output logic [31:0] alu_out
);

    always_comb begin
        unique case (alu_ctrl)
            4'b0000: // add
                alu_out = op1 + op2;
            4'b0001: // sub
                alu_out = op1 - op2;
            4'b0010: // sll
                alu_out = op1 << op2[4:0]; // shifts op1 by amount specified in lower 5 bits of op2
            4'b0011: // srl
                alu_out = op1 >> op2[4:0];
            4'b0100: // sra
                alu_out = op1 >>> op2[4:0];
            4'b0101: // slt
                alu_out = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;
            4'b0110: // sltu
                alu_out = (op1 < op2) ? 32'b1 : 32'b0;
            4'b0111: // xor
                alu_out = op1 ^ op2;
            4'b1000: // or
                alu_out = op1 | op2;
            4'b1001: // and
                alu_out = op1 & op2;
        endcase
    end

endmodule
