import math
from binarytree import build
import copy

ways = 4

def dfs(root, location):
    if (root == None):
        return False
    stack = []
    stack.append(root)
    visited = set()
    while(len(stack)):
        s = stack[-1]
        stack.pop()
        # print("sadfsd ", s.value)
        if (s.value not in visited):
            # print(s.value)
            visited.add(s.value)
        if (s.right!=  None):
            right = s.right
            if(right.value not in visited):
                stack.append(right)
        if (s.left!= None):
            left = s.left
            if(left.value not in visited):
                stack.append(left)
        if (location in visited):
            return True
    return False




def control():
    file_name =  "cache_cntrl_"+str(ways)
    file_break = ",\n\t"
    file = open(file_name+".sv", "w")
    file_content ="module " + file_name + "(\n" 
    file_content += "\tinput clk,\n\tinput rst,\n\tinput mem_resp_cache,\n\tinput logic read,\n\tinput logic write,\n" + "\n\t" 
    for i in range(ways):
        file_content+="input logic hit"+str(i+1)+ file_break
    file_content += "\n\t"
    for i in range(ways):
        file_content+="input logic Dirty"+str(i+1)+"_out"+ file_break
    file_content +="\n\t"
    file_content += "input logic ["+str(ways-2)+":0] LRU_out" + file_break
    file_content +="output logic [" + str(int(math.log2(ways)-1))+":0] which_tag" + file_break
    file_content += "output logic new_address_sel" + file_break;
    file_content += "\n\t"
    for i in range(ways):
        file_content += "output logic valid_"+ str(i+1)+"_in" + file_break
    file_content+="\n\t"
    file_content +="output logic [" + str(ways-2) + ":0] LRU_in," + "\n\n\t"
    for i in range(ways):
        file_content += "output logic Dirty"+str(i+1)+"_load"+ file_break
    file_content += "\n\t"
    file_content += "output logic LRU_load,\n\toutput logic LRU_read," + "\n\n\t"
    for i in range(ways):
        file_content += "output logic tag_array" + str(i+1) + "_load" + file_break
    file_content += "\n\t"
    for i in range(ways):
        file_content += "output logic read_data_array_" + str(i+1) + file_break
    file_content += "\n\t"
    for i in range(ways):
        file_content += "output logic valid_" + str(i+1) + "_load" + file_break
    file_content += "\n\t"
    for i in range(ways):
        file_content += "output logic [1:0] write_sel_way_" + str(i+1)  + file_break
    file_content += "\n\t"
    for i in range(ways):
        file_content += "output logic write_read_sel_" + str(i+1) + file_break
    file_content += "\n\t"
    for i in range(ways):
        file_content += "output logic read_dirty_array_" + str(i+1) + file_break
    file_content += "\n\t"
    for i in range(ways):
        file_content += "output logic read_tag_array_" + str(i+1) + file_break
    file_content += "\n\t"
    for i in range(ways):
        file_content += "output logic valid_" + str(i+1) + "_in_read"+ file_break
    file_content += "\n\t"
    file_content += "output logic [" + str(int(math.log2(ways)-1)) + ":0] cacheline_sel," +"\n\n\t"
    for i in range(ways):
        file_content += "output logic Dirty" + str(i+1) + "_in"+ file_break
    file_content += "\n\n\t"
    file_content+="output logic pmem_read,\n\toutput logic pmem_write,\n\toutput logic done\n);\n\n"
    file_content +="logic ["+ str(int(math.log2(ways)-1)) + ":0] replace_which_way;\nlogic hit_check;\nlogic dirty;\nlogic["+ str(ways-2) +":0] temp_PLRU;\n\n"
    file_content += "function void load_PLRU("
    for i in range(ways):
        if (i<ways-1):
            file_content+="logic h" + str(i+1) +", "
        else:
            file_content+="logic h" + str(i+1) 
    file_content+=");\n\tLRU_in = LRU_out;\n\t"

    numerator = 1
    denominator = 2 
    nodes = []
    while(denominator<=ways):
        while(numerator<denominator ):
            nodes.append(str((int((ways*numerator/denominator)-1))))
            numerator +=2
        numerator = 1
        denominator *=2
    for i in range(ways):
        nodes.append("way"+str(i+1))
    # print(nodes)
    binary_tree = build(nodes)
    height = binary_tree.height
    print(binary_tree)
    path = [[] for i in range(ways)]
    for i in range(ways):
        temp_tree = copy.deepcopy(binary_tree)
        for j in range(height):
            if(dfs(temp_tree.left,str("way"+str(i+1)))):
                path[i].append((temp_tree.value, 0))
                temp_tree = temp_tree.left
            elif (dfs(temp_tree.right,str("way"+str(i+1)))):
                path[i].append((temp_tree.value, 1))
                temp_tree = temp_tree.right
    
    for i in range(len(path)):
        file_content+="if (h" + str(i+1)+") begin\n\t"
        for j in range(len(path[i])):
            file_content+="\tLRU_in["+path[i][j][0]+"] = 1'b"+str(path[i][j][1])+";\n\t"
        file_content+="end\n\n\t"
    file_content+="endfunction\n"

    file_content +="function void which_dirty( logic [2:0] replace, "
    for i in range(ways):
        if (i<ways-1):
            file_content+=" logic d"+str(i+1)+","
        else:
            file_content+=" logic d"+str(i+1)+");\n\t"
    file_content+="case (replace)\n"
    counter = 0
    for i in range(ways):
        file_content+="\t" + str(int(math.log2(ways)))+"'"+ str(bin(counter))[1:]
        file_content += ": dirty = d" + str(i+1) +";\n"
        counter+=1
    file_content += "\tendcase\n"
    file_content +="endfunction\n\n"

    file_content +="function void set_defaults();\n\t"
    file_content+="cacheline_sel = " + str(int(math.log2(ways)))+"'b0;\n\n\t"
    for i in range(ways):
        file_content+="valid_"+str(i+1)+"_in = 1'b0;\n\t"
    file_content += "\n\tLRU_in = " + str(ways-1)+"'b0;\n"
    file_content += "\tLRU_load = 1'b0;\n"
    file_content +="\tLRU_read = 1'b1;\n\n"
    for i in range(ways):
        file_content += "\tDirty"+str(i+1)+"_load = 1'b0;\n"
    file_content+="\n"
    for i in range(ways):
        file_content+="\ttag_array"+str(i+1)+"_load = 1'b0;\n"
    file_content+="\n"
    for i in range(ways):
        file_content+="\tvalid_"+str(i+1)+"_load = 1'b0;\n"
    file_content += "\n"
    for i in range(ways):
        file_content+="\twrite_sel_way_"+str(i+1)+ " = 2'b00;\n"
    file_content+="\n"
    for i in range(ways):
        file_content +="\tread_dirty_array_"+str(i+1)+" = 1'b1;\n"
    file_content+="\n"
    for i in range(ways):
        file_content +="\tread_tag_array_"+str(i+1)+" = 1'b1;\n"
    file_content+="\n"
    for i in range(ways):
        file_content +="\tread_data_array_"+str(i+1)+" = 1'b1;\n"
    file_content+="\n"
    for i in range(ways):
        file_content +="\tvalid_"+str(i+1)+"_in_read = 1'b1;\n"
    file_content+="\n\tpmem_read = 1'b0;\n\tpmem_write=1'b0;\n\tnew_address_sel=1'b0;\n\tdone=1'b0;\n\n"
    for i in range(ways):
        file_content +="\twrite_read_sel_"+str(i+1)+" = 1'b0;\n"
    file_content +="endfunction\n\n"
    file_content+="function void which_replace( logic [" +str(ways-2)+":0] PLRU);\n\t"
    file_content+="temp_PLRU = ~PLRU;\n"
    temp_str=""
    for i in range (len(path)):
        for j in range(len(path[i])):
            temp_str +=("\t") *(j+1)+ "if (temp_PLRU["+str(path[i][j][0])+"] == 1'b"+ str(path[i][j][1])+") begin\n" # maybe need to fix pepega
            # tree_dict[path[i][j][0]] = 0
        temp_str +=("\t") *(j+2)+ "replace_which_way = " + str(int(math.log2(ways)))+"'b"+str(bin(i)[2:])+";\n"
        temp_str +=("\t") *(j+2)+"which_tag = " + str(int(math.log2(ways)))+"'b"+str(bin(i)[2:])+";\n"
        for j in range(len(path[i]),0,-1):
            temp_str+=("\t")*j + "end\n"
    file_content+=temp_str+"endfunction\n\n"
    # file_content+=temp_str
    file_content += "assign hit_check = ("
    for i in range(ways):
        if (i<ways-1):
            file_content+="hit"+str(i+1)+"||"
        else:
            file_content+="hit"+str(i+1)+");\n"
    file_content += "enum int unsigned {\n\thit,\n\tmiss_clean, \n\tmiss_dirty\n} curr_state, next_state;\n\n"
    file_content += "always_comb begin\n\tset_defaults();\n\twhich_replace(LRU_out);\n"
    file_content+="\twhich_dirty(replace_which_way, "
    for i in range(ways):
        if(i<ways-1):
            file_content+="Dirty"+str(i+1)+"_out, "
        else:
            file_content+="Dirty"+str(i+1)+"_out);\n"
    file_content+="\tcase(curr_state)\n\t\thit:begin\n\t\tif(!(read||write))begin\n\t\t\tset_defaults();\n\t\tend\n\t\telse begin\n"
    file_content +="\t\t\tif(~hit_check) begin\n\t\t\t\tLRU_read = 1'b1;\n\t\t\tend\n"
    file_content +="\t\t\telse begin\n\t\t\t\tLRU_load=1'b1;\n\t\t\t\tload_PLRU("
    for i in range(ways):
        if (i<ways-1):
            file_content+="hit"+str(i+1)+", "
        else:
            file_content +="hit"+str(i+1)+");\n"
    file_content+="\t\t\t\tif(read)begin\n\t\t\t\t\t"
    for i in range(ways):
        if (i==0):
            file_content+="if(hit" + str(i+1)+") begin\n\t\t\t\t\t\t cacheline_sel = " + str(int(math.log2(ways))) + "'b" +str(bin(i)[2:])+";\n"
            file_content+="\t\t\t\t\tend\n"
        else:
            file_content+="\t\t\t\t\telse if(hit" + str(i+1)+") begin\n\t\t\t\t\t\t cacheline_sel = " + str(int(math.log2(ways))) + "'b" +str(bin(i)[2:])+";\n"
            file_content+="\t\t\t\t\tend\n"
    file_content +="\t\t\t\tend\n"
    file_content+="\t\t\t\telse if(write)begin\n\t\t\t\t\t"
    for i in range(ways):
        if (i==0):
            file_content+="if(hit" + str(i+1)+") begin\n\t\t\t\t\t\tcacheline_sel = " + str(int(math.log2(ways))) + "'b" +str(bin(i)[2:])+";\n"
            file_content+="\t\t\t\t\t\tDirty"+str(i+1)+"_in = 1'b1;\n"
            file_content+="\t\t\t\t\t\tDirty"+str(i+1)+"_load = 1'b1;\n"
            file_content+="\t\t\t\t\t\twrite_read_sel_"+str(i+1)+" = 1'b1;\n"
            file_content+="\t\t\t\t\t\twrite_sel_way_"+str(i+1)+" = 2'b10;\n"
            file_content+="\t\t\t\t\tend\n"
        else:
            file_content+="\t\t\t\t\telse if(hit" + str(i+1)+") begin\n\t\t\t\t\t\tcacheline_sel = " + str(int(math.log2(ways))) + "'b" +str(bin(i)[2:])+";\n"
            file_content+="\t\t\t\t\t\tDirty"+str(i+1)+"_in = 1'b1;\n"
            file_content+="\t\t\t\t\t\tDirty"+str(i+1)+"_load = 1'b1;\n"
            file_content+="\t\t\t\t\t\twrite_read_sel_"+str(i+1)+" = 1'b1;\n"
            file_content+="\t\t\t\t\t\twrite_sel_way_"+str(i+1)+" = 2'b10;\n"
            file_content+="\t\t\t\t\tend\n"
    file_content += "\t\t\t\tend\n\t\t\tdone = 1'b1;\n\t\tend\nend\nend\n"
    file_content+="\tmiss_clean:begin\n"
    file_content+="\t\tpmem_read = 1'b1;\n\t\tif(read) begin\n\t\t\tcacheline_sel = replace_which_way;\n\t\t\tcase(replace_which_way)\n"
    tab = "\t\t\t\t"
    for i in range(ways):
        file_content+="\t\t\t3'b"+str(bin(i)[2:])+": begin\n"
        file_content+=tab+"tag_array"+str(i+1)+"_load = 1'b1;\n"
        file_content+=tab + "valid_" +str(i+1)+"_load = 1'b1;\n"
        file_content+=tab + "valid_" + str(i+1)+"_in = 1'b1;\n"
        file_content += tab + "write_sel_way_"+str(i+1)+" = 2'b01;\n"
        file_content += tab[:3] + "end\n"
    file_content+=tab[:2]+"endcase\n"
    file_content +=tab[:1]+ "end\n"
    file_content += "\telse if (write) begin\n\t\tcacheline_sel = replace_which_way;\n\t\tcase(replace_which_way)\n"    
    for i in range(ways):
        file_content+="\t\t\t3'b"+str(bin(i)[2:])+": begin\n"
        file_content+=tab+"tag_array"+str(i+1)+"_load = 1'b1;\n"
        file_content+=tab + "valid_" +str(i+1)+"_load = 1'b1;\n"
        file_content+=tab + "valid_" + str(i+1)+"_in = 1'b1;\n"
        file_content += tab + "write_sel_way_"+str(i+1)+" = 2'b01;\n"
        file_content += tab[:3] + "end\n"
    file_content+=tab[:2]+"endcase\n"
    file_content +=tab[:1]+ "end\nend\n"
    

    file_content+="\tmiss_dirty:begin\n"
    file_content+="\t\tpmem_write = 1'b1;\n\t\tnew_address_sel = 1'b1;\n\t\tcacheline_sel=replace_which_way;\n"
    file_content+="\t\tcase (replace_which_way)\n"
    for i in range(ways):
        file_content+="\t\t\t"+ str(int(math.log2(ways)))+"'b"+str(bin(i)[2:])+": begin\n"
        file_content +="\t\t\tDirty"+str(i+1)+"_in = 1'b0;\n"
        file_content+="\t\t\tDirty"+str(i+1)+"_load = 1'b1;\n\t\tend\n"
    file_content +="\tendcase\nend\nendcase\nend"

    file_content+="\nalways_comb begin"
    file_content+="\n\tnext_state = curr_state;\n"
    file_content+="case(curr_state)\n"
    file_content+="hit:begin\n\t"
    file_content+="if(read||write) begin\n\t\tif(hit_check) begin\n\t\tnext_state = hit;\n\tend\n\telse if(~hit_check && ~dirty)\n\t\tnext_state = miss_clean;\n\telse if(~hit_check && dirty)\n\t\tnext_state=miss_dirty;\n\tend\nend\n"
    file_content+="miss_dirty:begin\n\tif(~mem_resp_cache)\n\t\tnext_state = miss_dirty;\n\telse\n\t\tnext_state = miss_clean;\n\tend\n"
    file_content+="miss_clean:begin\n\tif(~mem_resp_cache)\n\t\tnext_state = miss_clean;\n\telse\n\tnext_state = hit;\nend"
    file_content+="\nendcase\nend\n\n"

    file_content+="always_ff @ (posedge clk) begin\n\tif(rst)begin\n\t\tcurr_state<=hit;\n\tend\n\telse begin\n\t\tcurr_state<= next_state;\n\tend\nend\n"
    file_content+="endmodule : " +file_name

    file.write(file_content)

def datapath():
    file_name = "cache_datapath_"+str(ways) 
    file = open(file_name+".sv", "w")
    file_content = "module "+ file_name+ " #(\n\tparameter s_offset = 5,\n\tparameter s_index = 3,\n\tparameter s_tag = 32 - s_offset-s_index,\n\tparameter s_mask = 2**s_offset,\n\tparameter s_line = 8*s_mask,\n\tparameter num_sets = 2**s_index\n)\n(\n"
    file_content+="input clk,\ninput rst,\ninput logic [31:0] address,\n\n"
    for i in (range(ways)):
        file_content+="input logic Dirty"+str(i+1)+"_in,\n"
    file_content+="\n"
    for i in (range(ways)):
        file_content+="input logic valid_"+str(i+1)+"_in,\n"
    file_content+="\n"
    file_content+="input logic[255:0] mem_wdata256,\n\n"
    for i in (range(ways)):
        file_content+="input logic Dirty"+str(i+1)+"_load,\n"
    file_content+="\n"
    file_content+="input logic LRU_load,\n\n"
    for i in (range(ways)):
        file_content+="input logic tag_array"+str(i+1)+"_load,\n"
    file_content+="\n"
    for i in (range(ways)):
        file_content+="input logic valid_"+str(i+1)+"_load,\n"
    file_content+="\n"
    for i in (range(ways)):
        file_content+="input logic [1:0] write_sel_way_"+str(i+1)+",\n"
    file_content+="\n"
    for i in (range(ways)):
        file_content+="input logic read_dirty_array_"+str(i+1)+",\n"
    file_content+="\n"
    file_content+="input logic LRU_read,\n\n"
    for i in (range(ways)):
        file_content+="input logic read_tag_array_"+str(i+1)+",\n"
    file_content+="\n"
    for i in (range(ways)):
        file_content+="input logic read_data_array_"+str(i+1)+",\n"
    file_content+="\n"
    for i in (range(ways)):
        file_content+="input logic valid_"+str(i+1)+"_in_read,\n"
    file_content+="\n"
    file_content+="input logic new_address_sel,\n\n"
    for i in (range(ways)):
        file_content+="input logic write_read_sel_"+str(i+1)+",\n"
    file_content+="\n"
    file_content+="input logic [" + str(int(math.log2(ways)-1))+":0] which_tag,\n"
    file_content+="input logic [31:0] mem_byte_enable256,\n"
    file_content +="input logic [" + str(ways-2) + ":0] LRU_in," + "\n"
    file_content += "input logic [" + str(int(math.log2(ways)-1)) + ":0] cacheline_sel," +"\n"
    file_content += "input logic [255:0] cacheline_in,\noutput logic [255:0] cacheline_out,\noutput logic [s_tag-1:0]tag_out,\n\n"
    for i in (range(ways)):
        file_content+="output logic Dirty"+str(i+1)+"_out,\n"
    file_content+="\n"
    for i in (range(ways)):
        file_content+="output logic hit"+str(i+1)+",\n"
    file_content+="\n"
    file_content+="output logic [31:0] new_address,\n"
    file_content += "output logic ["+str(ways-2)+":0] LRU_out\n);\n\n"
    for i in range(ways):
        file_content+= "logic [s_tag-1:0] tag_array" +str(i+1)+"_out;\n"
    file_content += "\n"
    for i in range(ways):
        file_content+= "logic valid_" +str(i+1)+"_out;\n"
    file_content += "\n"

    for i in range(ways):
        file_content+="array_"+str(ways)+"_way #(.s_index(s_index), .width(1))\n"
        file_content+="dirty_bit_aray_way_"+str(i+1)+"(\n"
        file_content+=".clk(clk),\n.rst(rst),\n"
        file_content+=".read(read_dirty_array_"+str(i+1)+"),\n"
        file_content+=".load(Dirty"+str(i+1)+"_load),\n"
        file_content+=".rindex(address[s_offset+s_index-1:s_offset]),\n"
        file_content+=".windex(address[s_offset+s_index-1:s_offset]),\n"
        file_content+=".datain(Dirty"+str(i+1)+"_in),\n"
        file_content+=".dataout(Dirty"+str(i+1)+"_out)\n);\n\n"

    for i in range(ways):
        file_content+="array_"+str(ways)+"_way #(.s_index(s_index), .width(1))\n"
        file_content+="valid_array_"+str(i+1)+"(\n"
        file_content+=".clk(clk),\n.rst(rst),\n"
        file_content+=".read(valid_"+str(i+1)+"_in_read),\n"
        file_content+=".load(valid_"+str(i+1)+"_load),\n"
        file_content+=".rindex(address[s_offset+s_index-1:s_offset]),\n"
        file_content+=".windex(address[s_offset+s_index-1:s_offset]),\n"
        file_content+=".datain(valid_"+str(i+1)+"_in),\n"
        file_content+=".dataout(valid_"+str(i+1)+"_out)\n);\n\n"

    for i in range(ways):
        file_content+="array_"+str(ways)+"_way #(.s_index(s_index), .width(s_tag))\n"
        file_content+="tag_array"+str(i+1)+"(\n"
        file_content+=".clk(clk),\n.rst(rst),\n"
        file_content+=".read(read_tag_array_"+str(i+1)+"),\n"
        file_content+=".load(tag_array"+str(i+1)+"_load),\n"
        file_content+=".rindex(address[s_offset+s_index-1:s_offset]),\n"
        file_content+=".windex(address[s_offset+s_index-1:s_offset]),\n"
        file_content+=".datain(address[31:s_offset+s_index]),\n"
        file_content+=".dataout(tag_array"+str(i+1)+"_out)\n);\n\n"
    
    
    file_content+="array_"+str(ways)+"_way #(.s_index(s_index), .width(" +str(ways-1)+  "))\n"
    file_content+="PLRU_array(\n"
    file_content+=".clk(clk),\n.rst(rst),\n"
    file_content+=".read(LRU_read),\n"
    file_content+=".load(LRU_load),\n"
    file_content+=".rindex(address[s_offset+s_index-1:s_offset]),\n"
    file_content+=".windex(address[s_offset+s_index-1:s_offset]),\n"
    file_content+=".datain(LRU_in),\n"
    file_content+=".dataout(LRU_out)\n);\n\n"

    file_content+="logic [31:0] "
    for i in range(ways):
        if(i<ways-1):
            file_content+= "write_en_way_"+str(i+1)+", "
        else:
            file_content+= "write_en_way_"+str(i+1)+";"
    file_content+="\n"
    file_content+="logic [255:0] "
    for i in range(ways):
        if(i<ways-1):
            file_content+= "cache_line_data_out_"+str(i+1)+", "
        else:
            file_content+= "cache_line_data_out_"+str(i+1)+";"

    file_content+="\nlogic [255:0] "
    for i in range(ways):
        if(i<ways-1):
            file_content+= "data_in_"+str(i+1)+", "
        else:
            file_content+= "data_in_"+str(i+1)+";"
    file_content+="\n\n"

    for i in range(ways):
        file_content+="data_array_"+str(ways)+"_way w" +str(i+1)+"(\n"
        file_content+=".clk(clk),\n"
        file_content+=".read(read_data_array_"+str(i+1)+"),\n"
        file_content+=".write_en(write_en_way_"+str(i+1)+"),\n"
        file_content+=".rindex(address[s_offset+s_index-1:s_offset]),\n"
        file_content+=".windex(address[s_offset+s_index-1:s_offset]),\n"
        file_content+=".datain(data_in_" + str(i+1)+  "),\n"
        file_content+=".dataout(cache_line_data_out_"+str(i+1)+")\n);\n\n"

    file_content +="always_comb begin\n"
    for i in range(ways):
        file_content += "\tcase(write_read_sel_" +str(i+1)+")\n"
        file_content += "\t1'b0: data_in_"+str(i+1)+"= cacheline_in;\n"
        file_content += "\t1'b1: data_in_"+str(i+1)+"= mem_wdata256;\n\tendcase\n"
    file_content += "\tcase (new_address_sel)\n"
    file_content += "\t1'b0: new_address = {address[31:s_offset],5'b0};\n"
    file_content += "\t1'b1: new_address = {tag_out, address[s_offset+s_index-1:s_offset],5'b0};\n\tendcase\n"
    file_content += "\tcase (which_tag)\n"
    for i in range(ways):
        file_content += "\t"+ str(int(math.log2(ways)))+"'b"+str(bin(i)[2:]) +": tag_out = tag_array" +str(i+1)+"_out;\n"
    file_content+="\tendcase\n\n"
    file_content+="\tcase (cacheline_sel)\n"
    for i in range(ways):
        file_content += "\t"+ str(int(math.log2(ways)))+"'b"+str(bin(i)[2:]) +": cacheline_out = cache_line_data_out_" +str(i+1)+";\n"
    file_content+="\tendcase\n\n"

    for i in range(ways):
        file_content+="\tunique case(write_sel_way_"+str(i+1)+")\n"
        file_content += "\t"+ "2'b10" +": write_en_way_" +str(i+1) +" = mem_byte_enable256" +";\n"
        file_content += "\t"+"2'b01: write_en_way_" +str(1+i)+" = {32{1'b1}};"
        file_content +="\n\tdefault: write_en_way_" + str(i+1) + " = {32{1'b0}};"
        file_content +="\n\tendcase\n\n"



    for i in range(ways):
        file_content += "unique case (read_tag_array_" + str(i+1) +")\n\t"
        file_content +="\t1'b1: begin\n"
        file_content +="\t\t\tif ((address[31:s_offset+s_index] == tag_array"+str(i+1)+"_out) && valid_" + str(i+1)+"_out) begin\n"
        file_content +="\t\t\t hit" + str(i+1)+" = 1'b1;\n"
        file_content +="end\n"
        file_content +="\t\t\telse \n\t\t\thit" + str(i+1) +" = 1'b0;\nend\n"
        file_content +="\tdefault: hit" + str(i+1)+" = 1'b0;\nendcase\n\n"
    file_content +="end\n\n"
    file_content +="endmodule: "+ file_name



    file.write(file_content)




def cache():
    file_name = "cache_"+ str(ways)+"_way"
    file = open(file_name+".sv", 'w')
    file_content = "module " + file_name + " #(\n\tparameter s_offset = 5,\n\tparameter s_index = 3,\n\tparameter s_tag = 32 - s_offset-s_index,\n\tparameter s_mask = 2**s_offset,\n\tparameter s_line = 8*s_mask,\n\tparameter num_sets = 2**s_index\n)\n(\n"
    file_content += "input clk,\ninput rst,\n\ninput logic [31:0] mem_address,\noutput logic[31:0] mem_rdata,\ninput logic [31:0] mem_wdata,"
    file_content+="\ninput logic mem_read,\ninput logic mem_write,\ninput logic [3:0] mem_byte_enable,\noutput logic mem_resp,\n\noutput logic [31:0] pmem_address,\ninput logic [255:0] pmem_rdata,\noutput logic [255:0] pmem_wdata,\noutput logic pmem_read,\noutput logic pmem_write,\ninput logic pmem_resp\n);"
    file_content +="\nlogic mem_resp_cache;\nassign mem_resp_cache = pmem_resp;\nlogic write;\nassign write = mem_write;\nlogic read;\nassign read = mem_read;\nlogic [31:0] address;\n"
    file_content +="assign address = mem_address;\nlogic [31:0]new_address;\nassign pmem_address = new_address;\nlogic [" + str(int(math.log2(ways)-1))+":0] which_tag;\n"
    for i in range(ways):
        file_content +="logic Dirty"+str(i+1)+"_in;\n"
    file_content+="\n"

    for i in range(ways):
        file_content +="logic valid_"+str(i+1)+"_in;\n"
    file_content+="\n"

    for i in range(ways):
        file_content +="logic Dirty"+str(i+1)+"_load;\n"
    file_content+="\n"
    file_content +=  "logic [" + str(int(math.log2(ways)-1)) + ":0] cacheline_sel;\n"
    file_content +="logic LRU_load;\n"
    for i in range(ways):
        file_content +="logic tag_array"+str(i+1)+"_load;\n"
    file_content+="\n"

    for i in range(ways):
        file_content +="logic valid_"+str(i+1)+"_load;\n"
    file_content+="\n"
    file_content+="logic [1:0]"
    for i in range(ways):
        if(i<ways-1):
            file_content+= " write_sel_way_" + str(i+1) +","
        else:
            file_content +=" write_sel_way_" + str(i+1) +";"
    file_content +="\n"
    file_content += "logic [" +str(ways-2)+":0] LRU_out;\n\n"
    for i in range(ways):
        file_content+= "logic read_dirty_array_" + str(i+1) +";\n"
    file_content +="\n"
    file_content+="logic LRU_read;\n"
    for i in range(ways):
        file_content+= "logic read_tag_array_" + str(i+1) +";\n"
    file_content +="\n"
    for i in range(ways):
        file_content+= "logic read_data_array_" + str(i+1) +";\n"
    file_content +="\n"
    for i in range(ways):
        file_content+= "logic valid_" + str(i+1) +"_in_read;\n"
    file_content +="\n"
    file_content+="logic new_address_sel;\n\n"
    file_content+="logic [" + str(ways-2) + ":0] LRU_in;\n"
    file_content +="logic [255:0] cacheline_in;\n"
    file_content +="assign cacheline_in = pmem_rdata;\n"
    file_content +="logic [255:0] cacheline_out;\n"
    file_content +="logic [255:0] mem_rdata256;\n"
    file_content +="logic [255:0] mem_wdata256;\n"
    file_content +="assign mem_rdata256 = cacheline_out;\n"
    file_content +="assign pmem_wdata = cacheline_out;\n"
    file_content +="logic [s_tag-1:0] tag_out;\n\n"
    for i in range(ways):
        file_content+= "logic Dirty" + str(i+1) +"_out;\n"
    file_content +="\n"
    for i in range(ways):
        file_content+= "logic hit" + str(i+1) +";\n"
    file_content +="\n"
    file_content +="logic [31:0] mem_byte_enable256;\n"
    file_content += "logic done;\n"
    for i in range(ways):
        file_content+= "logic write_read_sel_" + str(i+1) + ";\n"
    file_content +="\n"
    file_content +="assign mem_resp = done;\n"
    file_content += "cache_cntrl_"+str(ways)+" control\n(.*\n);\n"
    file_content += "cache_datapath_" +str(ways)+ " datapath\n(.*\n);\n"
    file_content += "bus_adapter_" +str(ways)+"_way bus_adapter\n(.*\n);\n"
    file_content +="endmodule: " + file_name


    

    # file_content +=
    
    file.write(file_content)
if __name__ == "__main__":
    control()
    datapath()
    cache()