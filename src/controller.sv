`include "program_counter.sv"
`include "decoder.sv"
`include "register_file.sv"
`include "alu_control.sv"
`include "alu.sv"

// still needs data memory module (to select what data goes into destination register)
// we should probably make a finite state machine
// fetching instruction, decoding instruction, execute (calculate address),
// write into / read from data memory, write to register

module controller #(
    parameter IMem = "sim/program",
    parameter DMem = "sim/data"
)(
    input logic clk,
    input logic rst
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
    logic [31:0] instr;    

    logic wren = 1'b0;
    logic [31:0] rs1v;
    logic [31:0] rs2v;
    logic [31:0] rdv;

    logic [31:0] op1;
    logic [31:0] op2;
    logic [3:0] alu_ctrl;
    logic [31:0] alu_out;

    localparam FETCH_INSTRUCTION = 3'b0;
    localparam DECODE_INSTRUCTION = 3'b001;
    localparam RESULT = 3'b010;
    localparam STORE_RDV = 3'b011;

    logic [2:0] state = FETCH_INSTRUCTION;
    logic [2:0] next_state;

    logic [31:0] dmem_rdata;
    logic dmem_we;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    
    logic pc_commit;
    logic redirect;
    logic pc_sel;


    logic [31:0] redirect_target;
    logic branch_condtion;
    logic [31:0] branch_target;
            
    memory #(
        .IMEM_INIT_FILE_PREFIX (IMem),
        .DMEM_INIT_FILE_PREFIX (DMem)
    // Set DMEM_INIT_FILE_PREFIX too if your program needs initialized data.
    ) memory_unit (
        .clk           (clk),
        .funct3        (funct3),
        .dmem_wren     (dmem_we),
        .dmem_address  (dmem_addr),
        .dmem_data_in  (dmem_wdata),
        .imem_address  (pc_out),
        .imem_data_out (instr),
        .dmem_data_out (dmem_rdata),
        .reset         (),       // This output is tied high; not for CPU reset.
        .led           (),
        .red           (),
        .green         (),
        .blue          ()
    );


    program_counter u1 (
        // inputs
        .clk            (clk),
        .reset          (rst),
        .PC_in       (pc_out),
        .pc_sel         (pc_sel),
        .branch_target  (branch_target),
        // outputs
        .PC_out         (pc_out)
    );

    decoder u2 (
        // inputs
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
        .op1        (op1),
        .op2        (op2),
        .alu_ctrl   (alu_ctrl),
        // outputs
        .alu_out    (alu_out)
    );

    // main controller state machine
    always_comb begin
        next_state = state;
        wren       = 1'b0;
        sel_op1    = 1'b0;
        sel_op2    = 1'b0;
        rd_sel     = 2'b00;
        
        unique case (state)
            FETCH_INSTRUCTION: begin
                next_state = DECODE_INSTRUCTION;
            end

            DECODE_INSTRUCTION: begin
                unique case (opcode)
                    // R type instruction
                    7'b0110011: begin
                        next_state = RESULT;
                        sel_op1 = 1'b0;
                        sel_op2 = 1'b0;
                    end
                    // I type instruction
                    7'b0010011: begin
                        next_state = RESULT;
                        sel_op1 = 1'b0;
                        sel_op2 = 1'b1;
                    end
                    // S type instruction
                    7'b0100011: begin
                        // next_state = ;
                        sel_op1 = 1'b0;
                        sel_op2 = 1'b1;
                    end
                    // B type instruction
                    7'b1100011: begin
                       unique case (funct3)
                            3'b000: branch_condition = (rs1v == rs2v); // BEQ
                            3'b001: branch_condition = (rs1v != rs2v); // BNE
                            3'b100: branch_condition = ($signed(rs1v) < $signed(rs2v)); // BLT
                            3'b101: branch_condition = ($signed(rs1v) >= $signed(rs2v)); // BGE
                            3'b110: branch_condition = (rs1v < rs2v);  // BLTU
                            3'b111: branch_condition = (rs1v >= rs2v); // BGEU
                            default: branch_condition = 1'b0;
                        endcase
                         next_state = RESULT;
                    end
                    // LUI
                    7'b0110111: begin
                        next_state = RESULT;
                    end
                    // AUIPC, J type instruction
                    7'b0010111, 7'b1101111: begin
                        next_state = RESULT;
                        sel_op1 = 1'b1;
                        sel_op2 = 1'b1;
                    end
                endcase
            end

            RESULT: begin
                unique case (opcode)
                    // R and I type instructions, AUIPC
                    7'b0110011, 7'b0010011, 7'b0010111: begin
                        rd_sel = 2'b00;
                        next_state = STORE_RDV;
                    end
                    // LUI
                    7'b0110111: begin
                        rd_sel = 2'b11;
                        next_state = STORE_RDV;
                    end
                    // J type instruction
                    7'b1101111: begin
                        rd_sel = 2'b10;
                        next_state = STORE_RDV;
                    end
                endcase
            end

            STORE_RDV: begin
                wren = 1'b1;
                next_state = FETCH_INSTRUCTION;

                // J type instruction
                if (opcode == 7'b1101111) begin
                    pc_in = alu_out;
                end
            end
            // default: next_state = ;
        endcase
    end

    // clocking FSM
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= FETCH_INSTRUCTION;
        end else begin
            state <= next_state;
        end
    end

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
