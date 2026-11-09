module decoder(
    input logic clk,
    input logic rst,
    input logic [31:0] instr,

    output logic [6:0] opcode,
    output logic [4:0] rd,
    output logic [2:0] funct3,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [6:0] funct7,
    output logic [31:0] imm_val
);

assign opcode = instr[6:0];
assign rd = instr[11:7];
assign funct3 = instr[14:12];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign funct7 = instr[31:25];

always_comb begin
    unique case (opcode)
        7'b0010011, 7'b0000011: begin // I type instruction (immediate arithmetic, load)
            imm_val = {{20{instr[31]}},instr[31:20]};
        end
        7'b0100011: begin // S type instruction (store)
            imm_val = {{20{instr[31]}},instr[31:25],instr[11:7]};
        end
        7'b1100011: begin // B type instruction (branch)
            imm_val = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8]};
        end
        7'b0110111, 7'b0010111: begin // U type instruction (load upper imn, add upper imm)
        // U type instructions are 0 extended
            imm_val = {instr[31:12],12'b0};
        end
        7'b1101111: begin // J type instruction (jump and link)
            imm_val = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21]};
        end
    endcase
end

endmodule
