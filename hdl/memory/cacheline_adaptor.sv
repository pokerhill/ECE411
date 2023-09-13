module cacheline_adaptor
(
    input clk,
    input reset_n,
    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,
    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);
logic [255:0] value_read;
logic[1:0] read_mux;
logic[1:0]write_mux;
logic out;
logic read_signal,write_signal;
assign line_o = value_read;
f_s_m fsm(.clk(clk),
.reset_n(reset_n),
.read_i(read_i),
.write_i(write_i),
.resp_i(resp_i),
.read_mux(read_mux),
.write_mux(write_mux),
.read_o(read_o),
.write_o(write_o),
.resp_o(resp_o),
.read_signal(read_signal),
.write_signal(write_signal),
.out (out)
);
always_ff @ (posedge clk) begin
    if(out)begin
        address_o = address_i;
    end
end
always_comb begin
    if(read_signal) begin
    case(read_mux)
        2'b00: begin
            value_read[63:0] = burst_i;
        end
        2'b01: begin
            value_read[127:64] = burst_i;
        end
        2'b10: begin
            value_read[191:128] = burst_i;
        end
        2'b11: begin
            value_read[255:192] = burst_i;
        end
    endcase
    end 
    case(write_mux)
        2'b00: begin
            burst_o = line_i[63:0];
        end
        2'b01: begin
            burst_o =  line_i[127:64];
        end
        2'b10: begin
            burst_o =line_i[191:128];
        end
        2'b11: begin
           burst_o = line_i[255:192] ;
        end
    endcase
end
endmodule : cacheline_adaptor
module f_s_m(
    input clk,
    input reset_n,
    input read_i,
    input write_i,
    input resp_i,
    output logic [1:0] read_mux,
    output logic [1:0] write_mux,
    output logic read_o,
    output logic write_o,
    output logic resp_o,
    output logic write_signal,
    output logic read_signal,
    output logic out    );
enum logic [3:0]{RESET, R1,R2,R3,R4,W1,W2,W3,W4,FINISHED } curr_state, next_state;
always_ff @ (posedge clk)begin
    if (~reset_n)begin
        curr_state<=RESET;
    end
    else begin
        curr_state <=next_state;
    end
end
always_comb begin
    next_state =curr_state;
    case(curr_state)
        RESET: begin
            if(read_i && write_i)begin
                next_state = RESET;
            end
            else if(read_i) begin
                next_state = R1;
            end
           else if(write_i) begin
                next_state = W1;
           end
        end
        R1: begin
            if(resp_i)begin
            next_state = R2;
            end
        end
        R2: begin
            if(resp_i)begin
            next_state = R3;
            end
        end
        R3: begin
            if(resp_i)begin
            next_state = R4;
            end
        end
        R4: begin
            if(resp_i)begin
            next_state = FINISHED;
            end
        end
        W1: begin
            if(resp_i)begin
            next_state = W2;
            end
        end
        W2: begin
            if(resp_i)begin
            next_state = W3;
            end
        end
        W3: begin
            if(resp_i)begin
            next_state = W4;
            end
        end
        W4: begin
            if(resp_i)begin
            next_state = FINISHED;
            end
        end
        FINISHED: begin
            next_state = RESET;
        end
    endcase
end
always_comb begin
    read_o = 1'b0;
    write_o = 1'b0;
    resp_o = 1'b0;
    read_signal =1'b0;
    write_signal = 1'b0;
    out = 1'b0;
    case(curr_state)
        RESET: begin
            read_o = 1'b0;
            write_o = 1'b0;
            resp_o = 1'b0;
            read_signal = 1'b0;
            write_signal = 1'b0;
            out =1'b1;
        end
        R1: begin
            read_o = 1'b1;
           read_mux = 2'b00;
           read_signal = 1'b1;
        end
        R2: begin
            read_o = 1'b1;
           read_mux = 2'b01;
           read_signal = 1'b1;
        end
        R3: begin
            read_o = 1'b1;
           read_mux = 2'b10;
           read_signal = 1'b1;
        end
        R4: begin
            read_o = 1'b1;
            read_mux = 2'b11;
            read_signal = 1'b1;
        end
        W1: begin
            write_o = 1'b1;
            write_mux = 2'b00;
            write_signal = 1'b1;
        end
        W2: begin
            write_o = 1'b1;
            write_mux = 2'b01;
            write_signal = 1'b1;
        end
        W3: begin
            write_o = 1'b1;
            write_mux = 2'b10;
            write_signal = 1'b1;
        end
        W4: begin
            write_o = 1'b1;
            write_mux = 2'b11;
            write_signal =1'b1;
        end
        FINISHED: begin
            resp_o = 1'b1;
        end
    endcase
end
endmodule: f_s_m
