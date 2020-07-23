module Division(
	input         clock,
	input         start,
	input  [31:0] a,
	input  [31:0] b,
	output [31:0] q,
	output [31:0] r
);

reg [31:0] q_out;
reg [31:0] r_out;
reg [7:0] s;
reg t = 1'b0;
integer i;

always @(posedge clock)
begin
    if({start, t} == 2'b01)
        begin
            s = 2 * r_out + a[i];

            if(s < b)
                begin
                    q_out[i] = 0;
                    r_out = s;
                end
            else
            begin
                q_out[i] = 1;
                r_out = s - b;
                end
            if (i > 0)
                i = i - 1;
            else
                t = 1'b0;
        end
    else
        begin
            q_out = 32'd0;
            r_out = 32'd0;
            i = 31;
            t = 1'b1;
        end
end

assign q = q_out;
assign r = r_out;

endmodule

