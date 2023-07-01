
`include "scr1_memif.svh"
`include "scr1_arch_description.svh"

`define DBL_INT_ADD(a,b,c) if (a > 0xffffffff - (c)) ++b; a += c;
`define ROTLEFT(a,b)(((a) << (b)) | ((a) >> (32-(b))))
`define ROTRIGHT(a,b) (((a) >> (b)) | ((a) << (32-(b))))

`define CH(x,y,z) (((x) & (y)) ^ (~(x) & (z)))
`define MAJ(x,y,z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
`define EP0(x) (`ROTRIGHT(x,2) ^ `ROTRIGHT(x,13) ^ `ROTRIGHT(x,22))
`define EP1(x) (`ROTRIGHT(x,6) ^ `ROTRIGHT(x,11) ^ `ROTRIGHT(x,25))
`define SIG0(x) (`ROTRIGHT(x,7) ^ `ROTRIGHT(x,18) ^ ((x) >> 3))
`define SIG1(x) (`ROTRIGHT(x,17) ^ `ROTRIGHT(x,19) ^ ((x) >> 10))



module scr1_accel
(
    // Control signals
    input   logic                           clk,
    input   logic                           rst_n,


    // Core data interface
    output  logic                           dmem_req_ack,
    input   logic                           dmem_req,
    input   type_scr1_mem_cmd_e             dmem_cmd,
    input   type_scr1_mem_width_e           dmem_width,
    input   logic [`SCR1_DMEM_AWIDTH-1:0]   dmem_addr,
    input   logic [`SCR1_DMEM_DWIDTH-1:0]   dmem_wdata,
    output  logic [`SCR1_DMEM_DWIDTH-1:0]   dmem_rdata,
    output  type_scr1_mem_resp_e            dmem_resp
);


//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------
logic                               dmem_req_en;
logic                               dmem_rd;
logic                               dmem_wr;
logic [`SCR1_DMEM_DWIDTH-1:0]       dmem_writedata;
logic [`SCR1_DMEM_DWIDTH-1:0]       dmem_rdata_local;
logic [1:0]                         dmem_rdata_shift_reg;
//-------------------------------------------------------------------------------
// Core interface
//-------------------------------------------------------------------------------
assign dmem_req_en = (dmem_resp == SCR1_MEM_RESP_RDY_OK) ^ dmem_req;


always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        dmem_resp <= SCR1_MEM_RESP_NOTRDY;
    end else if (dmem_req_en) begin
        dmem_resp <= dmem_req ? SCR1_MEM_RESP_RDY_OK : SCR1_MEM_RESP_NOTRDY;
    end
end

assign dmem_req_ack = 1'b1;
//-------------------------------------------------------------------------------
// Memory data composing
//-------------------------------------------------------------------------------
assign dmem_rd  = dmem_req & (dmem_cmd == SCR1_MEM_CMD_RD);
assign dmem_wr  = dmem_req & (dmem_cmd == SCR1_MEM_CMD_WR);

always_comb begin
    dmem_writedata = dmem_wdata;
    case ( dmem_width )
        SCR1_MEM_WIDTH_BYTE : begin
            dmem_writedata  = {(`SCR1_DMEM_DWIDTH /  8){dmem_wdata[7:0]}};
        end
        SCR1_MEM_WIDTH_HWORD : begin
            dmem_writedata  = {(`SCR1_DMEM_DWIDTH / 16){dmem_wdata[15:0]}};
        end
        default : begin
        end
    endcase
end
	 reg go_bit;
	 wire go_bit_in;
	 reg done_bit;
	 wire done_bit_in;
	 reg [31:0] state [0:7];
	 reg [31:0] data [0:15];
	 reg [31:0] m [0:63];
	 reg [31:0] A;
	 reg [31:0] B;
	 reg [31:0] C;
	 reg [31:0] D;
	 reg [31:0] E;
	 reg [31:0] F;
	 reg [31:0] G;
	 reg [31:0] H;
	 reg [15:0] counter;

	 assign ctr = counter;
	 
	 always @(*) begin
		case(dmem_addr[8:2])
		7'b0000000: dmem_rdata_local = {done_bit, 30'b0, go_bit};
		7'b0000001: dmem_rdata_local = state[0];
		7'b0000010: dmem_rdata_local = state[1];
		7'b0000011: dmem_rdata_local = state[2];
		7'b0000100: dmem_rdata_local = state[3];
		7'b0000101: dmem_rdata_local = state[4];
		7'b0000110: dmem_rdata_local = state[5];
		7'b0000111: dmem_rdata_local = state[6];
		7'b0001000: dmem_rdata_local = state[7];
		7'b0001001: dmem_rdata_local = data[0];
		7'b0001010: dmem_rdata_local = data[1];
		7'b0001011: dmem_rdata_local = data[2];
		7'b0001100: dmem_rdata_local = data[3];
		7'b0001101: dmem_rdata_local = data[4];
		7'b0001110: dmem_rdata_local = data[5];
		7'b0001111: dmem_rdata_local = data[6];
		7'b0010000: dmem_rdata_local = data[7];
		7'b0010001: dmem_rdata_local = data[8];
		7'b0010010: dmem_rdata_local = data[9];
		7'b0010011: dmem_rdata_local = data[10];
		7'b0010100: dmem_rdata_local = data[11];
		7'b0010101: dmem_rdata_local = data[12];
		7'b0010110: dmem_rdata_local = data[13];
		7'b0010111: dmem_rdata_local = data[14];
		7'b0011000: dmem_rdata_local = data[15];
		7'b0011001: dmem_rdata_local = A;
		7'b0011010: dmem_rdata_local = B;
		7'b0011011: dmem_rdata_local = C;
		7'b0011100: dmem_rdata_local = D;
		7'b0011101: dmem_rdata_local = E;
		7'b0011110: dmem_rdata_local = F;
		7'b0011111: dmem_rdata_local = G;
		7'b0100000: dmem_rdata_local = H;
		7'b0100001: dmem_rdata_local = m[0];
		7'b0100010: dmem_rdata_local = m[1];
		7'b0100011: dmem_rdata_local = m[2];
		7'b0100100: dmem_rdata_local = m[3];
		7'b0100101: dmem_rdata_local = m[4];
		7'b0100110: dmem_rdata_local = m[5];
		7'b0100111: dmem_rdata_local = m[6];
		7'b0101000: dmem_rdata_local = m[7];
		7'b0101001: dmem_rdata_local = m[8];
		7'b0101010: dmem_rdata_local = m[9];
		7'b0101011: dmem_rdata_local = m[10];
		7'b0101100: dmem_rdata_local = m[11];
		7'b0101101: dmem_rdata_local = m[12];
		7'b0101110: dmem_rdata_local = m[13];
		7'b0101111: dmem_rdata_local = m[14];
		7'b0110000: dmem_rdata_local = m[15];
		7'b0110001: dmem_rdata_local = m[16];
		7'b0110010: dmem_rdata_local = m[17];
		7'b0110011: dmem_rdata_local = m[18];
		7'b0110100: dmem_rdata_local = m[19];
		7'b0110101: dmem_rdata_local = m[20];
		7'b0110110: dmem_rdata_local = m[21];
		7'b0110111: dmem_rdata_local = m[22];
		7'b0111000: dmem_rdata_local = m[23];
		7'b0111001: dmem_rdata_local = m[24];
		7'b0111010: dmem_rdata_local = m[25];
		7'b0111011: dmem_rdata_local = m[26];
		7'b0111100: dmem_rdata_local = m[27];
		7'b0111101: dmem_rdata_local = m[28];
		7'b0111110: dmem_rdata_local = m[29];
		7'b0111111: dmem_rdata_local = m[30];
		7'b1000000: dmem_rdata_local = m[31];
		7'b1000001: dmem_rdata_local = m[32];
		7'b1000010: dmem_rdata_local = m[33];
		7'b1000011: dmem_rdata_local = m[34];
		7'b1000100: dmem_rdata_local = m[35];
		7'b1000101: dmem_rdata_local = m[36];
		7'b1000110: dmem_rdata_local = m[37];
		7'b1000111: dmem_rdata_local = m[38];
		7'b1001000: dmem_rdata_local = m[39];
		7'b1001001: dmem_rdata_local = m[40];
		7'b1001010: dmem_rdata_local = m[41];
		7'b1001011: dmem_rdata_local = m[42];
		7'b1001100: dmem_rdata_local = m[43];
		7'b1001101: dmem_rdata_local = m[44];
		7'b1001110: dmem_rdata_local = m[45];
		7'b1001111: dmem_rdata_local = m[46];
		7'b1010000: dmem_rdata_local = m[47];
		7'b1010001: dmem_rdata_local = m[48];
		7'b1010010: dmem_rdata_local = m[49];
		7'b1010011: dmem_rdata_local = m[50];
		7'b1010100: dmem_rdata_local = m[51];
		7'b1010101: dmem_rdata_local = m[52];
		7'b1010110: dmem_rdata_local = m[53];
		7'b1010111: dmem_rdata_local = m[54];
		7'b1011000: dmem_rdata_local = m[55];
		7'b1011001: dmem_rdata_local = m[56];
		7'b1011010: dmem_rdata_local = m[57];
		7'b1011011: dmem_rdata_local = m[58];
		7'b1011100: dmem_rdata_local = m[59];
		7'b1011101: dmem_rdata_local = m[60];
		7'b1011110: dmem_rdata_local = m[61];
		7'b1011111: dmem_rdata_local = m[62];
		7'b1100000: dmem_rdata_local = m[63];
		default: dmem_rdata_local = 32'b0;
		endcase
	 end
	 
	 assign go_bit_in = (dmem_wr & (dmem_addr[8:2] == 7'b0000000));
	
	 always @(posedge clk or negedge rst_n)
		if(~rst_n) go_bit <= 1'b0;
		else go_bit <=  go_bit_in ? 1'b1 : 1'b0;
		
	 always @(posedge clk or negedge rst_n)
		if(~rst_n) begin
			state[0] <= 32'h6a09e667;
			state[1] <= 32'hbb67ae85;
			state[2] <= 32'h3c6ef372;
			state[3] <= 32'ha54ff53a;
			state[4] <= 32'h510e527f;
			state[5] <= 32'h9b05688c;
			state[6] <= 32'h1f83d9ab;
			state[7] <= 32'h5be0cd19;
		end
		else begin
			if (dmem_wr) begin
				data[0] <= (dmem_addr[8:2] ==  7'b0001001) ? dmem_writedata : data[0];
				data[1] <= (dmem_addr[8:2] ==  7'b0001010) ? dmem_writedata : data[1];
				data[2] <= (dmem_addr[8:2] ==  7'b0001011) ? dmem_writedata : data[2];
				data[3] <= (dmem_addr[8:2] ==  7'b0001100) ? dmem_writedata : data[3];
				data[4] <= (dmem_addr[8:2] ==  7'b0001101) ? dmem_writedata : data[4];
				data[5] <= (dmem_addr[8:2] ==  7'b0001110) ? dmem_writedata : data[5];
				data[6] <= (dmem_addr[8:2] ==  7'b0001111) ? dmem_writedata : data[6];
				data[7] <= (dmem_addr[8:2] ==  7'b0010000) ? dmem_writedata : data[7];
				data[8] <= (dmem_addr[8:2] ==  7'b0010001) ? dmem_writedata : data[8];
				data[9] <= (dmem_addr[8:2] ==  7'b0010010) ? dmem_writedata : data[9];
				data[10] <= (dmem_addr[8:2] == 7'b0010011) ? dmem_writedata : data[10];
				data[11] <= (dmem_addr[8:2] == 7'b0010100) ? dmem_writedata : data[11];
				data[12] <= (dmem_addr[8:2] == 7'b0010101) ? dmem_writedata : data[12];
				data[13] <= (dmem_addr[8:2] == 7'b0010110) ? dmem_writedata : data[13];
				data[14] <= (dmem_addr[8:2] == 7'b0010111) ? dmem_writedata : data[14];
				data[15] <= (dmem_addr[8:2] == 7'b0011000) ? dmem_writedata : data[15];
			end
			else begin
				data[0] <= data[0];
				data[1] <= data[1];
				data[2] <= data[2];
				data[3] <= data[3];
				data[4] <= data[4];
				data[5] <= data[5];
				data[6] <= data[6];
				data[7] <= data[7];
				data[8] <= data[8];
				data[9] <= data[9];
				data[10] <= data[10];
				data[11] <= data[11];
				data[12] <= data[12];
				data[13] <= data[13];		
				data[14] <= data[14];
				data[15] <= data[15];
			end
			counter <= go_bit_in? 16'h00 : done_bit_in ? counter : counter +16'h01;
		end
		
	always @(posedge clk) begin
	if (counter==16'd0) begin
		 m[0]={data[0][7:0], data[0][15:8], data[0][23:16], data[0][31:24]};
		 m[1]={data[1][7:0], data[1][15:8], data[1][23:16], data[1][31:24]};
		 m[2]={data[2][7:0], data[2][15:8], data[2][23:16], data[2][31:24]};
		 m[3]={data[3][7:0], data[3][15:8], data[3][23:16], data[3][31:24]};
		 m[4]={data[4][7:0], data[4][15:8], data[4][23:16], data[4][31:24]};
		 m[5]={data[5][7:0], data[5][15:8], data[5][23:16], data[5][31:24]};
		 m[6]={data[6][7:0], data[6][15:8], data[6][23:16], data[6][31:24]};
		 m[7]={data[7][7:0], data[7][15:8], data[7][23:16], data[7][31:24]};
		 m[8]={data[8][7:0], data[8][15:8], data[8][23:16], data[8][31:24]};
		 m[9]={data[9][7:0], data[9][15:8], data[9][23:16], data[9][31:24]};
		 m[10]={data[10][7:0], data[10][15:8], data[10][23:16], data[10][31:24]};
		 m[11]={data[11][7:0], data[11][15:8], data[11][23:16], data[11][31:24]};
		 m[12]={data[12][7:0], data[12][15:8], data[12][23:16], data[12][31:24]};
		 m[13]={data[13][7:0], data[13][15:8], data[13][23:16], data[13][31:24]};
		 m[14]={data[14][7:0], data[14][15:8], data[14][23:16], data[14][31:24]};
		 m[15]={data[15][7:0], data[15][15:8], data[15][23:16], data[15][31:24]};
	end
	else if (counter==16'd1) begin
		 m[16]={(`SIG1(m[14]))+(m[9])+(`SIG0(m[1]))+(m[0])};
		 m[17]={(`SIG1(m[15]))+(m[10])+(`SIG0(m[2]))+(m[1])};
	end
	else if (counter==16'd2) begin
		 m[18]={(`SIG1(m[16]))+(m[11])+(`SIG0(m[3]))+(m[2])};
		 m[19]={(`SIG1(m[17]))+(m[12])+(`SIG0(m[4]))+(m[3])};
	end	
	else if (counter==16'd3) begin
		 m[20]={(`SIG1(m[18]))+(m[13])+(`SIG0(m[5]))+(m[4])};
		 m[21]={(`SIG1(m[19]))+(m[14])+(`SIG0(m[6]))+(m[5])};
	end
	else if (counter==16'd4) begin
		 m[22]={(`SIG1(m[20]))+(m[15])+(`SIG0(m[7]))+(m[6])};
		 m[23]={(`SIG1(m[21]))+(m[16])+(`SIG0(m[8]))+(m[7])};	
	end
	else if (counter==16'd5) begin
		 m[24]={(`SIG1(m[22]))+(m[17])+(`SIG0(m[9]))+(m[8])};
		 m[25]={(`SIG1(m[23]))+(m[18])+(`SIG0(m[10]))+(m[9])};
	end
	else if (counter==16'd6) begin
		 m[26]={(`SIG1(m[24]))+(m[19])+(`SIG0(m[11]))+(m[10])};
		 m[27]={(`SIG1(m[25]))+(m[20])+(`SIG0(m[12]))+(m[11])};
	end
	else if (counter==16'd7) begin
		 m[28]={(`SIG1(m[26]))+(m[21])+(`SIG0(m[13]))+(m[12])};
		 m[29]={(`SIG1(m[27]))+(m[22])+(`SIG0(m[14]))+(m[13])};
	end
	else if (counter==16'd8) begin
		 m[30]={(`SIG1(m[28]))+(m[23])+(`SIG0(m[15]))+(m[14])};
		 m[31]={(`SIG1(m[29]))+(m[24])+(`SIG0(m[16]))+(m[15])};
	end	
	else if (counter==16'd9) begin
		 m[32]={(`SIG1(m[30]))+(m[25])+(`SIG0(m[17]))+(m[16])};
		 m[33]={(`SIG1(m[31]))+(m[26])+(`SIG0(m[18]))+(m[17])};
	end
	else if (counter==16'd10) begin
		 m[34]={(`SIG1(m[32]))+(m[27])+(`SIG0(m[19]))+(m[18])};
		 m[35]={(`SIG1(m[33]))+(m[28])+(`SIG0(m[20]))+(m[19])};
	end
	else if (counter==16'd11) begin
		 m[36]={(`SIG1(m[34]))+(m[29])+(`SIG0(m[21]))+(m[20])};
		 m[37]={(`SIG1(m[35]))+(m[30])+(`SIG0(m[22]))+(m[21])};
	end
	else if (counter==16'd12) begin
		 m[38]={(`SIG1(m[36]))+(m[31])+(`SIG0(m[23]))+(m[22])};
		 m[39]={(`SIG1(m[37]))+(m[32])+(`SIG0(m[24]))+(m[23])};	
	end
	else if (counter==16'd13) begin
		 m[40]={(`SIG1(m[38]))+(m[33])+(`SIG0(m[25]))+(m[24])};
		 m[41]={(`SIG1(m[39]))+(m[34])+(`SIG0(m[26]))+(m[25])};
	end
	else if (counter==16'd14) begin
		 m[42]={(`SIG1(m[40]))+(m[35])+(`SIG0(m[27]))+(m[26])};
		 m[43]={(`SIG1(m[41]))+(m[36])+(`SIG0(m[28]))+(m[27])};
	end	
	else if (counter==16'd15) begin
		 m[44]={(`SIG1(m[42]))+(m[37])+(`SIG0(m[29]))+(m[28])};
		 m[45]={(`SIG1(m[43]))+(m[38])+(`SIG0(m[30]))+(m[29])};
	end
	else if (counter==16'd16) begin
		 m[46]={(`SIG1(m[44]))+(m[39])+(`SIG0(m[31]))+(m[30])};
		 m[47]={(`SIG1(m[45]))+(m[40])+(`SIG0(m[32]))+(m[31])};		
	end
	else if (counter==16'd17) begin
		 m[48]={(`SIG1(m[46]))+(m[41])+(`SIG0(m[33]))+(m[32])};
		 m[49]={(`SIG1(m[47]))+(m[42])+(`SIG0(m[34]))+(m[33])};
	end
	else if (counter==16'd18) begin
		 m[50]={(`SIG1(m[48]))+(m[43])+(`SIG0(m[35]))+(m[34])};
		 m[51]={(`SIG1(m[49]))+(m[44])+(`SIG0(m[36]))+(m[35])};
	end
	else if (counter==16'd19) begin
		 m[52]={(`SIG1(m[50]))+(m[45])+(`SIG0(m[37]))+(m[36])};
		 m[53]={(`SIG1(m[51]))+(m[46])+(`SIG0(m[38]))+(m[37])};
	end
	else if (counter==16'd20) begin
		 m[54]={(`SIG1(m[52]))+(m[47])+(`SIG0(m[39]))+(m[38])};
		 m[55]={(`SIG1(m[53]))+(m[48])+(`SIG0(m[40]))+(m[39])};
	end	
	else if (counter==16'd21) begin
		 m[56]={(`SIG1(m[54]))+(m[49])+(`SIG0(m[41]))+(m[40])};
		 m[57]={(`SIG1(m[55]))+(m[50])+(`SIG0(m[42]))+(m[41])};
	end
	else if (counter==16'd22) begin
		 m[58]={(`SIG1(m[56]))+(m[51])+(`SIG0(m[43]))+(m[42])};
		 m[59]={(`SIG1(m[57]))+(m[52])+(`SIG0(m[44]))+(m[43])};	
	end
	else if (counter==16'd23) begin
		 m[60]={(`SIG1(m[58]))+(m[53])+(`SIG0(m[45]))+(m[44])};
		 m[61]={(`SIG1(m[59]))+(m[54])+(`SIG0(m[46]))+(m[45])};
	end
	else if (counter==16'd24) begin
		 m[62]={(`SIG1(m[60]))+(m[55])+(`SIG0(m[47]))+(m[46])};
		 m[63]={(`SIG1(m[61]))+(m[56])+(`SIG0(m[48]))+(m[47])};
	end
end
							 
	 //assign done_bit_in = (counter == 16'd24);
	 
	 always @(posedge clk or negedge rst_n)
		if(~rst_n) done_bit <= 1'b0;
		else done_bit <= go_bit_in ? 1'b0 : done_bit_in;
	 

always_ff @(posedge clk) begin
    if (dmem_rd) begin
        dmem_rdata_shift_reg <= dmem_addr[1:0];
    end
end

assign dmem_rdata = dmem_rdata_local >> ( 8 * dmem_rdata_shift_reg );

endmodule : scr1_accel
