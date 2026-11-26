//Instruction Memory Module

module i_mem  (
   input logic clk,
   input logic rst,
   input logic [31:0] Addr
   output logic [31:0] ir
   
);

   logic [31:0] mem [255:0]; // 256 x 32 bit mem
   
   //Loading isnt mem from the memh file obj code file from linker scirpt
   initial begin 
      $readmemh("sim/program.memh", mem);
   end
   
   ir <= mem[Addr[9:2]];
   
endmodule

module instruction_register (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instruction_in,
    output logic [31:0] ir
);
    always_ff @(posedge clk or posedge rst) begin
            ir <= instruction_in;
    end
endmodule
