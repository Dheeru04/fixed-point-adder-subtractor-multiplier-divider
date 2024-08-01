module qmult #(
    parameter Q = 15,
    parameter N = 32
    )
    (
    input [N-1:0] i_multiplicand,
    input [N-1:0] i_multiplier,
    output [N-1:0] o_result,
    output reg ovr
    );
    
    reg [2*N-1:0] r_result;
    reg [N-1:0] r_RetVal;

    assign o_result = r_RetVal;

    always @(i_multiplicand, i_multiplier) begin
        // Perform the multiplication
        r_result = i_multiplicand[N-2:0] * i_multiplier[N-2:0];
        
        // Determine the sign of the result
        r_RetVal[N-1] = i_multiplicand[N-1] ^ i_multiplier[N-1];
        
        // Extract the fixed-point result
        r_RetVal[N-2:0] = r_result[N-2+Q:Q];
        
        // Check for overflow
        if (r_result[2*N-2:N-1+Q] != 0)
            ovr = 1;
        else
            ovr = 0;
    end
endmodule
module Test_mult;

    // Inputs
    reg [31:0] i_multiplicand;
    reg [31:0] i_multiplier;

    // Outputs
    wire [31:0] o_result;
    wire ovr;
    
    // Instantiate the Unit Under Test (UUT)
    qmult #(15,32) uut (
        .i_multiplicand(i_multiplicand), 
        .i_multiplier(i_multiplier), 
        .o_result(o_result),
        .ovr(ovr)
    );

    initial begin
        // Monitor the results
        $monitor("Time: %0d, Multiplicand: %b, Multiplier: %b, Result: %b, Overflow: %b", $time, i_multiplicand, i_multiplier, o_result, ovr);        
        
        // Initialize Inputs
        i_multiplicand = 32'b00000000000110010010000111111011; // pi = 3.141592
        i_multiplier = 32'b00000000000000000000000000000001;   // 1
        
        // Wait 100 ns for global reset to finish
        #100;
        
        // Apply a sequence of test values
        #10 i_multiplier = 32'b00000000000000000000000000000010; // 2
        #10 i_multiplier = 32'b00000000000000000000000000000100; // 4
        #10 i_multiplier = 32'b10000000000000000000000000000001; // -1
        #10 i_multiplier = 32'b10000000000000000000000000000010; // -2
        #10 i_multiplier = 32'b00000000000000000000000000000000; // 0
        
        // Finish simulation
        #10 $finish;
    end
      
endmodule
