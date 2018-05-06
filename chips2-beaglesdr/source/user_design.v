//////////////////////////////////////////////////////////////////////////////
//name : user_design
//input : input_rs232_rx:16
//output : output_rs232_tx:16
//output : output_leds:16
//source_file : user_design.c
///===========
///
///Created by C2CHIP

//////////////////////////////////////////////////////////////////////////////
// Register Allocation
// ===================
//         Register                 Name                   Size          
//            0                 variable cmd                2            
//            1              temporary_register             2            
//            2              temporary_register             2            
//            3             print_udecimal return address            2            
//            4              variable udecimal              2            
//            5                variable digit               2            
//            6             variable significant            2            
//            7              temporary_register             2            
//            8             user_design return address            2            
//            9             stdout_put_char return address            2            
//            10                 variable i                 2            
//            11               variable leds                2            
module user_design(input_rs232_rx,input_rs232_rx_stb,output_rs232_tx_ack,output_leds_ack,clk,rst,output_rs232_tx,output_leds,output_rs232_tx_stb,output_leds_stb,input_rs232_rx_ack);
  integer file_count;
  input [15:0] input_rs232_rx;
  input input_rs232_rx_stb;
  input output_rs232_tx_ack;
  input output_leds_ack;
  input clk;
  input rst;
  output [15:0] output_rs232_tx;
  output [15:0] output_leds;
  output output_rs232_tx_stb;
  output output_leds_stb;
  output input_rs232_rx_ack;
  reg [15:0] timer;
  reg timer_enable;
  reg stage_0_enable;
  reg stage_1_enable;
  reg stage_2_enable;
  reg [8:0] program_counter;
  reg [8:0] program_counter_0;
  reg [44:0] instruction_0;
  reg [4:0] opcode_0;
  reg [3:0] dest_0;
  reg [3:0] src_0;
  reg [3:0] srcb_0;
  reg [31:0] literal_0;
  reg [8:0] program_counter_1;
  reg [4:0] opcode_1;
  reg [3:0] dest_1;
  reg [31:0] register_1;
  reg [31:0] registerb_1;
  reg [31:0] literal_1;
  reg [3:0] dest_2;
  reg [31:0] result_2;
  reg write_enable_2;
  reg [15:0] address_2;
  reg [15:0] data_out_2;
  reg [15:0] data_in_2;
  reg memory_enable_2;
  reg [15:0] address_4;
  reg [31:0] data_out_4;
  reg [31:0] data_in_4;
  reg memory_enable_4;
  reg [15:0] s_output_rs232_tx_stb;
  reg [15:0] s_output_leds_stb;
  reg [15:0] s_output_rs232_tx;
  reg [15:0] s_output_leds;
  reg [15:0] s_input_rs232_rx_ack;
  reg [15:0] memory_2 [1031:0];
  reg [44:0] instructions [334:0];
  reg [31:0] registers [11:0];

  //////////////////////////////////////////////////////////////////////////////
  // MEMORY INITIALIZATION                                                      
  //                                                                            
  // In order to reduce program size, array contents have been stored into      
  // memory at initialization. In an FPGA, this will result in the memory being 
  // initialized when the FPGA configures.                                      
  // Memory will not be re-initialized at reset.                                
  // Dissable this behaviour using the no_initialize_memory switch              
  
  initial
  begin
    memory_2[4] = 10;
    memory_2[5] = 0;
    memory_2[6] = 10;
    memory_2[7] = 0;
  end


  //////////////////////////////////////////////////////////////////////////////
  // INSTRUCTION INITIALIZATION                                                 
  //                                                                            
  // Initialise the contents of the instruction memory                          
  //
  // Intruction Set
  // ==============
  // 0 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'jmp_and_link'}
  // 1 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': 'stop'}
  // 2 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': 'move'}
  // 3 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': 'nop'}
  // 4 {'right': False, 'float': False, 'unsigned': False, 'literal': False, 'output': 'rs232_tx', 'op': 'write'}
  // 5 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': 'jmp_to_reg'}
  // 6 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'literal'}
  // 7 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '>='}
  // 8 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'jmp_if_false'}
  // 9 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '-'}
  // 10 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '+'}
  // 11 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'goto'}
  // 12 {'float': False, 'literal': False, 'right': False, 'unsigned': True, 'op': '|'}
  // 13 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '|'}
  // 14 {'right': False, 'float': False, 'unsigned': False, 'literal': False, 'input': 'rs232_rx', 'op': 'read'}
  // 15 {'float': False, 'literal': True, 'right': True, 'unsigned': False, 'op': '=='}
  // 16 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'jmp_if_true'}
  // 17 {'right': False, 'float': False, 'unsigned': False, 'literal': False, 'output': 'leds', 'op': 'write'}
  // Intructions
  // ===========
  
  initial
  begin
    instructions[0] = {5'd0, 4'd8, 4'd0, 32'd214};//{'dest': 8, 'label': 214, 'op': 'jmp_and_link'}
    instructions[1] = {5'd1, 4'd0, 4'd0, 32'd0};//{'op': 'stop'}
    instructions[2] = {5'd2, 4'd1, 4'd10, 32'd0};//{'dest': 1, 'src': 10, 'op': 'move'}
    instructions[3] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[4] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[5] = {5'd4, 4'd0, 4'd1, 32'd0};//{'src': 1, 'output': 'rs232_tx', 'op': 'write'}
    instructions[6] = {5'd5, 4'd0, 4'd9, 32'd0};//{'src': 9, 'op': 'jmp_to_reg'}
    instructions[7] = {5'd6, 4'd5, 4'd0, 32'd0};//{'dest': 5, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[8] = {5'd6, 4'd6, 4'd0, 32'd0};//{'dest': 6, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[9] = {5'd6, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[10] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[11] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[12] = {5'd2, 4'd5, 4'd1, 32'd0};//{'dest': 5, 'src': 1, 'op': 'move'}
    instructions[13] = {5'd2, 4'd2, 4'd4, 32'd0};//{'dest': 2, 'src': 4, 'op': 'move'}
    instructions[14] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[15] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[16] = {5'd7, 4'd1, 4'd2, 32'd10000};//{'src': 2, 'right': 10000, 'dest': 1, 'signed': False, 'op': '>=', 'type': 'int', 'size': 2}
    instructions[17] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[18] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[19] = {5'd8, 4'd0, 4'd1, 32'd35};//{'src': 1, 'label': 35, 'op': 'jmp_if_false'}
    instructions[20] = {5'd2, 4'd2, 4'd4, 32'd0};//{'dest': 2, 'src': 4, 'op': 'move'}
    instructions[21] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[22] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[23] = {5'd9, 4'd1, 4'd2, 32'd10000};//{'src': 2, 'right': 10000, 'dest': 1, 'signed': False, 'op': '-', 'type': 'int', 'size': 2}
    instructions[24] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[25] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[26] = {5'd2, 4'd4, 4'd1, 32'd0};//{'dest': 4, 'src': 1, 'op': 'move'}
    instructions[27] = {5'd2, 4'd2, 4'd5, 32'd0};//{'dest': 2, 'src': 5, 'op': 'move'}
    instructions[28] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[29] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[30] = {5'd10, 4'd1, 4'd2, 32'd1};//{'src': 2, 'right': 1, 'dest': 1, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[31] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[32] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[33] = {5'd2, 4'd5, 4'd1, 32'd0};//{'dest': 5, 'src': 1, 'op': 'move'}
    instructions[34] = {5'd11, 4'd0, 4'd0, 32'd36};//{'label': 36, 'op': 'goto'}
    instructions[35] = {5'd11, 4'd0, 4'd0, 32'd37};//{'label': 37, 'op': 'goto'}
    instructions[36] = {5'd11, 4'd0, 4'd0, 32'd13};//{'label': 13, 'op': 'goto'}
    instructions[37] = {5'd2, 4'd2, 4'd5, 32'd0};//{'dest': 2, 'src': 5, 'op': 'move'}
    instructions[38] = {5'd2, 4'd7, 4'd6, 32'd0};//{'dest': 7, 'src': 6, 'op': 'move'}
    instructions[39] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[40] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[41] = {5'd12, 4'd1, 4'd2, 32'd7};//{'srcb': 7, 'src': 2, 'dest': 1, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[42] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[43] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[44] = {5'd8, 4'd0, 4'd1, 32'd58};//{'src': 1, 'label': 58, 'op': 'jmp_if_false'}
    instructions[45] = {5'd2, 4'd7, 4'd5, 32'd0};//{'dest': 7, 'src': 5, 'op': 'move'}
    instructions[46] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[47] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[48] = {5'd13, 4'd2, 4'd7, 32'd48};//{'src': 7, 'right': 48, 'dest': 2, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[49] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[50] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[51] = {5'd2, 4'd10, 4'd2, 32'd0};//{'dest': 10, 'src': 2, 'op': 'move'}
    instructions[52] = {5'd0, 4'd9, 4'd0, 32'd2};//{'dest': 9, 'label': 2, 'op': 'jmp_and_link'}
    instructions[53] = {5'd6, 4'd1, 4'd0, 32'd1};//{'dest': 1, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[54] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[55] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[56] = {5'd2, 4'd6, 4'd1, 32'd0};//{'dest': 6, 'src': 1, 'op': 'move'}
    instructions[57] = {5'd11, 4'd0, 4'd0, 32'd58};//{'label': 58, 'op': 'goto'}
    instructions[58] = {5'd6, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[59] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[60] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[61] = {5'd2, 4'd5, 4'd1, 32'd0};//{'dest': 5, 'src': 1, 'op': 'move'}
    instructions[62] = {5'd2, 4'd2, 4'd4, 32'd0};//{'dest': 2, 'src': 4, 'op': 'move'}
    instructions[63] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[64] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[65] = {5'd7, 4'd1, 4'd2, 32'd1000};//{'src': 2, 'right': 1000, 'dest': 1, 'signed': False, 'op': '>=', 'type': 'int', 'size': 2}
    instructions[66] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[67] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[68] = {5'd8, 4'd0, 4'd1, 32'd84};//{'src': 1, 'label': 84, 'op': 'jmp_if_false'}
    instructions[69] = {5'd2, 4'd2, 4'd4, 32'd0};//{'dest': 2, 'src': 4, 'op': 'move'}
    instructions[70] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[71] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[72] = {5'd9, 4'd1, 4'd2, 32'd1000};//{'src': 2, 'right': 1000, 'dest': 1, 'signed': False, 'op': '-', 'type': 'int', 'size': 2}
    instructions[73] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[74] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[75] = {5'd2, 4'd4, 4'd1, 32'd0};//{'dest': 4, 'src': 1, 'op': 'move'}
    instructions[76] = {5'd2, 4'd2, 4'd5, 32'd0};//{'dest': 2, 'src': 5, 'op': 'move'}
    instructions[77] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[78] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[79] = {5'd10, 4'd1, 4'd2, 32'd1};//{'src': 2, 'right': 1, 'dest': 1, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[80] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[81] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[82] = {5'd2, 4'd5, 4'd1, 32'd0};//{'dest': 5, 'src': 1, 'op': 'move'}
    instructions[83] = {5'd11, 4'd0, 4'd0, 32'd85};//{'label': 85, 'op': 'goto'}
    instructions[84] = {5'd11, 4'd0, 4'd0, 32'd86};//{'label': 86, 'op': 'goto'}
    instructions[85] = {5'd11, 4'd0, 4'd0, 32'd62};//{'label': 62, 'op': 'goto'}
    instructions[86] = {5'd2, 4'd2, 4'd5, 32'd0};//{'dest': 2, 'src': 5, 'op': 'move'}
    instructions[87] = {5'd2, 4'd7, 4'd6, 32'd0};//{'dest': 7, 'src': 6, 'op': 'move'}
    instructions[88] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[89] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[90] = {5'd12, 4'd1, 4'd2, 32'd7};//{'srcb': 7, 'src': 2, 'dest': 1, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[91] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[92] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[93] = {5'd8, 4'd0, 4'd1, 32'd107};//{'src': 1, 'label': 107, 'op': 'jmp_if_false'}
    instructions[94] = {5'd2, 4'd7, 4'd5, 32'd0};//{'dest': 7, 'src': 5, 'op': 'move'}
    instructions[95] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[96] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[97] = {5'd13, 4'd2, 4'd7, 32'd48};//{'src': 7, 'right': 48, 'dest': 2, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[98] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[99] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[100] = {5'd2, 4'd10, 4'd2, 32'd0};//{'dest': 10, 'src': 2, 'op': 'move'}
    instructions[101] = {5'd0, 4'd9, 4'd0, 32'd2};//{'dest': 9, 'label': 2, 'op': 'jmp_and_link'}
    instructions[102] = {5'd6, 4'd1, 4'd0, 32'd1};//{'dest': 1, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[103] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[104] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[105] = {5'd2, 4'd6, 4'd1, 32'd0};//{'dest': 6, 'src': 1, 'op': 'move'}
    instructions[106] = {5'd11, 4'd0, 4'd0, 32'd107};//{'label': 107, 'op': 'goto'}
    instructions[107] = {5'd6, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[108] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[109] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[110] = {5'd2, 4'd5, 4'd1, 32'd0};//{'dest': 5, 'src': 1, 'op': 'move'}
    instructions[111] = {5'd2, 4'd2, 4'd4, 32'd0};//{'dest': 2, 'src': 4, 'op': 'move'}
    instructions[112] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[113] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[114] = {5'd7, 4'd1, 4'd2, 32'd100};//{'src': 2, 'right': 100, 'dest': 1, 'signed': False, 'op': '>=', 'type': 'int', 'size': 2}
    instructions[115] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[116] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[117] = {5'd8, 4'd0, 4'd1, 32'd133};//{'src': 1, 'label': 133, 'op': 'jmp_if_false'}
    instructions[118] = {5'd2, 4'd2, 4'd4, 32'd0};//{'dest': 2, 'src': 4, 'op': 'move'}
    instructions[119] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[120] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[121] = {5'd9, 4'd1, 4'd2, 32'd100};//{'src': 2, 'right': 100, 'dest': 1, 'signed': False, 'op': '-', 'type': 'int', 'size': 2}
    instructions[122] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[123] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[124] = {5'd2, 4'd4, 4'd1, 32'd0};//{'dest': 4, 'src': 1, 'op': 'move'}
    instructions[125] = {5'd2, 4'd2, 4'd5, 32'd0};//{'dest': 2, 'src': 5, 'op': 'move'}
    instructions[126] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[127] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[128] = {5'd10, 4'd1, 4'd2, 32'd1};//{'src': 2, 'right': 1, 'dest': 1, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[129] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[130] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[131] = {5'd2, 4'd5, 4'd1, 32'd0};//{'dest': 5, 'src': 1, 'op': 'move'}
    instructions[132] = {5'd11, 4'd0, 4'd0, 32'd134};//{'label': 134, 'op': 'goto'}
    instructions[133] = {5'd11, 4'd0, 4'd0, 32'd135};//{'label': 135, 'op': 'goto'}
    instructions[134] = {5'd11, 4'd0, 4'd0, 32'd111};//{'label': 111, 'op': 'goto'}
    instructions[135] = {5'd2, 4'd2, 4'd5, 32'd0};//{'dest': 2, 'src': 5, 'op': 'move'}
    instructions[136] = {5'd2, 4'd7, 4'd6, 32'd0};//{'dest': 7, 'src': 6, 'op': 'move'}
    instructions[137] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[138] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[139] = {5'd12, 4'd1, 4'd2, 32'd7};//{'srcb': 7, 'src': 2, 'dest': 1, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[140] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[141] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[142] = {5'd8, 4'd0, 4'd1, 32'd156};//{'src': 1, 'label': 156, 'op': 'jmp_if_false'}
    instructions[143] = {5'd2, 4'd7, 4'd5, 32'd0};//{'dest': 7, 'src': 5, 'op': 'move'}
    instructions[144] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[145] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[146] = {5'd13, 4'd2, 4'd7, 32'd48};//{'src': 7, 'right': 48, 'dest': 2, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[147] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[148] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[149] = {5'd2, 4'd10, 4'd2, 32'd0};//{'dest': 10, 'src': 2, 'op': 'move'}
    instructions[150] = {5'd0, 4'd9, 4'd0, 32'd2};//{'dest': 9, 'label': 2, 'op': 'jmp_and_link'}
    instructions[151] = {5'd6, 4'd1, 4'd0, 32'd1};//{'dest': 1, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[152] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[153] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[154] = {5'd2, 4'd6, 4'd1, 32'd0};//{'dest': 6, 'src': 1, 'op': 'move'}
    instructions[155] = {5'd11, 4'd0, 4'd0, 32'd156};//{'label': 156, 'op': 'goto'}
    instructions[156] = {5'd6, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[157] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[158] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[159] = {5'd2, 4'd5, 4'd1, 32'd0};//{'dest': 5, 'src': 1, 'op': 'move'}
    instructions[160] = {5'd2, 4'd2, 4'd4, 32'd0};//{'dest': 2, 'src': 4, 'op': 'move'}
    instructions[161] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[162] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[163] = {5'd7, 4'd1, 4'd2, 32'd10};//{'src': 2, 'right': 10, 'dest': 1, 'signed': False, 'op': '>=', 'type': 'int', 'size': 2}
    instructions[164] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[165] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[166] = {5'd8, 4'd0, 4'd1, 32'd182};//{'src': 1, 'label': 182, 'op': 'jmp_if_false'}
    instructions[167] = {5'd2, 4'd2, 4'd4, 32'd0};//{'dest': 2, 'src': 4, 'op': 'move'}
    instructions[168] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[169] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[170] = {5'd9, 4'd1, 4'd2, 32'd10};//{'src': 2, 'right': 10, 'dest': 1, 'signed': False, 'op': '-', 'type': 'int', 'size': 2}
    instructions[171] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[172] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[173] = {5'd2, 4'd4, 4'd1, 32'd0};//{'dest': 4, 'src': 1, 'op': 'move'}
    instructions[174] = {5'd2, 4'd2, 4'd5, 32'd0};//{'dest': 2, 'src': 5, 'op': 'move'}
    instructions[175] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[176] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[177] = {5'd10, 4'd1, 4'd2, 32'd1};//{'src': 2, 'right': 1, 'dest': 1, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[178] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[179] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[180] = {5'd2, 4'd5, 4'd1, 32'd0};//{'dest': 5, 'src': 1, 'op': 'move'}
    instructions[181] = {5'd11, 4'd0, 4'd0, 32'd183};//{'label': 183, 'op': 'goto'}
    instructions[182] = {5'd11, 4'd0, 4'd0, 32'd184};//{'label': 184, 'op': 'goto'}
    instructions[183] = {5'd11, 4'd0, 4'd0, 32'd160};//{'label': 160, 'op': 'goto'}
    instructions[184] = {5'd2, 4'd2, 4'd5, 32'd0};//{'dest': 2, 'src': 5, 'op': 'move'}
    instructions[185] = {5'd2, 4'd7, 4'd6, 32'd0};//{'dest': 7, 'src': 6, 'op': 'move'}
    instructions[186] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[187] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[188] = {5'd12, 4'd1, 4'd2, 32'd7};//{'srcb': 7, 'src': 2, 'dest': 1, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[189] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[190] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[191] = {5'd8, 4'd0, 4'd1, 32'd205};//{'src': 1, 'label': 205, 'op': 'jmp_if_false'}
    instructions[192] = {5'd2, 4'd7, 4'd5, 32'd0};//{'dest': 7, 'src': 5, 'op': 'move'}
    instructions[193] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[194] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[195] = {5'd13, 4'd2, 4'd7, 32'd48};//{'src': 7, 'right': 48, 'dest': 2, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[196] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[197] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[198] = {5'd2, 4'd10, 4'd2, 32'd0};//{'dest': 10, 'src': 2, 'op': 'move'}
    instructions[199] = {5'd0, 4'd9, 4'd0, 32'd2};//{'dest': 9, 'label': 2, 'op': 'jmp_and_link'}
    instructions[200] = {5'd6, 4'd1, 4'd0, 32'd1};//{'dest': 1, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[201] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[202] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[203] = {5'd2, 4'd6, 4'd1, 32'd0};//{'dest': 6, 'src': 1, 'op': 'move'}
    instructions[204] = {5'd11, 4'd0, 4'd0, 32'd205};//{'label': 205, 'op': 'goto'}
    instructions[205] = {5'd2, 4'd7, 4'd4, 32'd0};//{'dest': 7, 'src': 4, 'op': 'move'}
    instructions[206] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[207] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[208] = {5'd13, 4'd2, 4'd7, 32'd48};//{'src': 7, 'right': 48, 'dest': 2, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[209] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[210] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[211] = {5'd2, 4'd10, 4'd2, 32'd0};//{'dest': 10, 'src': 2, 'op': 'move'}
    instructions[212] = {5'd0, 4'd9, 4'd0, 32'd2};//{'dest': 9, 'label': 2, 'op': 'jmp_and_link'}
    instructions[213] = {5'd5, 4'd0, 4'd3, 32'd0};//{'src': 3, 'op': 'jmp_to_reg'}
    instructions[214] = {5'd6, 4'd11, 4'd0, 32'd0};//{'dest': 11, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[215] = {5'd6, 4'd0, 4'd0, 32'd0};//{'dest': 0, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[216] = {5'd6, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[217] = {5'd14, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'input': 'rs232_rx', 'op': 'read'}
    instructions[218] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[219] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[220] = {5'd2, 4'd0, 4'd1, 32'd0};//{'dest': 0, 'src': 1, 'op': 'move'}
    instructions[221] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[222] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[223] = {5'd2, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'src': 0, 'op': 'move'}
    instructions[224] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[225] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[226] = {5'd15, 4'd2, 4'd1, 32'd49};//{'src': 1, 'right': 49, 'dest': 2, 'signed': True, 'op': '==', 'size': 2}
    instructions[227] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[228] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[229] = {5'd16, 4'd0, 4'd2, 32'd251};//{'src': 2, 'label': 251, 'op': 'jmp_if_true'}
    instructions[230] = {5'd15, 4'd2, 4'd1, 32'd50};//{'src': 1, 'right': 50, 'dest': 2, 'signed': True, 'op': '==', 'size': 2}
    instructions[231] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[232] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[233] = {5'd16, 4'd0, 4'd2, 32'd263};//{'src': 2, 'label': 263, 'op': 'jmp_if_true'}
    instructions[234] = {5'd15, 4'd2, 4'd1, 32'd51};//{'src': 1, 'right': 51, 'dest': 2, 'signed': True, 'op': '==', 'size': 2}
    instructions[235] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[236] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[237] = {5'd16, 4'd0, 4'd2, 32'd275};//{'src': 2, 'label': 275, 'op': 'jmp_if_true'}
    instructions[238] = {5'd15, 4'd2, 4'd1, 32'd52};//{'src': 1, 'right': 52, 'dest': 2, 'signed': True, 'op': '==', 'size': 2}
    instructions[239] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[240] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[241] = {5'd16, 4'd0, 4'd2, 32'd287};//{'src': 2, 'label': 287, 'op': 'jmp_if_true'}
    instructions[242] = {5'd15, 4'd2, 4'd1, 32'd53};//{'src': 1, 'right': 53, 'dest': 2, 'signed': True, 'op': '==', 'size': 2}
    instructions[243] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[244] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[245] = {5'd16, 4'd0, 4'd2, 32'd299};//{'src': 2, 'label': 299, 'op': 'jmp_if_true'}
    instructions[246] = {5'd15, 4'd2, 4'd1, 32'd54};//{'src': 1, 'right': 54, 'dest': 2, 'signed': True, 'op': '==', 'size': 2}
    instructions[247] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[248] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[249] = {5'd16, 4'd0, 4'd2, 32'd311};//{'src': 2, 'label': 311, 'op': 'jmp_if_true'}
    instructions[250] = {5'd11, 4'd0, 4'd0, 32'd323};//{'label': 323, 'op': 'goto'}
    instructions[251] = {5'd6, 4'd1, 4'd0, 32'd1};//{'dest': 1, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[252] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[253] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[254] = {5'd2, 4'd11, 4'd1, 32'd0};//{'dest': 11, 'src': 1, 'op': 'move'}
    instructions[255] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[256] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[257] = {5'd2, 4'd2, 4'd11, 32'd0};//{'dest': 2, 'src': 11, 'op': 'move'}
    instructions[258] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[259] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[260] = {5'd2, 4'd4, 4'd2, 32'd0};//{'dest': 4, 'src': 2, 'op': 'move'}
    instructions[261] = {5'd0, 4'd3, 4'd0, 32'd7};//{'dest': 3, 'label': 7, 'op': 'jmp_and_link'}
    instructions[262] = {5'd11, 4'd0, 4'd0, 32'd328};//{'label': 328, 'op': 'goto'}
    instructions[263] = {5'd6, 4'd1, 4'd0, 32'd2};//{'dest': 1, 'literal': 2, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[264] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[265] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[266] = {5'd2, 4'd11, 4'd1, 32'd0};//{'dest': 11, 'src': 1, 'op': 'move'}
    instructions[267] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[268] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[269] = {5'd2, 4'd2, 4'd11, 32'd0};//{'dest': 2, 'src': 11, 'op': 'move'}
    instructions[270] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[271] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[272] = {5'd2, 4'd4, 4'd2, 32'd0};//{'dest': 4, 'src': 2, 'op': 'move'}
    instructions[273] = {5'd0, 4'd3, 4'd0, 32'd7};//{'dest': 3, 'label': 7, 'op': 'jmp_and_link'}
    instructions[274] = {5'd11, 4'd0, 4'd0, 32'd328};//{'label': 328, 'op': 'goto'}
    instructions[275] = {5'd6, 4'd1, 4'd0, 32'd3};//{'dest': 1, 'literal': 3, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[276] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[277] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[278] = {5'd2, 4'd11, 4'd1, 32'd0};//{'dest': 11, 'src': 1, 'op': 'move'}
    instructions[279] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[280] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[281] = {5'd2, 4'd2, 4'd11, 32'd0};//{'dest': 2, 'src': 11, 'op': 'move'}
    instructions[282] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[283] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[284] = {5'd2, 4'd4, 4'd2, 32'd0};//{'dest': 4, 'src': 2, 'op': 'move'}
    instructions[285] = {5'd0, 4'd3, 4'd0, 32'd7};//{'dest': 3, 'label': 7, 'op': 'jmp_and_link'}
    instructions[286] = {5'd11, 4'd0, 4'd0, 32'd328};//{'label': 328, 'op': 'goto'}
    instructions[287] = {5'd6, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[288] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[289] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[290] = {5'd2, 4'd11, 4'd1, 32'd0};//{'dest': 11, 'src': 1, 'op': 'move'}
    instructions[291] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[292] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[293] = {5'd2, 4'd2, 4'd11, 32'd0};//{'dest': 2, 'src': 11, 'op': 'move'}
    instructions[294] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[295] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[296] = {5'd2, 4'd4, 4'd2, 32'd0};//{'dest': 4, 'src': 2, 'op': 'move'}
    instructions[297] = {5'd0, 4'd3, 4'd0, 32'd7};//{'dest': 3, 'label': 7, 'op': 'jmp_and_link'}
    instructions[298] = {5'd11, 4'd0, 4'd0, 32'd328};//{'label': 328, 'op': 'goto'}
    instructions[299] = {5'd6, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[300] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[301] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[302] = {5'd2, 4'd11, 4'd1, 32'd0};//{'dest': 11, 'src': 1, 'op': 'move'}
    instructions[303] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[304] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[305] = {5'd2, 4'd2, 4'd11, 32'd0};//{'dest': 2, 'src': 11, 'op': 'move'}
    instructions[306] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[307] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[308] = {5'd2, 4'd4, 4'd2, 32'd0};//{'dest': 4, 'src': 2, 'op': 'move'}
    instructions[309] = {5'd0, 4'd3, 4'd0, 32'd7};//{'dest': 3, 'label': 7, 'op': 'jmp_and_link'}
    instructions[310] = {5'd11, 4'd0, 4'd0, 32'd328};//{'label': 328, 'op': 'goto'}
    instructions[311] = {5'd6, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[312] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[313] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[314] = {5'd2, 4'd11, 4'd1, 32'd0};//{'dest': 11, 'src': 1, 'op': 'move'}
    instructions[315] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[316] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[317] = {5'd2, 4'd2, 4'd11, 32'd0};//{'dest': 2, 'src': 11, 'op': 'move'}
    instructions[318] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[319] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[320] = {5'd2, 4'd4, 4'd2, 32'd0};//{'dest': 4, 'src': 2, 'op': 'move'}
    instructions[321] = {5'd0, 4'd3, 4'd0, 32'd7};//{'dest': 3, 'label': 7, 'op': 'jmp_and_link'}
    instructions[322] = {5'd11, 4'd0, 4'd0, 32'd328};//{'label': 328, 'op': 'goto'}
    instructions[323] = {5'd6, 4'd1, 4'd0, 32'd0};//{'dest': 1, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[324] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[325] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[326] = {5'd2, 4'd11, 4'd1, 32'd0};//{'dest': 11, 'src': 1, 'op': 'move'}
    instructions[327] = {5'd11, 4'd0, 4'd0, 32'd328};//{'label': 328, 'op': 'goto'}
    instructions[328] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[329] = {5'd2, 4'd1, 4'd11, 32'd0};//{'dest': 1, 'src': 11, 'op': 'move'}
    instructions[330] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[331] = {5'd3, 4'd0, 4'd0, 32'd0};//{'op': 'nop'}
    instructions[332] = {5'd17, 4'd0, 4'd1, 32'd0};//{'src': 1, 'output': 'leds', 'op': 'write'}
    instructions[333] = {5'd11, 4'd0, 4'd0, 32'd217};//{'label': 217, 'op': 'goto'}
    instructions[334] = {5'd5, 4'd0, 4'd8, 32'd0};//{'src': 8, 'op': 'jmp_to_reg'}
  end


  //////////////////////////////////////////////////////////////////////////////
  // CPU IMPLEMENTAION OF C PROCESS                                             
  //                                                                            
  // This section of the file contains a CPU implementing the C process.        
  
  always @(posedge clk)
  begin

    //implement memory for 2 byte x n arrays
    if (memory_enable_2 == 1'b1) begin
      memory_2[address_2] <= data_in_2;
    end
    data_out_2 <= memory_2[address_2];
    memory_enable_2 <= 1'b0;

    write_enable_2 <= 0;
    //stage 0 instruction fetch
    if (stage_0_enable) begin
      stage_1_enable <= 1;
      instruction_0 <= instructions[program_counter];
      opcode_0 = instruction_0[44:40];
      dest_0 = instruction_0[39:36];
      src_0 = instruction_0[35:32];
      srcb_0 = instruction_0[3:0];
      literal_0 = instruction_0[31:0];
      if(write_enable_2) begin
        registers[dest_2] <= result_2;
      end
      program_counter_0 <= program_counter;
      program_counter <= program_counter + 1;
    end

    //stage 1 opcode fetch
    if (stage_1_enable) begin
      stage_2_enable <= 1;
      register_1 <= registers[src_0];
      registerb_1 <= registers[srcb_0];
      dest_1 <= dest_0;
      literal_1 <= literal_0;
      opcode_1 <= opcode_0;
      program_counter_1 <= program_counter_0;
    end

    //stage 2 opcode fetch
    if (stage_2_enable) begin
      dest_2 <= dest_1;
      case(opcode_1)

        16'd0:
        begin
          program_counter <= literal_1;
          result_2 <= program_counter_1 + 1;
          write_enable_2 <= 1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd1:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd2:
        begin
          result_2 <= register_1;
          write_enable_2 <= 1;
        end

        16'd4:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
          s_output_rs232_tx_stb <= 1'b1;
          s_output_rs232_tx <= register_1;
        end

        16'd5:
        begin
          program_counter <= register_1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd6:
        begin
          result_2 <= literal_1;
          write_enable_2 <= 1;
        end

        16'd7:
        begin
          result_2 <= $unsigned(register_1) >= $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd8:
        begin
          if (register_1 == 0) begin
            program_counter <= literal_1;
            stage_0_enable <= 1;
            stage_1_enable <= 0;
            stage_2_enable <= 0;
          end
        end

        16'd9:
        begin
          result_2 <= $unsigned(register_1) - $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd10:
        begin
          result_2 <= $unsigned(register_1) + $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd11:
        begin
          program_counter <= literal_1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd12:
        begin
          result_2 <= $unsigned(register_1) | $unsigned(registerb_1);
          write_enable_2 <= 1;
        end

        16'd13:
        begin
          result_2 <= $unsigned(register_1) | $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd14:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
          s_input_rs232_rx_ack <= 1'b1;
        end

        16'd15:
        begin
          result_2 <= $signed(register_1) == $signed(literal_1);
          write_enable_2 <= 1;
        end

        16'd16:
        begin
          if (register_1 != 0) begin
            program_counter <= literal_1;
            stage_0_enable <= 1;
            stage_1_enable <= 0;
            stage_2_enable <= 0;
          end
        end

        16'd17:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
          s_output_leds_stb <= 1'b1;
          s_output_leds <= register_1;
        end

       endcase
    end
     if (s_output_rs232_tx_stb == 1'b1 && output_rs232_tx_ack == 1'b1) begin
       s_output_rs232_tx_stb <= 1'b0;
       stage_0_enable <= 1;
       stage_1_enable <= 1;
       stage_2_enable <= 1;
     end

    if (s_input_rs232_rx_ack == 1'b1 && input_rs232_rx_stb == 1'b1) begin
       result_2 <= input_rs232_rx;
       write_enable_2 <= 1;
       s_input_rs232_rx_ack <= 1'b0;
       stage_0_enable <= 1;
       stage_1_enable <= 1;
       stage_2_enable <= 1;
     end

     if (s_output_leds_stb == 1'b1 && output_leds_ack == 1'b1) begin
       s_output_leds_stb <= 1'b0;
       stage_0_enable <= 1;
       stage_1_enable <= 1;
       stage_2_enable <= 1;
     end

    if (timer == 0) begin
      if (timer_enable) begin
         stage_0_enable <= 1;
         stage_1_enable <= 1;
         stage_2_enable <= 1;
         timer_enable <= 0;
      end
    end else begin
      timer <= timer - 1;
    end

    if (rst == 1'b1) begin
      stage_0_enable <= 1;
      stage_1_enable <= 0;
      stage_2_enable <= 0;
      timer <= 0;
      timer_enable <= 0;
      program_counter <= 0;
      s_input_rs232_rx_ack <= 0;
      s_output_rs232_tx_stb <= 0;
      s_output_leds_stb <= 0;
    end
  end
  assign input_rs232_rx_ack = s_input_rs232_rx_ack;
  assign output_rs232_tx_stb = s_output_rs232_tx_stb;
  assign output_rs232_tx = s_output_rs232_tx;
  assign output_leds_stb = s_output_leds_stb;
  assign output_leds = s_output_leds;

endmodule
