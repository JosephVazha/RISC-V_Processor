module alu_control(
    input logic [5:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    output logic [3:0] alu_ctrl
);

    always_comb begin
        // add, addi
        if ((opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0000000)
        || (opcode == 7'b0010011 && funct3 == 3'b000)) begin
            alu_control = 4'b0000;
        end
        // sub
        if (opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0100000) begin
            alu_control = 4'b0001;
        end
        // sll, slli
        if ((opcode == 7'b0110011 && funct3 == 3'b001)
        || (opcode == 7'b0010011 && funct3 == 3'b001)) begin
            alu_control = 4'b0010;
        end
        // srl, srli
        if ((opcode == 7'b0110011 && funct3 == 3'b101 && funct7 == 7'b0000000)
        || (opcode == 7'b0010011 && funct3 == 3'b101) && funct7 == 7'b0000000) begin
            alu_control = 4'b0011;
        end
        // sra, srai
        if ((opcode == 7'b0110011 && funct3 == 3'b101 && funct7 == 7'b0100000)
        || (opcode == 7'b0010011 && funct3 == 3'b101) && funct7 == 7'b0100000) begin
            alu_control = 4'b0100;
        end
        // slt, slti
        if ((opcode == 7'b0110011 && funct3 == 3'b010)
        || (opcode == 7'b0010011 && funct3 == 3'b010)) begin
            alu_control = 4'b0101;
        end
        // sltu, sltiu
        if ((opcode == 7'b0110011 && funct3 == 3'b011)
        || (opcode == 7'b0010011 && funct3 == 3'b011)) begin
            alu_control = 4'b0110;
        end
        // xor, xori
        if ((opcode == 7'b0110011 && funct3 == 3'b100)
        || (opcode == 7'b0010011 && funct3 == 3'b100)) begin
            alu_control = 4'b0111;
        end
        // or, ori
        if ((opcode == 7'b0110011 && funct3 == 3'b110)
        || (opcode == 7'b0010011 && funct3 == 3'b110)) begin
            alu_control = 4'b1000;
        end
        // and, andi
        if ((opcode == 7'b0110011 && funct3 == 3'b111)
        || (opcode == 7'b0010011 && funct3 == 3'b111)) begin
            alu_control = 4'b1001;
        end
    end

endmodule
