
module program_counter (
   input logic    clk,
   input logic    reset,
   
   input logic [31:0]  PC_in,
   output logic [31:0]  PC_out
);

    // Color change
always_ff @(posedge clk or posedge reset) begin
   if(reset)
      PC_out <= 32'b00;
   else 
      PC_out <= PC_in;
   end
endmodule

module nextAdrr (
   input [31:0] fromPC;
   output [31:0] nextPC;
   
   //Instructions are 4 bytes long
   assign NextPc = 4 + fromPC;
endmodule

module InstructionMem(

   input  logic [31:0] read_addr;
   output logic [31:0] instr_out
);

   logic[31:0] I_Mem[63:0] 
   assign instr_out = I_mem[read_addr[7:2]];

endmodule



