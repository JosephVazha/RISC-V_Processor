
module program_counter (
   input logic    clk,
   input logic    reset,
   input logic    pc_sel,
   input logic    pc_en,
   input logic [31:0] branch_target,   


   input logic [31:0]  PC_in,
   output logic [31:0]  PC_out
);


always_ff @(posedge clk or posedge reset) begin
   if(reset)
      PC_out <= 32'h1000;
   else if (pc_sel)
      PC_out <= branch_target;
   else
      PC_out <= PC_in + 32'd4;
   end
endmodule



