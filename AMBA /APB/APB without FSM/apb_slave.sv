module apb_slave(
	input Pclk ,
	input reset , //active low
	input PSEL,
	input PENABLE,
	input PWRITE,
	input [7:0] PADDR,
	input [7:0] PWDATA,
	output reg [7:0] PRDATA,
	output reg PREADY,
	output reg PSLVERR
	);

	parameter N=4;  //wait states

	reg [7:0] mem[0:7] ; //8x8 memory

	reg [2:0] wait_counter; //counter for wait states
	reg trans_active =0;


	always @(posedge Pclk or negedge reset)begin
		if(!reset)begin
			PREADY <= 0;
			PSLVERR <= 0;
			PRDATA <=0;
			wait_counter <= 0;
			trans_active <= 0;

			for(integer i =0; i<8 ; i=i+1)begin
				mem[i] <= 8'b0;
			end
		end
		else begin
			PSLVERR <= 0;

			if(PSEL && PENABLE && !trans_active)begin
				trans_active <= 1;
				wait_counter <= 0;
				PREADY<=0;  //enter into wait state
			end

			if(trans_active)begin
				if(wait_counter < N-1)begin
					wait_counter <= wait_counter + 1;
				end
				else begin  //wait_counter == N means wait states are noe over
					PREADY <= 1;
					trans_active <= 0 ; //reset flag

					if(PWRITE)begin
						if(PADDR == 8'h10 || PADDR == 8'h11) begin
							PSLVERR <= 1;  //master tired to access invalid addresss
						end else begin
							mem[PADDR[2:0]] <= PWDATA;  //write
						end
					end
					else begin
						PRDATA <= mem[PADDR[2:0]];  //read
					end
				end
			end
			else begin //trans_active = 0
				PREADY <= 0;
			end
		end
	end

	endmodule






