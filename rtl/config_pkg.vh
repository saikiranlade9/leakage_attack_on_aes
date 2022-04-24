//--key
    parameter [127:0] AES_KEY = 128'h92AB3ADCF22C55724728BFA8C2C61ECD;


//--Slave Parameters     
     //Width of S_APB address bus 
    parameter integer APB_ADDR_WIDTH = 32;
    // Width of S_APB data bus 
    parameter integer APB_DATA_WIDTH = 32;
    // WIDTH of Strobe signal 
    parameter integer APB_STROBE_WIDTH = $ceil(APB_DATA_WIDTH/8);    
    
    
    //number of user logic slave registers with write access for respective slaves
    //AES
    parameter integer SLV_REGS_WRITE_00 = 9;
    //HASH
    parameter integer SLV_REGS_WRITE_01 = 17;
    
    
    //number of user logic slave registers with read access for respective slaves
    //AES
    parameter integer SLV_REGS_READ_00 = 8;
    //HASH
    parameter integer SLV_REGS_READ_01 = 8;
    
    
    // number of bits required to address user logic slave registers for respective slaves
    //AES
    parameter integer ADDR_BITS_FOR_SLV_REGS_00 = $clog2(SLV_REGS_READ_00 + SLV_REGS_WRITE_00);
    //HASH
    parameter integer ADDR_BITS_FOR_SLV_REGS_01 = $clog2(SLV_REGS_READ_01 + SLV_REGS_WRITE_01);
    
    
    // base address to write to the user logic registers for respective slaves
    //AES
    parameter BASE_ADDR_WRITE_00 = 32'h00000000;
    //HASH
    parameter BASE_ADDR_WRITE_01 = BASE_ADDR_WRITE_00 + (SLV_REGS_WRITE_00 + SLV_REGS_READ_00)*4;
    
    
    // base address to read from the user logic registers for respective slaves
    //AES
    parameter BASE_ADDR_READ_00 = BASE_ADDR_WRITE_00 + SLV_REGS_WRITE_00*4;
    //HASH
    parameter BASE_ADDR_READ_01 = BASE_ADDR_WRITE_01 + SLV_REGS_WRITE_01*4;
    
//--Master  parameters
    
    //Number of Slaves
    parameter integer NUMBER_OF_SLAVES = 7;
    
    //input and output widths of IPs
    parameter integer AES_TEXT_IN_WIDTH = 128;
    parameter integer AES_KEY_WIDTH = 128;
    parameter integer AES_CIPH_OUT_WIDTH = 128;
    parameter integer AES_INV_CIPH_OUT_WIDTH = 128;
    parameter integer HASH_IN_WIDTH = 512;
    parameter integer HASH_OUT_WIDTH = 256;
//    parameter integer PUF_CHALLENGE_WIDTH = 128;
//    parameter integer PUF_RESPONSE_WIDTH = 128;
//    parameter integer TRNG_OUT_WIDTH = 128;
//    parameter integer MULT_INP_WIDTH = 128;
//    parameter integer MULT_OUT_WIDTH = 128;
//    parameter integer ODOMETER_OUT_WIDTH = 128;
//    parameter integer ECC_OUT_WIDTH = 128;
    
    //width of the opertaion_type signal which is log2(#of operation types) and #of operation types = 17
    parameter integer OPERATION_TYPE_WIDTH = 5;
    
    //width of PSELx signal
    parameter integer PSELx_WIDTH = $clog2(NUMBER_OF_SLAVES);
    
    
    //HOST data parameters
    parameter integer MAX_INPUT_DATA_SIZE = 512;
    parameter integer MAX_OUTPUT_DATA_SIZE = 512;
    parameter integer HOST_INSTRUCT_SIZE = 6;