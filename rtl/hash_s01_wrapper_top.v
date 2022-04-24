
`include "timescale.v"

module hash_s01_wrapper_top(pclk_01, presetn_01, paddr_01, pwdata_01, pprot_01, psel_01, penable_01, pwrite_01, pstrb_01, pready_01, pslverr_01, prdata_01);

`include "config_pkg.vh"
  
      // Ports of APB Slave Bus Interface S00
      input wire                                pclk_01;
      input wire                                presetn_01;
      input wire    [APB_ADDR_WIDTH-1 : 0]      paddr_01;
      input wire    [APB_DATA_WIDTH-1 : 0]      pwdata_01;
      input wire    [2 : 0]                     pprot_01;
      input wire                                psel_01;
      input wire                                penable_01;
      input wire                                pwrite_01;
      input wire    [APB_STROBE_WIDTH-1 : 0]    pstrb_01; 
      output wire                               pready_01;
      output wire                               pslverr_01;
      output wire   [APB_DATA_WIDTH-1 : 0]      prdata_01;
      
      
    // Instantiation of APB Bus Interface S00 
     hash_apb_s01 U1(
        .PCLK(pclk_01),
        .PRESETn(presetn_01),
        .PADDR(paddr_01),
        .PWDATA(pwdata_01),
        .PPROT(pprot_01),
        .PSEL(psel_01),
        .PENABLE(penable_01),
        .PWRITE(pwrite_01),
        .PSTRB(pstrb_01),
        .PREADY(pready_01),
        .PSLVERR(pslverr_01),
        .PRDATA(prdata_01)
     );
         
        
endmodule

