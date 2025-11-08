
`timescale 1ns / 1ps

module apb_testbench;

    // Clock and reset
    reg pclk;
    reg presetn;

    // Control signals
    reg transfer, read, write;
    reg [8:0] apb_write_paddr;
    reg [7:0] apb_write_data;
    reg [8:0] apb_read_paddr;

    // Outputs
    wire pslverr;
    wire [7:0] apb_read_data_out;

    // Generate clock
    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk;
    end

    // Connect to main design
    apb_top dut (
        .pclk(pclk),
        .presetn(presetn),
        .transfer(transfer),
        .read(read),
        .write(write),
        .apb_write_paddr(apb_write_paddr),
        .apb_write_data(apb_write_data),
        .apb_read_paddr(apb_read_paddr),
        .pslverr(pslverr),
        .apb_read_data_out(apb_read_data_out)
    );

    // Reset the system
    task reset_system;
        begin
            presetn = 0;  // Active reset
            transfer = 0;
            read = 0;
            write = 0;
            apb_write_paddr = 0;
            apb_write_data = 0;
            apb_read_paddr = 0;
            #20;
            presetn = 1;  // Release reset
            #10;
        end
    endtask

    // Write data to address
    task write_data;
        input [8:0] address;
        input [7:0] data;
        begin
            transfer = 1;
            write = 1;
            apb_write_paddr = address;
            apb_write_data = data;
            #30;  // Complete transfer
            transfer = 0;
            write = 0;
            #10;
        end
    endtask

    // Read data from address
    task read_data;
        input [8:0] address;
        begin
            transfer = 1;
            read = 1;
            apb_read_paddr = address;
            #30;  // Complete transfer
            transfer = 0;
            read = 0;
            #10;
        end
    endtask

    // Run tests
    initial begin
        reset_system;
        
        // Test 1: Simple write
        write_data(9'h005, 8'hAA);
        
        // Test 2: Simple read
        read_data(9'h005);
        
        // Test 3: Write to different slaves
        write_data(9'h005, 8'hA5);  // Slave 1
        write_data(9'h085, 8'h5A);  // Slave 2
        
        // Test 4: Multiple operations
        write_data(9'h010, 8'h11);
        read_data(9'h010);
        write_data(9'h020, 8'h22);
        read_data(9'h020);
        
        // Test 5: Check error for invalid address
        write_data(9'h1FF, 8'hFF);
        
        // Test 6: Reset during operation
        write_data(9'h030, 8'h33);
        reset_system;
        
        $finish;
    end

endmodule