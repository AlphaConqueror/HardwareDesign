module MealyPattern(
	input        clock,
	input        i,
	output [1:0] o
);

reg [1:0] current;
reg [1:0] out;

always @(posedge clock)
    begin
        out <= 2'b00;

        if ( i == 1'b0 && current == 2'b01 ) // 001 -> ouput 10
            out <= 2'b10;

        if ( i == 1'b1 && current == 2'b11 ) // 111 -> ouput 01
            out <= 2'b01;

        current[0] = current[1]; //current updaten
        current[1] <= i;
    end

    assign o = out;

endmodule

module MealyPatternTestbench();

reg clock, in;
wire [1:0] out;
integer z;
reg [9:0] data;
reg [19:0] correct_out;

reg test_passed;

MealyPattern machine(.clock(clock), .i(in), .o(out));

initial
    begin
        clock = 0;
        data = 10'b1110011001; //output is 00, 00, 10, 00, 00, 00, 10, 00, 00, 01
        correct_out = 20'b01000010000000100000;
        test_passed = 1'b1;

        for(z = 0; z <= 9; z = z + 1)
        begin
            #2 clock = 1;
            in = data[z];
            #2 clock = 0;
            test_passed <= test_passed & (correct_out[2 * z] == out[0] & correct_out[2 * z + 1] == out[1]);


            $display( "Input = ", in, " Output = %2b", out);
        end

        if ( test_passed )
            $display("Test passed");
        else
            $display("Not passed");
    end

endmodule

