/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */

module modular_cache_control (
    input clk,
    input rst, 
    input mem_resp_cache,
    input logic read,
    input logic write,

   input logic hit1,
   input logic hit2,
   input logic hit3,
   input logic hit4,
   input logic hit5,
   input logic hit6,
   input logic hit7,
   input logic hit8,

    input logic Dirty1_out,
    input logic Dirty2_out,
    input logic Dirty3_out,
    input logic Dirty4_out,
    input logic Dirty5_out,
    input logic Dirty6_out,
    input logic Dirty7_out,
    input logic Dirty8_out,

    input logic[6:0]LRU_out,
    
    output logic [2:0] which_tag,
    output logic new_address_sel,

    output logic valid_1_in,
    output logic valid_2_in,
    output logic valid_3_in,
    output logic valid_4_in,
    output logic valid_5_in,
    output logic valid_6_in,
    output logic valid_7_in,
    output logic valid_8_in,


    output logic [6:0] LRU_in,

    output logic Dirty1_load,
    output logic Dirty2_load,
    output logic Dirty3_load,
    output logic Dirty4_load,
    output logic Dirty5_load,
    output logic Dirty6_load,
    output logic Dirty7_load,
    output logic Dirty8_load,
    
    output logic LRU_load,

    output logic tag_array1_load,
    output logic tag_array2_load,
    output logic tag_array3_load,
    output logic tag_array4_load,
    output logic tag_array5_load,
    output logic tag_array6_load,
    output logic tag_array7_load,
    output logic tag_array8_load,

    output logic read_data_array_1,
    output logic read_data_array_2,
    output logic read_data_array_3,
    output logic read_data_array_4,
    output logic read_data_array_5,
    output logic read_data_array_6,
    output logic read_data_array_7,
    output logic read_data_array_8,

    output logic valid_1_load,
    output logic valid_2_load,
    output logic valid_3_load,
    output logic valid_4_load,
    output logic valid_5_load,
    output logic valid_6_load,
    output logic valid_7_load,
    output logic valid_8_load,

    output logic write_sel_way_1,
    output logic write_sel_way_2,
    output logic write_sel_way_3,
    output logic write_sel_way_4,
    output logic write_sel_way_5,
    output logic write_sel_way_6,
    output logic write_sel_way_7,
    output logic write_sel_way_8,

    output logic write_read_sel_1,
    output logic write_read_sel_2,
    output logic write_read_sel_3,
    output logic write_read_sel_4,
    output logic write_read_sel_5,
    output logic write_read_sel_6,
    output logic write_read_sel_7,
    output logic write_read_sel_8,

    output logic read_dirty_array_1,
    output logic read_dirty_array_2,
    output logic read_dirty_array_3,
    output logic read_dirty_array_4,
    output logic read_dirty_array_5,
    output logic read_dirty_array_6,
    output logic read_dirty_array_7,
    output logic read_dirty_array_8,

    output logic LRU_read,

    output logic read_tag_array_1,
    output logic read_tag_array_2,
    output logic read_tag_array_3,
    output logic read_tag_array_4,
    output logic read_tag_array_5,
    output logic read_tag_array_6,
    output logic read_tag_array_7,
    output logic read_tag_array_8,

    output logic valid_1_in_read,
    output logic valid_2_in_read,
    output logic valid_3_in_read,
    output logic valid_4_in_read,
    output logic valid_5_in_read,
    output logic valid_6_in_read,
    output logic valid_7_in_read,
    output logic valid_8_in_read,


    output logic[2:0] cacheline_sel,


    output logic Dirty1_in,
    output logic Dirty2_in,
    output logic Dirty3_in,
    output logic Dirty4_in,
    output logic Dirty5_in,
    output logic Dirty6_in,
    output logic Dirty7_in,
    output logic Dirty8_in,

    output logic pmem_read,
    output logic pmem_write,
    output logic done
);
logic [2:0] replace_which_way; 
logic hit_check;
logic dirty;
logic [6:0] temp_PLRU;
function void load_PLRU(logic h1,logic h2, logic h3, logic h4, logic h5, logic h6, logic h7, logic h8);
    LRU_in = LRU_out; 
    if(h1) begin
        LRU_in[3] = 1'b0;
        LRU_in[1] = 1'b0;
        LRU_in[0] = 1'b0;
    end
    else if(h2) begin
        LRU_in[3] = 1'b0;
        LRU_in[1] = 1'b0;
        LRU_in[0] = 1'b1;
    end
    else if(h3) begin
        LRU_in[3] = 1'b0;
        LRU_in[1] = 1'b1;
        LRU_in[2] = 1'b0;
    end
    else if(h4) begin
        LRU_in[3] = 1'b0;
        LRU_in[1] = 1'b1;
        LRU_in[2] = 1'b1;
    end
    else if(h5) begin
        LRU_in[3] = 1'b1;
        LRU_in[5] = 1'b0;
        LRU_in[4] = 1'b0;
    end
    else if(h6) begin
        LRU_in[3] = 1'b1;
        LRU_in[5] = 1'b0;
        LRU_in[4] = 1'b1;
    end
    else if(h7) begin
        LRU_in[3] = 1'b1;
        LRU_in[5] = 1'b1;
        LRU_in[6] = 1'b0;
    end
    else if(h8) begin
        LRU_in[3] = 1'b1;
        LRU_in[5] = 1'b1;
        LRU_in[6] = 1'b1;
    end
endfunction
function void which_replace(logic [6:0] PLRU);
    temp_PLRU = ~PLRU; 
    if (temp_PLRU[3]) begin
        if (~temp_PLRU[5]) begin
            if (~temp_PLRU[4]) begin
                replace_which_way = 3'b100;
                which_tag = 3'b100;
            end
            else  begin // made else instead of else if (temp_PLRU[4]) bc of don't cares
                replace_which_way = 3'b101;
                which_tag = 3'b101;
            end
        end
        else begin // made else instead of else if (temp_PLRU[5]) bc of don't cares
            if (~temp_PLRU[6]) begin
                replace_which_way =  3'b110;
                which_tag = 3'b110;
            end
            else begin
                replace_which_way = 3'b111;
                which_tag = 3'b111;
            end
        end
    end
    else begin
        if (~temp_PLRU[1]) begin
            if (~temp_PLRU[0]) begin
                replace_which_way = 3'b000;
                which_tag = 3'b000;
            end
            else  begin // made else instead of else if (temp_PLRU[4]) bc of don't cares
                replace_which_way = 3'b001;
                which_tag = 3'b001;
            end
        end
        else begin // made else instead of else if (temp_PLRU[5]) bc of don't cares
            if (~temp_PLRU[2]) begin
                replace_which_way =  3'b010;
                which_tag = 3'b010;
            end
            else begin
                replace_which_way = 3'b011;
                which_tag = 3'b011;
            end
        end
    end

endfunction

function void which_dirty ( logic [2:0] replace, logic d1, logic d2,  logic d3, logic d4,logic d5, logic d6,logic d7,logic d8);
    case (replace)
    3'b000: dirty = d1; 
    3'b001: dirty = d2;
    3'b010: dirty = d3;
    3'b011: dirty = d4;
    3'b100: dirty = d5; 
    3'b101: dirty = d6;
    3'b110: dirty = d7;
    3'b111: dirty = d8;
    endcase
endfunction

// function void which_hit (logic hit_check, logic d1, logic d2, logic d3, logic d4, logic d5, logic d6, logic d7, logic d8 );
//     if (~hit_check)
//         return;
//     else begin
//         if (h1) begin
//             dirty = d1;
//         end
//         else if (h2) begin
//             dirty = d2;
//         end
//         else if (h3) begin
//             dirty = d3;
//         end
//         else if (h4) begin
//             dirty = d4;
//         end
//         else if (h5) begin
//             dirty = d5;
//         end
//         else if (h6) begin
//             dirty = d6;
//         end
//         else if (h7) begin
//             dirty = d7;
//         end
//         else if (h8) begin
//             dirty = d8;
//         end
//     end
// endfunction
// assign dirty = LRU_out ? (Dirty1_out ): (Dirty2_out ); // need to use psudeo LRU Algo now
// assign which_tag = ~LRU_out; // need to use psudeo lru algo now
function void set_defaults();
    cacheline_sel = 3'b0;

    valid_1_in = 1'b0;
    valid_2_in = 1'b0;
    valid_3_in = 1'b0;
    valid_4_in = 1'b0;
    valid_5_in = 1'b0;
    valid_6_in = 1'b0;
    valid_7_in = 1'b0;
    valid_8_in = 1'b0;

    LRU_in = 7'b0;

    Dirty1_load = 1'b0;
    Dirty2_load = 1'b0;
    Dirty3_load = 1'b0;
    Dirty4_load = 1'b0;
    Dirty5_load = 1'b0;
    Dirty6_load = 1'b0;
    Dirty7_load = 1'b0;
    Dirty8_load = 1'b0;

    LRU_load = 1'b0;

    tag_array1_load = 1'b0; 
    tag_array2_load = 1'b0; 
    tag_array3_load = 1'b0; 
    tag_array4_load = 1'b0; 
    tag_array5_load = 1'b0; 
    tag_array6_load = 1'b0; 
    tag_array7_load = 1'b0; 
    tag_array8_load = 1'b0; 

    valid_1_load = 1'b0;
    valid_2_load = 1'b0;
    valid_3_load = 1'b0;
    valid_4_load = 1'b0;
    valid_5_load = 1'b0;
    valid_6_load = 1'b0;
    valid_7_load = 1'b0;
    valid_8_load = 1'b0;

    write_sel_way_1 = 1'b0;
    write_sel_way_2 = 1'b0;
    write_sel_way_3 = 1'b0;
    write_sel_way_4 = 1'b0;
    write_sel_way_5 = 1'b0;
    write_sel_way_6 = 1'b0;
    write_sel_way_7 = 1'b0;
    write_sel_way_8 = 1'b0;
    
   read_dirty_array_1 = 1'b1; 
   read_dirty_array_2 = 1'b1; 
   read_dirty_array_3 = 1'b1; 
   read_dirty_array_4 = 1'b1; 
   read_dirty_array_5 = 1'b1; 
   read_dirty_array_6 = 1'b1; 
   read_dirty_array_7 = 1'b1; 
   read_dirty_array_8 = 1'b1; 

    LRU_read = 1'b1;

    read_tag_array_1 = 1'b1;
    read_tag_array_2 = 1'b1;
    read_tag_array_3 = 1'b1;
    read_tag_array_4 = 1'b1;
    read_tag_array_5 = 1'b1;
    read_tag_array_6 = 1'b1;
    read_tag_array_7 = 1'b1;
    read_tag_array_8 = 1'b1;

    read_data_array_1 = 1'b1;
    read_data_array_2 = 1'b1;
    read_data_array_3 = 1'b1;
    read_data_array_4 = 1'b1;
    read_data_array_5 = 1'b1;
    read_data_array_6 = 1'b1;
    read_data_array_7 = 1'b1;
    read_data_array_8 = 1'b1;

    valid_1_in_read = 1'b1;
    valid_2_in_read = 1'b1;
    valid_3_in_read = 1'b1;
    valid_4_in_read = 1'b1;
    valid_5_in_read = 1'b1;
    valid_6_in_read = 1'b1;
    valid_7_in_read = 1'b1;
    valid_8_in_read = 1'b1;

    pmem_read = 1'b0;
    pmem_write = 1'b0;
    new_address_sel=1'b0;
    done = 1'b0;

   write_read_sel_1 = 1'b0;
   write_read_sel_2 = 1'b0;
   write_read_sel_3 = 1'b0;
   write_read_sel_4 = 1'b0;
   write_read_sel_5 = 1'b0;
   write_read_sel_6 = 1'b0;
   write_read_sel_7 = 1'b0;
   write_read_sel_8 = 1'b0;

endfunction


assign hit_check = (hit1 || hit2 || hit3 || hit4 || hit5 || hit6 || hit7 || hit8);

enum int unsigned{
    stall, 
    hit, 
    miss_clean, 
    miss_dirty
} curr_state, next_state;

always_comb begin
    set_defaults();
    which_replace(LRU_out);
    which_dirty(replace_which_way, Dirty1_out, Dirty2_out, Dirty3_out, Dirty4_out, Dirty5_out,Dirty6_out, Dirty7_out, Dirty8_out);

    case(curr_state)
        // stall: begin
        //     read_dirty_array_1 = 1'b1; 
        //     read_dirty_array_2 = 1'b1;
        // end
        hit: begin
            if(~hit_check) begin
                LRU_read = 1'b1;
            end
            else begin
            //   which_hit(hit_check, hit1, hit2, hit3, hit4, hit5, hit6, hit7, hit8,
            //   Dirty1_out, Dirty2_out, Dirty3_out, Dirty4_out, Dirty5_out, Dirty6_out, Dirty7_out, Dirty8_out);
                LRU_load = 1'b1;
                load_PLRU(hit1, hit2, hit3,hit4,hit5,hit6,hit7,hit8);

                if (read) begin
                      if (hit1) begin
                      cacheline_sel = 3'b000;
                    end
                    else if (hit2) begin
                        cacheline_sel = 3'b001;
                    end
                    else if (hit3) begin
                      cacheline_sel = 3'b010;
                    end
                    else if (hit4) begin
                      cacheline_sel = 3'b011;
                    end
                    else if (hit5) begin
                       cacheline_sel = 3'b100;
                    end
                    else if (hit6) begin
                       cacheline_sel = 3'b101;
                    end
                    else if (hit7) begin
                     cacheline_sel = 3'b110;
                    end
                    else if (hit8) begin
                        cacheline_sel = 3'b111;
                    end
                    // if(hit1) begin
                    //    cacheline_sel = 1'b0;
                    //     LRU_in = 1'b0;
                    // end   
                    // else if(hit2) begin
                    //     cacheline_sel = 1'b1;
                    //     LRU_in = 1'b1;
                    //  end   
            end
                else if (write) begin
                    if (hit1) begin
                        Dirty1_in = 1'b1;
                        Dirty1_load = 1'b1;
                        write_read_sel_1 = 1'b1;
                        write_sel_way_1 = 1'b1;
                         cacheline_sel = 3'b000;
                    end
                    else if (hit2) begin
                        Dirty2_load = 1'b1;
                        Dirty2_in = 1'b1;
                        write_read_sel_2 = 1'b1;
                        write_sel_way_2 = 1'b1;
                         cacheline_sel = 3'b001;
                    end
                    else if (hit3) begin
                        Dirty3_load = 1'b1;
                        Dirty3_in = 1'b1;
                        write_read_sel_3 = 1'b1;
                        write_sel_way_3 = 1'b1;
                         cacheline_sel = 3'b010;
                    end
                    else if (hit4) begin
                        Dirty4_load = 1'b1;
                        Dirty4_in = 1'b1;
                        write_read_sel_4 = 1'b1;
                        write_sel_way_4 = 1'b1;
                         cacheline_sel = 3'b011;
                    end
                    else if (hit5) begin
                        Dirty5_load = 1'b1;
                        Dirty5_in = 1'b1;
                        write_read_sel_5 = 1'b1;
                        write_sel_way_5 = 1'b1;
                         cacheline_sel = 3'b100;
                    end
                    else if (hit6) begin
                        Dirty6_load = 1'b1;
                        Dirty6_in = 1'b1;
                        write_read_sel_6 = 1'b1;
                        write_sel_way_6 = 1'b1;
                         cacheline_sel = 3'b101;
                    end
                    else if (hit7) begin
                        Dirty7_load = 1'b1;
                        Dirty7_in = 1'b1;
                        write_read_sel_7 = 1'b1;
                        write_sel_way_7 = 1'b1;
                         cacheline_sel = 3'b110;
                    end
                    else if (hit8) begin
                        Dirty8_load = 1'b1;
                        Dirty8_in = 1'b1;
                        write_read_sel_8 = 1'b1;
                        write_sel_way_8 = 1'b1;
                         cacheline_sel = 3'b111;
                    end
                end
            done = 1'b1;
            end
        end
        miss_clean: begin
            // read_tag_array_1 = 1'b1;
            // read_tag_array_2 = 1'b1;
            // valid_2_in_read = 1'b1;
            // valid_1_in_read = 1'b1;
            pmem_read = 1'b1;
            if(read) begin
                cacheline_sel = replace_which_way;
                case (replace_which_way) //is 7 bits now need to chance
                    3'b000: begin
                        tag_array1_load = 1'b1;
                        valid_1_load = 1'b1;
                        valid_1_in = 1'b1;
                        write_sel_way_1 = 1'b1;

                    end
                    3'b001: begin
                        tag_array2_load = 1'b1;
                        valid_2_load = 1'b1;
                        valid_2_in = 1'b1;
                        write_sel_way_2 = 1'b1;
                    end
                    3'b010: begin
                        tag_array3_load = 1'b1;
                        valid_3_load = 1'b1;
                        valid_3_in = 1'b1;
                        write_sel_way_3 = 1'b1;
                    end
                    3'b011: begin
                        tag_array4_load = 1'b1;
                        valid_4_load = 1'b1;
                        valid_4_in = 1'b1;
                        write_sel_way_4 = 1'b1;
                    end
                    3'b100: begin
                        tag_array5_load = 1'b1;
                        valid_5_load = 1'b1;
                        valid_5_in = 1'b1;
                        write_sel_way_5 = 1'b1;
                    end
                    3'b101: begin
                        tag_array6_load = 1'b1;
                        valid_6_load = 1'b1;
                        valid_6_in = 1'b1;
                        write_sel_way_6 = 1'b1;
                    end
                    3'b110: begin
                        tag_array7_load = 1'b1;
                        valid_7_load = 1'b1;
                        valid_7_in = 1'b1;
                        write_sel_way_7 = 1'b1;
                    end
                    3'b111: begin
                        tag_array8_load = 1'b1;
                        valid_8_load = 1'b1;
                        valid_8_in = 1'b1;
                        write_sel_way_8 = 1'b1;
                    end
                endcase
            end
            else if(write) begin
                 cacheline_sel = replace_which_way;
                case (replace_which_way) //is 7 bits now need to chance
                    3'b000: begin
                        tag_array1_load = 1'b1;
                        valid_1_load = 1'b1;
                        valid_1_in = 1'b1;
                        write_sel_way_1 = 1'b1;

                    end
                    3'b001: begin
                        tag_array2_load = 1'b1;
                        valid_2_load = 1'b1;
                        valid_2_in = 1'b1;
                        write_sel_way_2 = 1'b1;
                    end
                    3'b010: begin
                        tag_array3_load = 1'b1;
                        valid_3_load = 1'b1;
                        valid_3_in = 1'b1;
                        write_sel_way_3 = 1'b1;
                    end
                    3'b011: begin
                        tag_array4_load = 1'b1;
                        valid_4_load = 1'b1;
                        valid_4_in = 1'b1;
                        write_sel_way_4 = 1'b1;
                    end
                    3'b100: begin
                        tag_array5_load = 1'b1;
                        valid_5_load = 1'b1;
                        valid_5_in = 1'b1;
                        write_sel_way_5 = 1'b1;
                    end
                    3'b101: begin
                        tag_array6_load = 1'b1;
                        valid_6_load = 1'b1;
                        valid_6_in = 1'b1;
                        write_sel_way_6 = 1'b1;
                    end
                    3'b110: begin
                        tag_array7_load = 1'b1;
                        valid_7_load = 1'b1;
                        valid_7_in = 1'b1;
                        write_sel_way_7 = 1'b1;
                    end
                    3'b111: begin
                        tag_array8_load = 1'b1;
                        valid_8_load = 1'b1;
                        valid_8_in = 1'b1;
                        write_sel_way_8 = 1'b1;
                    end
                endcase
            end

        end
        miss_dirty: begin
                pmem_write = 1'b1;
                new_address_sel = 1'b1;
                cacheline_sel = replace_which_way;  
            case (replace_which_way)  // is 7 bits now need to change
                3'b000: begin
                    // valid_1_in = 1'b0;
                    // valid_1_load = 1'b1;
                    Dirty1_in = 1'b0;
                    Dirty1_load = 1'b1;
                end
                3'b001: begin
                    // valid_2_in = 1'b0;
                    // valid_2_load = 1'b1;
                    Dirty2_in = 1'b0;
                    Dirty2_load = 1'b1;
                end
                3'b010: begin
                    // valid_2_in = 1'b0;
                    // valid_2_load = 1'b1;
                    Dirty3_in = 1'b0;
                    Dirty3_load = 1'b1;
                end
                3'b011: begin
                    // valid_2_in = 1'b0;
                    // valid_2_load = 1'b1;
                    Dirty4_in = 1'b0;
                    Dirty4_load = 1'b1;
                end
                3'b100: begin
                    // valid_2_in = 1'b0;
                    // valid_2_load = 1'b1;
                    Dirty5_in = 1'b0;
                    Dirty5_load = 1'b1;
                end
                3'b101: begin
                    // valid_2_in = 1'b0;
                    // valid_2_load = 1'b1;
                    Dirty6_in = 1'b0;
                    Dirty6_load = 1'b1;
                end
                3'b110: begin
                    // valid_2_in = 1'b0;
                    // valid_2_load = 1'b1;
                    Dirty7_in = 1'b0;
                    Dirty7_load = 1'b1;
                end
                3'b111: begin
                    // valid_2_in = 1'b0;
                    // valid_2_load = 1'b1;
                    Dirty8_in = 1'b0;
                    Dirty8_load = 1'b1;
                end
            endcase
        end
    endcase
end
    


always_comb begin
    next_state = curr_state; 
    case(curr_state)
    stall:begin
        if (read || write) begin
            next_state = hit;
        end
        else
            next_state = stall; 
    end
    hit: begin
        if (hit_check) begin
            next_state = stall;
        end
        else if(~hit_check && ~dirty )
            next_state = miss_clean;
        else if(~hit_check && dirty )
            next_state = miss_dirty;
    end
    miss_dirty: begin
        if(~mem_resp_cache)
            next_state = miss_dirty;
        else   
            next_state = miss_clean;
        end
    miss_clean: begin
        if(~mem_resp_cache)
            next_state = miss_clean;
        else   
            next_state = hit;
         end

    endcase
end


always_ff @ (posedge clk) begin
    if(rst) begin
        curr_state <= stall; 
    end
    else begin
        curr_state <= next_state;
    end

end

endmodule : modular_cache_control
