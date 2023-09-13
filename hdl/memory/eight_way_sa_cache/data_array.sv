/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER.
A special register array specifically for your
data arrays. This module supports a write mask to
help you update the values in the array. */

module modular_data_array #(
    parameter s_offset = 5,
    parameter s_index = 3
)
(
    clk,
    read,
    write_en,
    rindex,
    windex,
    datain,
    dataout
);

localparam s_mask   = 2**s_offset;
localparam s_line   = 8*s_mask;
localparam num_sets = 2**s_index;

input clk;
input read;
//input [s_mask-1:0] write_en;
input write_en;
input [s_index-1:0] rindex;
input [s_index-1:0] windex;
input [255:0] datain;
output logic [255:0] dataout;

logic [255:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
logic [255:0] _dataout;
assign dataout = _dataout;

always_ff @(posedge clk)
begin
    if (read)
        for (int i = 0; i < s_mask; i++)
            _dataout[255:0] <= (write_en & (rindex == windex)) ?
                                  datain[255:0] : data[rindex][255:0];

    for (int i = 0; i < s_mask; i++)
    begin
        data[windex][255:0] <= write_en ? datain[255:0] :
                                                data[windex][255:0];
    end
end

endmodule : modular_data_array
