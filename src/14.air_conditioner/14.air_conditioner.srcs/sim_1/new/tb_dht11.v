`timescale 1ns / 1ps

module tb_dht11;

    // DUT Inputs
    reg clk = 0;
    reg reset;

    // DUT Outputs
    wire [7:0] humidity;
    wire [7:0] current_temperature;

    // DUT Inout
    wire dht11_data;

    // Testbench internal signals for controlling the inout pin
    reg dht_out_tb; // Testbench's output driver
    reg dht_en_tb;  // Testbench's output enable (1 to drive, 0 for high-Z)

    reg [39:0] sensor_data;

    // Connect the testbench driver to the DUT's inout pin
    // When dht_en_tb is 0, the line is high-impedance, allowing the DUT to drive it.
    assign dht11_data = dht_en_tb ? dht_out_tb : 1'bz;

    // Instantiate the Device Under Test (DUT)
    // Override parameters for faster simulation.
    // We change the initial wait time to 10ms.
    // 10ms requires 1,000,000 cycles with a 100MHz clock.
    dht11_controller #(
        .WAIT_SECOND(1),
        .COUNT_1S(1_000_000) // 10ms in cycles
    ) dut (
        .clk(clk),
        .reset(reset),
        .humidity(humidity),
        .current_temperature(current_temperature),
        .dht11_data(dht11_data)
    );

    // Clock generation (100MHz clock, 10ns period)
    always #5 clk = ~clk;

    // Task to simulate the DHT11 sensor sending data
    task send_dht_data;
        input [39:0] data_to_send;
        integer i;
    begin
        // 1. Wait for the DUT to start communication by pulling the line low
        @(negedge dht11_data);
        $display("[%0t ns] DUT has initiated the start signal (line is LOW).", $time);

        // 2. Wait for the DUT to pull the line high (start of 30us pulse)
        @(posedge dht11_data);
        $display("[%0t ns] DUT started its 30us HIGH pulse. Waiting for it to finish.", $time);

        // --- ✨ 핵심 수정: 버스 충돌을 피하기 위해 대기 ---
        // DUT가 30us 동안 버스를 사용하므로, 끝날 때까지 기다려줍니다. (여유있게 31us)
        #31000; 
        // 이제 DUT는 입력 모드로 전환했고, 버스는 테스트벤치가 사용 가능합니다.
        // --- END OF FIX ---

        // 3. Sensor (Testbench) response signal: 80us LOW followed by 80us HIGH
        dht_en_tb <= 1;   // 테스트벤치가 버스 제어를 시작
        dht_out_tb <= 0;
        #80000;         // 80us LOW
        dht_out_tb <= 1;
        #80000;         // 80us HIGH
        $display("[%0t ns] Testbench has sent the response signal.", $time);

        // 4. Send the 40 bits of data
        for (i = 39; i >= 0; i = i - 1) begin
            dht_out_tb <= 0;
            #50000;
            
            dht_out_tb <= 1;
            if (data_to_send[i] == 1'b1) begin
                #70000;
            end else begin
                #28000;
            end
        end
        $display("[%0t ns] Testbench has finished sending 40 bits of data.", $time);

        // 5. Release the data line
        dht_en_tb <= 0;
    end
    endtask


    // Main test sequence
    initial begin
        // 1. Initialize signals and apply reset
        reset = 1;
        dht_en_tb = 0; // Start with the line in high-impedance
        dht_out_tb = 1;

        #20; // Wait for a few clock cycles
        reset = 0;
        
        // Data to be sent:
        // Humidity:    40% (Integer: 40 = 8'h28, Decimal: 0 = 8'h00)
        // Temperature: 27C (Integer: 27 = 8'h1B, Decimal: 0 = 8'h00)
        // Checksum:    0x28 + 0x00 + 0x1B + 0x00 = 0x43
        sensor_data = {8'h28, 8'h00, 8'h1B, 8'h00, 8'h43};

        // 2. Call the task to simulate the sensor behavior
        send_dht_data(sensor_data);

        // 3. Wait for the DUT to process the data and update outputs
        #1000000;

        // 4. Check the results and print status
        $display("-----------------------------------------------------");
        $display("[%0t ns] Final Check:", $time);
        $display("Expected Humidity: 40,    Actual Humidity: %d", humidity);
        $display("Expected Temperature: 27, Actual Temperature: %d", current_temperature);
        $display("-----------------------------------------------------");

        if (humidity == 8'd40 && current_temperature == 8'd27) begin
            $display("SUCCESS: Test Passed! The DUT correctly parsed the sensor data.");
        end else begin
            $display("FAILURE: Test Failed! The output values do not match the expected values.");
        end

        // 5. Finish the simulation
        $finish;
    end

endmodule