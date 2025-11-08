module apb_slave (
    input wire pclk,              
    input wire presetn,         
    input wire psel,            
    input wire penable,         
    input wire pwrite,           
    input wire [7:0] paddr,      
    input wire [7:0] pwdata,    
    output reg [7:0] prdata,     
    output reg pready,          
    output reg pslverr           
);

    // Internal memory
    reg [7:0] memory [255:0];

    
    reg [7:0] addr_reg; // Stores values between clock cycles

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 8'h00;
        end
        pready = 1'b0;
        pslverr = 1'b0;
        prdata = 8'h00;
    end


    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            pready <= 1'b0;
            pslverr <= 1'b0;
            prdata <= 8'h00;
            addr_reg <= 8'b0;
        end else begin

            pready <= 1'b0;
            pslverr <= 1'b0;

            if (psel && penable) begin  // Only respond when both psel and penable are high
            // Handle Read Operations
            if (!pwrite) begin
                if (paddr <= 8'd255) begin
                    prdata <= memory[paddr];
                    pready <= 1'b1;
                end else begin
                    pslverr <= 1'b1;
                    pready <= 1'b1;
                end
            end
            // Handle Write Operations
            else begin
                if (paddr <= 8'd255) begin
                    memory[paddr] <= pwdata;
                    pready <= 1'b1;
                end else begin
                    pslverr <= 1'b1;
                    pready <= 1'b1;
                end
            end
        end
    end
end

endmodule