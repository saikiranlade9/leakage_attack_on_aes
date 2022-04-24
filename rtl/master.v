`include "timescale.v"

module master #(
	parameter integer INSTRUCT_SIZE = 4,
	parameter integer HOST_INSTRUCT_SIZE = 6,
	parameter SECURE_FUNC_ENC = 2'b10,
	parameter NON_SECURE_FUNC_ENC = 2'b01,
	parameter INSTRUCT_ENCRPT   = 4'b0001,
	parameter INSTRUCT_DECRPT   = 4'b0010,
	parameter INSTRUCT_HASH     = 4'b0011,
	parameter integer NO_OF_SLAVE = 7,
	
	//
	parameter integer ADDR_BUS_WIDTH = 32,
	parameter integer DATA_BUS_WIDTH = 32,
	parameter integer INPUT_DATA_SIZE = 128,
	parameter integer MAX_INPUT_DATA_SIZE = 512,
	parameter integer AES_TEXT_KEY_SIZE = 128,
	parameter integer HASH_INPUT_SIZE = 512,
	parameter integer HASH_OUTPUT_SIZE = 256,
	parameter integer MAX_OUTPUT_DATA_SIZE = 512,
	//
	parameter integer OPERATION_ENCODE_SIZE = 5,
	parameter ENCRPT_WRITE_ENCODE   = 5'b00001,
	parameter DECRPT_WRITE_ENCODE   = 5'b00010,
	parameter HASH_WRITE_ENCODE     = 5'b00101,
	parameter ENCRPT_READ_ENCODE    = 5'b01001,
	parameter DECRPT_READ_ENCODE    = 5'b01010,
	parameter HASH_READ_ENCODE      = 5'b01101,
	
	parameter total_number_byte_size = 8,
	parameter enable_data_out_size = 32,
	parameter test_response_size = 32,
	parameter KS_value_size = 4,
	parameter P_value_size = 4,
	parameter capture_count_size = 16,
	parameter Private_key_chip_size = 128,
	parameter hash_output_size = 256,
	
	//Base addresses
	parameter AES_WRITE_BASE_ADDR = 32'h00000000,
	parameter AES_READ_BASE_ADDR = 32'h00000190,
	parameter HASH_WRITE_BASE_ADDR = 32'h00000640,
	parameter HASH_READ_BASE_ADDR= 32'h000007D0



)
( clk, rstn, host_instruction, host_data, write_complete, text_out, key_out, operation_type, hash_out, 
encrypt_output_data_port, decrypt_output_data_port, hash_output_port, 
data_input_ready, init_transaction, start, operation_done, out


    );
    
    //Global Input signals and inputs from host
    input clk, rstn;
    input [HOST_INSTRUCT_SIZE-1:0] host_instruction;
    input [MAX_INPUT_DATA_SIZE-1:0] host_data;
    input start;
    
    //Inputs from SAP master wrapper for internal transactions
    
    input data_input_ready;
    input write_complete;
    input [AES_TEXT_KEY_SIZE-1:0] encrypt_output_data_port, decrypt_output_data_port;
    input [HASH_OUTPUT_SIZE-1:0] hash_output_port;
    
    //output signals to host
    //output reg busy;
    output reg operation_done;
	output reg [MAX_OUTPUT_DATA_SIZE-1:0] out;
    
    //Output signals to wrapper for internal transactions
   
    output reg [AES_TEXT_KEY_SIZE-1:0] text_out;
    output reg [AES_TEXT_KEY_SIZE-1:0] key_out;
    output reg [HASH_INPUT_SIZE-1:0] hash_out;
    output reg [OPERATION_ENCODE_SIZE-1:0] operation_type;
    output reg init_transaction;
    
    reg [MAX_INPUT_DATA_SIZE-1:0] input_data_port;
    wire [MAX_INPUT_DATA_SIZE-1:0] internal_data_port;
    wire [HASH_INPUT_SIZE-1:0] hash_input;
    wire [1:0] secure_or_non;
    reg input_select;
    reg [INSTRUCT_SIZE-1:0] input_instuct;
    reg [AES_TEXT_KEY_SIZE-1:0] encrypt_output, decrypted_output;
    reg [HASH_OUTPUT_SIZE-1:0] hash_output;
    reg encrypt_output_ready, decrypt_output_ready, hash_output_ready;
    reg input_data_transfer_complete;
    reg non_secure_func_start;
    reg secure_func_start;
    reg [INSTRUCT_SIZE-1:0] sap_secure_instruction;
    reg [NO_OF_SLAVE-1:0] slave_busy;
    reg write_start, read_start;

    //Input select determines whether the input is coming from HOST processor 
    
	always @(input_select or host_data or internal_data_port)
		begin
			if (input_select  == 0)
				input_data_port <= host_data;
			else 
				input_data_port <= internal_data_port;
		end
    
    assign secure_or_non = host_instruction[HOST_INSTRUCT_SIZE-1:HOST_INSTRUCT_SIZE-2];
    
    // Instruction decode for secure and non-secure task. assignment of input_instuct
    
    always @(posedge clk )
    begin
        if (rstn == 0)
            begin
                input_instuct <= 0;
                input_select <= 0;
            end
        else 
            begin
                if (secure_or_non == NON_SECURE_FUNC_ENC)
                    begin
                        input_instuct <= host_instruction[HOST_INSTRUCT_SIZE-3:0];
                        input_select <= 0;
                    end
                else if (secure_or_non == SECURE_FUNC_ENC)
                    begin
                        input_instuct <= sap_secure_instruction;
                        input_select <= 1;
                    end
            end
    end
	
	// output to host
	
	always @(posedge clk)
		begin
			if (rstn == 0)
				begin
					out <= 0;
				end
				
			else 
				begin
					if (operation_done == 1)
						begin
							case (input_instuct)
									INSTRUCT_ENCRPT  : begin out[AES_TEXT_KEY_SIZE-1:0] <= encrypt_output; end
									INSTRUCT_DECRPT  : begin out[AES_TEXT_KEY_SIZE-1:0] <= decrypted_output; end
									INSTRUCT_HASH    : begin out[HASH_OUTPUT_SIZE-1:0] <= hash_output; end
							endcase
						end
						
				end
		
		end
    
    // Determining if any slave is busy or idle
    
    always @(posedge clk)
        begin
            if (rstn == 0)
                begin
                    slave_busy <= 0;
                end
              
             else if (write_complete == 1)
                begin
                    case (input_instuct)
                        INSTRUCT_ENCRPT  : begin slave_busy[0] <= 1; end
                        INSTRUCT_DECRPT  : begin slave_busy[0] <= 1; end
                        INSTRUCT_HASH    : begin slave_busy[1] <= 1; end
                     endcase
                end
             else if (input_data_transfer_complete == 1)
                begin
                    case (input_instuct)
                        INSTRUCT_ENCRPT  : begin slave_busy[0] <= 0; end
                        INSTRUCT_DECRPT  : begin slave_busy[0] <= 0; end
                        INSTRUCT_HASH    : begin slave_busy[1] <= 0; end
                     endcase
                end
  
        end
        
   
    //Registers to store the read data from slaves
     always @(posedge clk) begin
        if (rstn == 0) begin
          
			encrypt_output <= 0;
			decrypted_output <= 0;
			hash_output <= 0;
			input_data_transfer_complete <= 0;
        end
        
     else if (encrypt_output_ready == 1) 
        begin
            encrypt_output <= encrypt_output_data_port;  
            input_data_transfer_complete <= 1;
        end   
     else if (decrypt_output_ready == 1)  
        begin      
            decrypted_output <= decrypt_output_data_port;  
            input_data_transfer_complete <= 1;
        end
     else if (hash_output_ready == 1)       
        begin 
            hash_output <= hash_output_port;        
            input_data_transfer_complete <= 1;
        end    
  
    //#################################################################################
    else
        input_data_transfer_complete <= 0;
     end
     //#################################################################################
     
    //FSM for managing read and write to the components
    localparam   IDLE  = 'd0,
                WRITE = 'd1,
                READ  = 'd2,
                WRITE_DONE  = 'd3,
                READ_DONE = 'd4;
        
    reg [2:0] state, next_state;
            
    always @(posedge clk)
    begin
        if (rstn == 0)
            state <= IDLE;
        else 
            state <= next_state;
    end
    
    always @(*)
    begin
    
        next_state <= state;
        init_transaction <= 0;

        text_out <= 0;
        key_out <= 0;
        operation_type <= 0;
        hash_out <= 0;
        encrypt_output_ready <= 0;
        decrypt_output_ready <= 0;
        hash_output_ready <= 0;
        
        case(state)
            IDLE:   begin
                        if (write_start == 1)
                            next_state <= WRITE;
                        else if (read_start == 1)
                            next_state <= READ;
                        else 
                            next_state <= IDLE;
                    end
                    
             WRITE: begin    
                         if (write_complete == 1)
                            begin
                                init_transaction <= 0;
                                next_state <= WRITE_DONE;
                            end
                         else 
                                next_state <= WRITE;
                              
                                            
                       case (input_instuct)
                       INSTRUCT_ENCRPT:     begin
                                                    
                                                    if (input_data_port != 0)
                                                    begin
                                                            text_out <= input_data_port[AES_TEXT_KEY_SIZE-1:0];
                                                            key_out <= input_data_port[AES_TEXT_KEY_SIZE*2-1:AES_TEXT_KEY_SIZE];
                                                            operation_type <= ENCRPT_WRITE_ENCODE;
                                                            init_transaction <= 1;
                                                           
                                                    end
                                                                                                     
                                            end
                                            
                       INSTRUCT_DECRPT:     begin
                                                    if (input_data_port != 0)
                                                    begin
                                                            text_out <= input_data_port[AES_TEXT_KEY_SIZE-1:0];
                                                            key_out <= input_data_port[AES_TEXT_KEY_SIZE*2-1:AES_TEXT_KEY_SIZE];
                                                            operation_type <= DECRPT_WRITE_ENCODE;
                                                            init_transaction <= 1;
                                                       
                                                    end
                                                                                                      
                                            end 
                                            
                       INSTRUCT_HASH:       begin
                                                    if (input_data_port != 0)
                                                    begin
                                                            hash_out <= input_data_port[HASH_INPUT_SIZE-1:0];
                                                            operation_type <= HASH_WRITE_ENCODE;
                                                            init_transaction <= 1;
                                                        
                                                    end
                                                    
                                            end 
                                        
                       endcase                   
                    end
                    
             READ: begin
                            
                         if (input_data_transfer_complete == 1) 
                            begin
                                init_transaction <= 0;
                                next_state <= READ_DONE;
                            end
                         else 
                            begin
                                next_state <= READ;
                            end
                            
                        case (input_instuct)
                        
                        INSTRUCT_ENCRPT:    begin
                                                operation_type <= ENCRPT_READ_ENCODE;
                                                init_transaction <= 1;
                                                //#################################################################################
                                                if (data_input_ready == 1 )
                                                begin 
                                                    encrypt_output_ready <= 1;
                                                    init_transaction <= 0;
                                                end
                                                //#################################################################################
                                                
 
                                            end
                                            
                        INSTRUCT_DECRPT:    begin
                                                operation_type <= DECRPT_READ_ENCODE;
                                                init_transaction <= 1;
                                                //#################################################################################
                                                if (data_input_ready == 1 )
                                                begin 
                                                    decrypt_output_ready <= 1;
                                                    init_transaction <= 0;
                                                end
                                                //#################################################################################
 
                                            end
                                            
                        INSTRUCT_HASH:      begin
                                                 operation_type <= HASH_READ_ENCODE;
                                                 init_transaction <= 1;
                                                 
                                                 if (data_input_ready == 1 ) 
                                                 begin
                                                    hash_output_ready <= 1;
                                                    init_transaction <= 0;
                                                 end
                                                      
                                            end
                                            
                        
                        endcase
                    end
                    
             WRITE_DONE: begin
//                            done_write <= 1;
                            if (write_start == 0)
                                next_state <= IDLE;
                            else 
                                next_state <= WRITE_DONE;
                         end   
                         
             READ_DONE: begin
//                            done_read <= 1;                                
                            if (read_start == 0)
                                next_state <= IDLE;
                            else 
                                next_state <= READ_DONE;
                        end
             
             default: 
                            next_state <= IDLE;
        endcase
    
    end
    
    // FSM Controller 
     localparam  SAP_IDLE     = 'd0,
                SAP_S_OR_NS  = 'd1,
                SAP_NS_WRITE = 'd2,
                SAP_NS_READ  = 'd3,  
                SAP_NS_DONE  = 'd4,
                SAP_S_WRITE  = 'd5;
                
     reg [3:0] sap_state, sap_next_state;
     
     always @(posedge clk)
        begin
            if (rstn == 0)
                sap_state <= SAP_IDLE;
            else 
                sap_state <= sap_next_state;
        end
    
    always @(*)
        begin
            operation_done <= 0;
            sap_next_state <= sap_state;
            write_start <= 0;
            read_start <= 0;
            
            case(sap_state)
                SAP_IDLE:   begin
                                if (start == 1)
                                    sap_next_state <= SAP_S_OR_NS;
                                else 
                                    sap_next_state <= SAP_IDLE;
                            end
                            
                SAP_S_OR_NS: begin
                                if (secure_or_non == NON_SECURE_FUNC_ENC) 
                                    sap_next_state <= SAP_NS_WRITE;    
                                else 
                                    sap_next_state <= SAP_S_WRITE; 
                              end  
                SAP_NS_WRITE: begin
                                    write_start <= 1;
                                    //#################################################################################
                                    if (write_complete == 1)
                                    //#################################################################################
                                        sap_next_state <= SAP_NS_READ;  
                                    else 
                                        sap_next_state <= SAP_NS_WRITE; 
                              end
                SAP_NS_READ: begin
                                    write_start <= 0;
                                    read_start <= 1;
                                    //#################################################################################
                                    if (data_input_ready == 1)
                                    //#################################################################################
                                        sap_next_state <= SAP_NS_DONE;  
                                    else 
                                        sap_next_state <= SAP_NS_READ; 
                              end     
                SAP_NS_DONE:  begin
                                    read_start <= 0;
                                    operation_done <= 1;
                                    if (start == 0)
                                        sap_next_state <= SAP_IDLE;  
                                    else 
                                        sap_next_state <= SAP_NS_DONE; 
                              end                   
                        
            endcase
        end
endmodule
