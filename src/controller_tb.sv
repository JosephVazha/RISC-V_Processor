
module controller_tb;

    logic clk;
    logic rst;

    // Instantiate CPU
    controller dut (
        .clk (clk),
        .rst (rst)
    );

    // 100 MHz clock (10 ns period)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        // Reset CPU
        rst = 1'b1;

        // ADD x3, x1, x2
        // rd=x3, rs1=x1, rs2=x2


        repeat (2) @(posedge clk);
        #1;
        $display("PC: %h | Instruction: %h", dut.pc_out, dut.instr);
        
        @(negedge clk);

        rst = 1'b0;

        // Initialize source registers
        dut.u3.registers[1] = 32'd10;
        dut.u3.registers[2] = 32'd20;

        // Wait for the end
        wait (dut.state == 3'b011);

        // Register file writes on the next rising edge
        @(posedge clk);
        #1;

        // Check result
        if (dut.u3.registers[3] !== 32'd30) begin
            $error("ADD FAILED: x3 = %0d, expected 30",
                   dut.u3.registers[3]);
            $fatal;
        end

        // Check PC increment
        if (dut.pc_out !== 32'h00001004) begin
            $error("PC FAILED: PC = %h, expected 00001004",
                   dut.pc_out);
            $fatal;
        end

        $display("ADD PASSED: x3 = %0d", dut.u3.registers[3]);
        $display("PC PASSED: PC = %h", dut.pc_out);

        $display("All tests passed!");
        $finish;
    end

    // Timeout in case the FSM gets stuck
    initial begin
        #500;
        $fatal(1, "TESTBENCH TIMEOUT");
    end

endmodule

