module digital_lock_k1 (
    input clk,                // 1Hz clock
    input enter_button,       // Enter button to submit the password
    input [5:0] password_input,  // 6-bit input for a password (0 to 63)
    output reg unlock_led,    // LED1: Unlock LED glows when correct password is entered
    output reg error_led,     // LED2: Error LED glows when incorrect password is entered
    output reg lockout_led    // LED3: Lockout LED glows when 3 incorrect attempts are made
);

    reg [5:0] correct_password = 6'd12;  // Set the correct password (e.g., 12)
    reg [3:0] attempt_count = 0;          // Counts the number of attempts
    reg [3:0] lock_counter = 0;           // Counts the 10 seconds lockout time
    reg locked = 0;                       // Indicates if the system is locked
    reg enter_button_last = 0;            // To store the previous state of the enter_button

    // State machine behavior
    always @(posedge clk) begin
        if (locked) begin
            // If the system is locked, increment the lock_counter
            if (lock_counter < 10) begin
                lock_counter <= lock_counter + 1;
            end else begin
                // Reset the lockout and unlock LED after 10 seconds
                locked <= 0;
                lock_counter <= 0;
                lockout_led <= 0;  // Turn off the lockout LED
            end
        end else begin
            // Detect the rising edge of the enter_button
            if (enter_button && !enter_button_last) begin
                // Check the entered password
                if (password_input == correct_password) begin
                    unlock_led <= 1;   // Password correct, unlock LED on
                    error_led <= 0;     // Error LED off
                    attempt_count <= 0; // Reset attempt count on success
                end else begin
                    unlock_led <= 0;   // Password incorrect, unlock LED off
                    error_led <= 1;    // Error LED on
                    attempt_count <= attempt_count + 1; // Increment attempt count
                    if (attempt_count == 3) begin
                        locked <= 1;    // Lock the system after 3 incorrect attempts
                        lockout_led <= 1;  // Turn on the lockout LED
                    end
                end
            end
        end
        
        // Store the previous state of the enter_button for edge detection
        enter_button_last <= enter_button;
    end

    // Reset LEDs when no input is made (idle state)
    always @(negedge enter_button) begin
        if (!locked) begin
            unlock_led <= 0;
            error_led <= 0;
        end
    end
endmodule