
`include "timescale.v"

// aes encryption and decryption can be verified using in the below link
// http://aes.online-domain-tools.com/

// sha256 hashing can be verified using the link below
// https://emn178.github.io/online-tools/sha256.html

// do not forget to remove the underscores and choose Hex for input format 

module top_tb();

`include "config_pkg.vh"

    //input from host
    reg clk, rstn;
    reg [HOST_INSTRUCT_SIZE-1:0] host_instruction;
    reg [MAX_INPUT_DATA_SIZE-1:0] host_data;
    reg start;
    wire operation_done;
    wire [MAX_OUTPUT_DATA_SIZE-1:0] out;
    
    reg [7:0] buffer[0:16]; //stores leaked bytes
    
    //regs for deriving the keys
    reg [31:0] w0;
    reg [31:0] w1;
    reg [31:0] w2;
    reg [31:0] w3;
    
    reg [31:0] k0;
    reg [31:0] k1;
    reg [31:0] k2;
    reg [31:0] k3;
    wire [31:0] s_box_k3;
    reg [31:0] ls_k3;
    reg [7:0] d;
    
    //constants used in each round
    reg [31:0] rcon[9:0];
    
    integer i;
    
    top U0 (.clk(clk),
                        .rstn(rstn),
                        .host_instruction(host_instruction),
                        .host_data(host_data),
                        .start(start),
                        .operation_done(operation_done),
                        .out(out));
                        
    aes_sbox t0(	.a(	k3[7:0]	),  .d(	s_box_k3[7:0]));
    aes_sbox t1(	.a(	k3[15:8]),  .d(	s_box_k3[15:8]));
    aes_sbox t2(	.a(	k3[23:16]), .d(	s_box_k3[23:16]));
    aes_sbox t3(	.a(	k3[31:24]), .d(	s_box_k3[31:24]));
                       
    always #10 clk = !clk;
 
    //initialize constants in each round
  initial begin
    rcon[9] = 32'h36000000;
    rcon[8] = 32'h1b000000;
    rcon[7] = 32'h80000000;
    rcon[6] = 32'h40000000;
    rcon[5] = 32'h20000000;
    rcon[4] = 32'h10000000;
    rcon[3] = 32'h08000000;
    rcon[2] = 32'h04000000;
    rcon[1] = 32'h02000000;
    rcon[0] = 32'h01000000;
  end
  
   
  initial begin
    
    $display("Running the test...");
    //initialize
    clk = 1;
    start = 0;
    host_data = 0;
    
    $display("Resetting.....");
    //reset
    rstn = 0;
    #200; 
    rstn = 1;
    
    $display("Testing normal operation of the SoC i.e when trojan is dormant");
    //Normal operation
    //#######################################################################################################################################################################
    
    $display("Testing AES encryption....");
    //AES encrypt    
    @(negedge clk);
    host_instruction = 6'b010001; //instruction code for aes encryption
    start = 1;
    $display("encrypting the input 8EE2ABA3_45A66158_C6E2B9C7_FD961E63", );
    host_data = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_8EE2ABA3_45A66158_C6E2B9C7_FD961E63;
    wait(operation_done == 1);
    @(posedge clk);
    $display("done encrypting...");
    @(posedge clk);
    if(out[127:0] == 128'h09CA61C6_815C88AE_EC99E42B_B97897A3)
        $display("encrypted output: %0h", out[127:0]);
    else $display("ERROR: encryption FAILED!!!");
    
    start = 0;
    host_instruction = 0;
    
    $display("Testing AES decryption....");
    //AES decrypt
    #40
    @(negedge clk);
    host_instruction = 6'b010010; //instruction code for aes decrypt
    start = 1;
    $display("decrypting the input 09CA61C6_815C88AE_EC99E42B_B97897A3", );
    host_data = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_09CA61C6_815C88AE_EC99E42B_B97897A3;
    wait(operation_done == 1);
    @(posedge clk);
    $display("done decrypting...");
    @(posedge clk);
    if(out[127:0] == 128'h8EE2ABA3_45A66158_C6E2B9C7_FD961E63)
        $display("decrypted output: %0h", out[127:0]);
    else $display("ERROR: decryption FAILED!!!");
    
    start = 0;
    host_instruction = 0;
    
    $display("Testing HASH....");
    //HASH
    #40
    @(negedge clk);
    host_instruction = 6'b010011; // instruction code for hashing
    start = 1;
    $display("hasing the input 860DB270_4B66B7D7_AAACC7BF_99A96676_15830CCC_D4F5BEAE_F39D0732_F59F3353_FD4112D9_E766E716_180A78BC_02ADE113_93214E11_F75EFD04_E5AB1327_64B07860", );
    host_data = 512'h860DB270_4B66B7D7_AAACC7BF_99A96676_15830CCC_D4F5BEAE_F39D0732_F59F3353_FD4112D9_E766E716_180A78BC_02ADE113_93214E11_F75EFD04_E5AB1327_64B07860;
    wait(operation_done == 1);
    @(posedge clk);
    $display("done hashing...");
    @(posedge clk);
    if(out[255:0] == 256'hCC203794_EDC255B7_0A068A84_861184E4_2C4ADD0C_D50B8AE5_3B99FD0D_3E3F0463)
        $display("hashed output: %0h", out[255:0]);
    else $display("ERROR: hashing FAILED!!!");
    
    start = 0;
    host_instruction = 0;
    
    
    //#######################################################################################################################################################################
   
   
   
    $display("activating the trojan by feeding 1499325D_65411CD9_7031755A_0784CF24 as input to the aes ecrypt IP.");
    //trigger trojan and leak key
    //16 tests are nescessary to leak the entire key because aes leaks a byte at a time.
    //activate the trojan by feeding ''1499325D_65411CD9_7031755A_0784CF24'' as input text,
    //#######################################################################################################################################################################
    for(i=0; i<16; i=i+1) begin
        //AES encrypt
        #40; 
        @(negedge clk);
        host_instruction = 6'b010001;
        start = 1;
        host_data = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_1499325D_65411CD9_7031755A_0784CF24;
        
        wait(operation_done == 1);
        @(posedge clk);
        @(posedge clk);
        buffer[i+1] = (out[127:0] /(2 ** (128 - (i+1)*8)) % 256);
        
        $display("Test Number:%0d, byte(%0d) of word(%0d) is leaked: %0h in %0h", i+1, 4-(i%4), i/4, buffer[i+1], out[127:0]);
        
        start = 0;
        host_instruction = 0;
   end
    //#######################################################################################################################################################################    
        
        
        
        
    w3 = {buffer[13], buffer[14], buffer[15], buffer[16]};
    w2 = {buffer[9], buffer[10], buffer[11], buffer[12]};
    w1 = {buffer[5], buffer[6], buffer[7], buffer[8]};
    w0 = {buffer[1], buffer[2], buffer[3], buffer[4]};
    
    $display("final round key {w0, w1, w2, w3}: %0h", {w0, w1, w2, w3});
   
    for(i=9; i>=0; i=i-1) begin
         $display("##################### ROUND %0d  #####################", i);
        //step1
        k3 = w3 ^ w2;
        k2 = w2 ^ w1;
        k1 = w1 ^ w0;
        k0 = w0;
        //$display("round: %0d, step: 01, key: %0h", i, {k0, k1, k2, k3});
        
        //step2
        #20
        k0 = k0 ^ rcon[i];
        //$display("round: %0d, step: 02, key: %0h", i, {k0, k1, k2, k3});
        
        //step3
        #20
        ls_k3 = {s_box_k3[23:0], s_box_k3[31:24]};
        k0 = k0 ^ ls_k3;
        #20
        $display("round: %0d, key: %0h", i, {k0, k1, k2, k3});
        
        w3 = k3;
        w2 = k2;
        w1 = k1;
        w0 = k0;     
    end
    $display("#######################################################");
    
    $display("");
    $display("#######################################################");
    $display("#######################################################");
    $display("");
    $display("leaked key after processing: %0h", {k0, k1, k2, k3});
    $display("");
    $display("#######################################################");
    $display("#######################################################");    
      #200 $finish;

end
  
 
endmodule