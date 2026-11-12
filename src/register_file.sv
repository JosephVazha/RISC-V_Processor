module register_file (
    input logic clk,
    input logic rst,
    input logic wren,

    input logic [4:0] rs1, // source register addresses
    input logic [4:0] rs2,

    input logic [4:0] rd, // destination register
    input logic [31:0] rdv,
    
    output logic [31:0] rs1v, // source register values
    output logic [31:0] rs2v
);

    logic [31:0] registers [31:0]; // stores 32 registers

// read
    always_comb begin
        rs1v = registers[rs1];
        rs2v = registers[rs2];
    end

// write
    always_ff begin
        if (rst) begin
            for (int i=0; i<32; i++) begin
                registers[i] <= 32'b0;
            end
        end
        else if (wren && rd != 5'd0) begin // destination register isn't x0
            registers[rd] <= rdv;
        end
    end

endmodule
