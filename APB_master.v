module apb_master (
    input wire presetn,                
    input wire pclk,                   
    input wire transfer,               
    input wire read,                   
    input wire write,                 
    input wire [8:0] apb_write_paddr,   //depend on rage select the slave
    input wire [7:0] apb_write_data,   
    input wire [8:0] apb_read_paddr,   
    input wire pready,                  
    input wire pslverr,                 
    input wire [7:0] prdata,            

    output reg psel1,                
    output reg psel2,                  
    output reg penable,               
    output reg pwrite,              
    output reg [8:0] paddr,           
    output reg [7:0] pwdata,            
    output reg [7:0] apb_read_data_out 
);

    // finite state machine  
    parameter IDLE = 2'b00;
    parameter SETUP = 2'b01;
    parameter ENABLE = 2'b10;

    reg [1:0] state;          // Current state
    reg [1:0] next_state;     // Next state

    // logic state 
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) //  reset is active  
            state <= IDLE;    // Reset to IDLE state
        else
            state <= next_state;
    end

    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            apb_read_data_out <= 8'h00;
        end else if (state == ENABLE && pready && read && !write) begin
            apb_read_data_out <= prdata; // Capture data on clock edge
        end
    end

    // Combinational next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (transfer)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end
            SETUP: begin
                next_state = ENABLE;  // Always move to ENABLE from SETUP
            end
            ENABLE: begin
                if (pready)
                    next_state = (transfer) ? SETUP : IDLE;
                else
                    next_state = ENABLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // output logic 
    always @(*) begin
        
        psel1 = 0;
        psel2 = 0;
        penable = 0;
        pwrite = 0;
        paddr = 9'b0;
        pwdata = 8'b0;

        case (state)
            IDLE: begin
                // no activity 
            end
            SETUP: begin
                penable = 0;
                if (read && !write) begin
                    paddr = apb_read_paddr;             
                    psel1 = (apb_read_paddr[8] == 0);   // Select slave 1 for lower addresses
                    psel2 = (apb_read_paddr[8] == 1);   // Select slave 2 for higher addresses
                    pwrite = 0;                         // Set for read operation
                end
                else if (write && !read) begin
                    paddr = apb_write_paddr;                // Load write address
                    psel1 = (apb_write_paddr[8] == 0);
                    psel2 = (apb_write_paddr[8] == 1);
                    pwrite = 1;                            // Set for write operation
                    pwdata = apb_write_data;               // Load write data
                end
            end
            ENABLE: begin
                penable = 1;  // Enable the transfer
                
                    
                end
        endcase
    end

endmodule

