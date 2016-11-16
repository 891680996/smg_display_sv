module number_gen (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	output 	[7:0]	number_data
);

/***********************************************************/
	//assuming that each smg light 10 ms ,here we use 50MHZ external clock
	//input,so we need frequency demultiplication by 0.01/(1/50M)-1 = 499_999

	parameter	 T_demulti = 12'd4000;//707*707 = 499_999

	/***********************************************************/
	/***********************************************************/

	reg		[11:0]	count1;
	reg 	[11:0]	count2;

	//realize the first demultiplication
	always_ff @(posedge clk or negedge rst_n) begin : proc_T1_demultiplication
		if(~rst_n) begin
			count1 <= 11'b0;
		end else begin
			if(count1 == T_demulti) begin
				count1 <= 11'b0;
			end else begin
				count1 <= count1 + 1'b1;
			end
		end
	end // proc_T1_demultiplication

	//the period of count2 is approximate 10ms
	always_ff @(posedge clk or negedge rst_n) begin : proc_T2_demultiplication
		if(~rst_n) begin
			count2 <= 11'b0;
		end else begin
			if(count2 == T_demulti) begin
				count2 <= 11'b0;
			end else begin
				if(count1 == T_demulti) begin
					count2 <= count2 + 1'b1;
				end
			end
		end // end else
	end // proc_T2_demultiplication

	reg		[7:0]	rnumber_data;

	always_ff @(posedge clk or negedge rst_n) begin : proc_rnumber_data
		if(~rst_n) begin
			rnumber_data <= 0;
		end else begin
			if(count2 == T_demulti) begin
				rnumber_data <= rnumber_data + 1'b1;
			end
		end
	end
	
	assign	number_data = rnumber_data;

endmodule // number_gen