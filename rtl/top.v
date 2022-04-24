
`include "timescale.v"

module top(clk, rstn, host_instruction, host_data, start, out, operation_done);

`include "config_pkg.vh"


    //Global Input signals and inputs from host
    input wire                              clk;
    input wire                              rstn;
    input wire  [HOST_INSTRUCT_SIZE-1:0]    host_instruction;
    input wire  [MAX_INPUT_DATA_SIZE-1:0]   host_data;
    input wire                              start;
    
    //output signals to host
    output wire operation_done;
	output wire [MAX_OUTPUT_DATA_SIZE-1:0] out;
	
	// signals from master
    wire                                PCLK;
    wire                                PRESETn;    
    wire    [APB_ADDR_WIDTH-1 : 0]      PADDR;
    wire    [APB_DATA_WIDTH-1 : 0]      PWDATA;
    wire    [2 : 0]                     PPROT;
    wire    [PSELx_WIDTH-1 :0]          PSELx;
    wire                                PENABLE;
    wire                                PWRITE;
    wire    [APB_STROBE_WIDTH-1 : 0]    PSTRB;
  
    wire                                PREADY;
    wire                                PSLVERR;
    wire    [APB_DATA_WIDTH-1 : 0]      PRDATA;
    
    
    reg pready;
    reg [APB_DATA_WIDTH-1 : 0] prdata;
    reg pslverr;
  
    
    wire PSEL_00, PSEL_01;   
       
    wire PREADY_00, PREADY_01;
   
    wire PSLVERR_00, PSLVERR_01;
   
    wire [APB_DATA_WIDTH-1 : 0] PRDATA_00, PRDATA_01;
   
    reg psel_00, psel_01;
       
    assign PSEL_00 = psel_00;
    assign PSEL_01 = psel_01;
    
    
      assign PREADY = pready;
      assign PRDATA = prdata;
      assign PSLVERR = pslverr;
    
    
    
    always@(*) begin
        prdata = 32'd0;
        pready = 1'b1;
        pslverr = 1'b0;
        case(PSELx)
            3'b000:
            begin
                prdata = 32'd0;
                pready = 1'b1;
                pslverr = 1'b0;
            end
            3'b001:
            begin
                prdata = PRDATA_00;
                pready = PREADY_00;
                pslverr = PSLVERR_00;
            end
            3'b010:
            begin
                prdata = PRDATA_01;
                pready = PREADY_01;
                pslverr = PSLVERR_01;
            end 
        endcase
   
    end
    
    always@(*) begin
        
        psel_00 = 1'b0;
        psel_01 = 1'b0;
        case(PSELx)
     
            3'b001: psel_00 = 1'b1;
            3'b010: psel_01 = 1'b1;
            3'b000: 
            begin
                psel_00 = 1'b0;
                psel_01 = 1'b0;
            end
        endcase
   
    end
    
    master_wrapper_top M00(
                            .host_instruction(host_instruction),
                            .host_data(host_data),
                            .start(start),
                            .operation_done(operation_done),
                            .out(out),
                            .PCLK(clk),
                            .PRESETn(rstn),
                            .PADDR(PADDR),
                            .PWDATA(PWDATA),
                            .PPROT(PPROT),
                            .PSELx(PSELx),
                            .PENABLE(PENABLE),
                            .PWRITE(PWRITE),
                            .PSTRB(PSTRB),
                            .PREADY(PREADY),
                            .PSLVERR(PSLVERR),
                            .PRDATA(PRDATA)
                            );
                            
    aes_s00_wrapper_top    S00(.pclk_00(clk),
                            .presetn_00(rstn),
                            .paddr_00(PADDR),
                            .pprot_00(PPROT),
                            .psel_00(PSEL_00),
                            .penable_00(PENABLE),
                            .pwrite_00(PWRITE),
                            .pwdata_00(PWDATA),
                            .pstrb_00(PSTRB),
                            .pready_00(PREADY_00),
                            .pslverr_00(PSLVERR_00),
                            .prdata_00(PRDATA_00)
                            ); 
                            
     hash_s01_wrapper_top    S01(.pclk_01(clk),
                            .presetn_01(rstn),
                            .paddr_01(PADDR),
                            .pprot_01(PPROT),
                            .psel_01(PSEL_01),
                            .penable_01(PENABLE),
                            .pwrite_01(PWRITE),
                            .pwdata_01(PWDATA),
                            .pstrb_01(PSTRB),
                            .pready_01(PREADY_01),
                            .pslverr_01(PSLVERR_01),
                            .prdata_01(PRDATA_01)
                            ); 
    
endmodule
