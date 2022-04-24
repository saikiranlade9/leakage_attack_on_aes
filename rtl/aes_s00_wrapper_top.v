
`include "timescale.v"


module aes_s00_wrapper_top (pclk_00, presetn_00, paddr_00, pwdata_00, pprot_00, psel_00, penable_00, pwrite_00, pstrb_00, pready_00, pslverr_00, prdata_00);

`include "config_pkg.vh"

    // Ports of APB Slave Bus Interface S00
    input wire                                pclk_00;
    input wire                                presetn_00;    
    input wire    [APB_ADDR_WIDTH-1 : 0]      paddr_00;
    input wire    [APB_DATA_WIDTH-1 : 0]      pwdata_00;
    input wire    [2 : 0]                     pprot_00;
    input wire                                psel_00;
    input wire                                penable_00;
    input wire                                pwrite_00;
    input wire    [APB_STROBE_WIDTH-1 : 0]    pstrb_00; 
    output wire                               pready_00;
    output wire                               pslverr_00;
    output wire   [APB_DATA_WIDTH-1 : 0]      prdata_00;


    // Instantiation of APB Bus Interface S00 
    aes_apb_s00 U0(
            .PCLK(pclk_00),
            .PRESETn(presetn_00),
            .PADDR(paddr_00),
            .PWDATA(pwdata_00),
            .PPROT(pprot_00),
            .PSEL(psel_00),
            .PENABLE(penable_00),
            .PWRITE(pwrite_00),
            .PSTRB(pstrb_00),
            .PREADY(pready_00),
            .PSLVERR(pslverr_00),
            .PRDATA(prdata_00)
         );
        
endmodule
