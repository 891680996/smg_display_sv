module smg_display (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input    [7:0]    number_data,
	output   [1:0]    column_scan_signal,  //assume that we have two smg to display
	output   [7:0]    row_scan_signal
);

	
	/*==========================================================*/

    /*generate ten data and one data

	/*==========================================================*/
	reg [31:0] rten_data;
	reg [31:0] rone_data;

	always_ff @(posedge clk or negedge rst_n) begin : proc_data_gen
		if(~rst_n) begin
			rten_data <= 0;
			rone_data <= 0;
		end else begin
			rten_data <= number_data/10;
			rone_data <= number_data%10;
		end
	end // proc_data_gen
    /*==========================================================*/

    



    /*==========================================================*/
 
    /*number encoding block

	/*==========================================================*/
	parameter    _0 = 8'b1100_0000,    _1 = 8'b1111_1001,    _2 = 8'b1010_0100,
				 _3 = 8'b1011_0000,    _4 = 8'b1001_1001,    _5 = 8'b1001_0010,
				 _6 = 8'b1000_0010,    _7 = 8'b1111_1000,    _8 = 8'b1000_0000,
				 _9 = 8'b1001_0000;

	reg [7:0] rten_smg_data;  //connect with ten_smg_data
	
	always_ff @(posedge clk) begin : proc_rten_smg_data
		if(~rst_n) begin
			rten_smg_data <= 8'hff;
		end else begin
			case (rten_data)

				4'd0	  :	rten_smg_data <= _0;
				4'd1	  :	rten_smg_data <= _1;
				4'd2	  :	rten_smg_data <= _2;
				4'd3	  :	rten_smg_data <= _3;
				4'd4	  :	rten_smg_data <= _4;
				4'd5	  :	rten_smg_data <= _5;
				4'd6	  :	rten_smg_data <= _6;
				4'd7	  :	rten_smg_data <= _7;
				4'd8	  :	rten_smg_data <= _8;
				4'd9	  :	rten_smg_data <= _9;
				default   : ;

			endcase // rten_data
		end // end else
	end // proc_rten_smg_data

	/***********************************************************/

	reg [7:0] rone_smg_data;  //connect with one_smg_data

	always_ff @(posedge clk) begin : proc_rone_smg_data
		if(~rst_n) begin
			rone_smg_data <= 8'hff;
		end else begin
			case (rone_data)

				4'd0	  :	rone_smg_data <= _0;
				4'd1	  :	rone_smg_data <= _1;
				4'd2	  :	rone_smg_data <= _2;
				4'd3      :	rone_smg_data <= _3;
				4'd4	  :	rone_smg_data <= _4;
				4'd5	  :	rone_smg_data <= _5;
				4'd6	  :	rone_smg_data <= _6;
				4'd7	  :	rone_smg_data <= _7;
				4'd8	  :	rone_smg_data <= _8;
				4'd9	  :	rone_smg_data <= _9;
				default   : ;

			endcase // rone_data
		end // end else
	end // proc_rone_smg_data
    /*==========================================================*/

	



    /*==========================================================*/
 
    /*smg scan block including column scan and row scan

	/*==========================================================*/
    //assuming that each smg light 10 ms ,here we use 50MHZ external clock
	//input,so we need frequency demultiplication by 0.01/(1/50M)-1 = 499_999
	parameter	 T_demulti = 10'd707;//707*707 = 499_999

	reg [9:0] count1;
	reg [9:0] count2;

	//realize the first demultiplication
	always_ff @(posedge clk or negedge rst_n) begin : proc_T1_demultiplication
		if(~rst_n) begin
			count1 <= 10'b0;
		end else begin
			if(count1 == T_demulti) begin
				count1 <= 10'b0;
			end else begin
				count1 <= count1 + 1'b1;
			end
		end
	end // proc_T1_demultiplication

	//the period of count2 is approximate 10ms
	always_ff @(posedge clk or negedge rst_n) begin : proc_T2_demultiplication
		if(~rst_n) begin
			count2 <= 10'b0;
		end else begin
			if(count2 == T_demulti) begin
				count2 <= 10'b0;
			end else begin
				if(count1 == T_demulti) begin
					count2 <= count2 + 1'b1;
				end
			end
		end // end else
	end // proc_T2_demultiplication

	/***********************************************************/
	//column scan
	reg [1:0] rcolumn_scan_signal;

	always_ff @(posedge clk or negedge rst_n) begin : proc_rcolumn_scan_signal
		if(~rst_n) begin
			rcolumn_scan_signal <= 2'b10;
		end else begin
			if(count2 == T_demulti) begin
				//ring shift right
				rcolumn_scan_signal <= {rcolumn_scan_signal[0],rcolumn_scan_signal[1]};
			end	
		end
	end // proc_rcolumn_scan_signal

    /***********************************************************/
    //row scan
	reg [7:0] rrow_scan_signal;

	always_ff @(posedge clk or negedge rst_n) begin : proc_rrow_scan_signal
		if(~rst_n) begin
			rrow_scan_signal <= 8'b0;
		end else begin
			case (rcolumn_scan_signal)
				2'b10	:	rrow_scan_signal <= rone_smg_data;
				2'b01 	: 	rrow_scan_signal <= rten_smg_data;
				default : 	rrow_scan_signal <= 2'bz;
			endcase
		end
	end // proc_rrow_scan_signal

	/***********************************************************/
	//column scan signal output
	assign 	column_scan_signal = rcolumn_scan_signal;
	//row scan signal output
	assign 	row_scan_signal = rrow_scan_signal;
	/***********************************************************/

    /*==========================================================*/

endmodule // smg_display
