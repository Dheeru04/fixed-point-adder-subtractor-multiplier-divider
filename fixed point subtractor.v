module qsubtract #(
    //Parameterized values
    parameter Q = 15,
    parameter N = 32
    )
    (
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
    );

reg [N-1:0] res;

assign c = res;

always @(a, b) begin
    // both negative or both positive
    if(a[N-1] == b[N-1]) begin
        res[N-2:0] = a[N-2:0] - b[N-2:0];
        res[N-1] = a[N-1];
    end
    // one of them is negative
    else if(a[N-1] == 0 && b[N-1] == 1) begin
        if(a[N-2:0] > b[N-2:0]) begin
            res[N-2:0] = a[N-2:0] + b[N-2:0];
            res[N-1] = 0;
        end else begin
            res[N-2:0] = b[N-2:0] + a[N-2:0];
            if (res[N-2:0] == 0)
                res[N-1] = 0;
            else
                res[N-1] = 1;
        end
    end else begin
        if(a[N-2:0] > b[N-2:0]) begin
            res[N-2:0] = a[N-2:0] + b[N-2:0];
            if (res[N-2:0] == 0)
                res[N-1] = 0;
            else
                res[N-1] = 1;
        end else begin
            res[N-2:0] = b[N-2:0] + a[N-2:0];
            res[N-1] = 0;
        end
    end
end
endmodule

module Test_subtract;

    // Inputs
    reg [31:0] a;
    reg [31:0] b;

    // Outputs
    wire [31:0] c;

    // Instantiate the Unit Under Test (UUT)
    qsubtract #(15, 32) uut (
        .a(a), 
        .b(b), 
        .c(c)
    );

    // Internal signals for monitoring
    wire [30:0] a_in;
    wire [30:0] b_in;
    wire [30:0] c_out;
    wire a_sign;
    wire b_sign;
    wire c_sign;

    assign a_in = a[30:0];
    assign b_in = b[30:0];
    assign c_out = c[30:0];
    assign a_sign = a[31];
    assign b_sign = b[31];
    assign c_sign = c[31];

    initial begin
        // Initialize Inputs
        $monitor("Time = %0d, a = %0d (%0d), b = %0d (%0d), c = %0d (%0d)", $time, a_in, a_sign, b_in, b_sign, c_out, c_sign);

        // Test case 1: both positive
        a = 32'h00000010; // 16
        b = 32'h00000008; // 8
        #10;
        
        // Test case 2: both negative
        a = 32'h80000010; // -16
        b = 32'h80000008; // -8
        #10;
        
        // Test case 3: a positive, b negative
        a = 32'h00000010; // 16
        b = 32'h80000008; // -8
        #10;
        
        // Test case 4: a negative, b positive
        a = 32'h80000010; // -16
        b = 32'h00000008; // 8
        #10;
        
        // Test case 5: a positive, b zero
        a = 32'h00000010; // 16
        b = 32'h00000000; // 0
        #10;
        
        // Test case 6: a zero, b negative
        a = 32'h00000000; // 0
        b = 32'h80000008; // -8
        #10;
        
        // Test case 7: both zero
        a = 32'h00000000; // 0
        b = 32'h00000000; // 0
        #10;

        // Test case 8: edge case with maximum positive and maximum negative values
        a = 32'h7FFFFFFF; // Max positive
        b = 32'h80000000; // Max negative
        #10;

        // Test case 9: edge case with minimum positive and minimum negative values
        a = 32'h00000001; // Min positive
        b = 32'hFFFFFFFF; // Min negative (-1)
        #10;
        
        // Finish simulation
        $finish;
    end
      
endmodule
