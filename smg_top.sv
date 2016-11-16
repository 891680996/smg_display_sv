module smg_top (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	output 	[1:0] 	column_scan_signal,
	output 	[7:0]	row_scan_signal
);
	
	logic 	[7:0]	number_data;

	number_gen 			u_0(
		.clk        (clk),
		.rst_n      (rst_n),
		.number_data(number_data)
		);

	smg_display u_1(
		.clk               (clk),
		.rst_n             (rst_n),
		.number_data       (number_data),
		.column_scan_signal(column_scan_signal),
		.row_scan_signal   (row_scan_signal)
		);
	


endmodule