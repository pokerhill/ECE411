
module regfile
(
    input clk,
    input rst,
    input load,
    input [31:0] in,
    input [4:0] src_a, src_b, dest,
    output logic [31:0] reg_a, reg_b
);

//logic [31:0] data [32] /* synthesis ramstyle = "logic" */ = '{default:'0};
logic [31:0] data [32];

always_ff @(posedge clk)
begin
    if (rst)
    begin
        for (int i=0; i<32; i=i+1) begin
            data[i] <= '0;
        end
    end
    else if (load && dest)
    begin
        data[dest] <= in;
    end
end

always_comb
begin
   if (src_a == dest && dest != 0) begin
        reg_a = in;
    end
	else begin
        reg_a = src_a ? data[src_a] : 0;
	end
    
	if(src_b == dest && dest != 0) begin
        reg_b = in;
    end
	else begin
        reg_b = src_b ? data[src_b] : 0;
	end

    //reg_a = src_a ? data[src_a] : 0;
    //reg_b = src_b ? data[src_b] : 0;
end

endmodule : regfile
