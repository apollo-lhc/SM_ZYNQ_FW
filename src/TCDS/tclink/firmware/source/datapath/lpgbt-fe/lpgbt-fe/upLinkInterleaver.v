/** ****************************************************************************
 *  lpGBTX                                                                     *
 *  Copyright (C) 2011-2016 GBTX Team, CERN                                    *
 *                                                                             *
 *  This IP block is free for HEP experiments and other scientific research    *
 *  purposes. Commercial exploitation of a chip containing the IP is not       *
 *  permitted.  You can not redistribute the IP without written permission     *
 *  from the authors. Any modifications of the IP have to be communicated back *
 *  to the authors. The use of the IP should be acknowledged in publications,  *
 *  public presentations, user manual, and other documents.                    *
 *                                                                             *
 *  This IP is distributed in the hope that it will be useful, but WITHOUT ANY *
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *
 *  FOR A PARTICULAR PURPOSE.                                                  *
 *                                                                             *
 *******************************************************************************
 *
 *  file: upLinkInterleaver.v
 *
 *  upLinkInterleaver
 *
 *  History:
 *  2016/05/30 Szymon Kulis    : Created File
 *  2016/10/26 José Fonseca    : Implemented and completed
 * 
 **/

module upLinkInterleaver (
    // input data (and fec codes)
    input [233:0]  dataFec5,
    input [205:0]  dataFec12,
    input [19:0]   fec5,
    input [47:0]   fec12,

    // control signals
    input          txDataRate,
    input          fecMode,
    input	   bypass,

    // output data:
    output reg [255:0] upLinkFrame
);

// -------------------------------------------------------------------------- //
// ------------- Triple Modular Redundancy Generator Directives ------------- //
// -------------------------------------------------------------------------- //
// tmrg default triplicate
// -------------------------------------------------------------------------- //
 	localparam FEC5            = 1'b0;
	localparam FEC12           = 1'b1;
	localparam TxDataRate5G12  = 1'b0;
	localparam TxDataRate10G24 = 1'b1;
	localparam HEADER          = 2'b10;


	always @(dataFec5 or dataFec12 or fec5 or fec12 or fecMode or txDataRate or bypass) begin 
		if(fecMode == FEC5) begin
			if(txDataRate == TxDataRate5G12) begin
					upLinkFrame[127:0]   = {HEADER, dataFec5[115:0], fec5[9:0]};
					upLinkFrame[255:128] = 128'b0;
			end
			else begin
				if(bypass) 
					upLinkFrame[255:0]   = {HEADER, dataFec5, fec5};
				else begin
					upLinkFrame[255:0]   = {HEADER, dataFec5[233:232], dataFec5[116:115], 
									dataFec5[231:227], dataFec5[114:110], 
									dataFec5[226:222], dataFec5[109:105],
									dataFec5[221:217], dataFec5[104:100], 
									dataFec5[216:212], dataFec5[99:95], 
									dataFec5[211:207], dataFec5[94:90],
									dataFec5[206:202], dataFec5[89:85],
									dataFec5[201:197], dataFec5[84:80],
									dataFec5[196:192], dataFec5[79:75],
									dataFec5[191:187], dataFec5[74:70],
									dataFec5[186:182], dataFec5[69:65],
									dataFec5[181:177], dataFec5[64:60],
									dataFec5[176:172], dataFec5[59:55],
									dataFec5[171:167], dataFec5[54:50],
									dataFec5[166:162], dataFec5[49:45],
									dataFec5[161:157], dataFec5[44:40],
									dataFec5[156:152], dataFec5[39:35],
									dataFec5[151:147], dataFec5[34:30],
									dataFec5[146:142], dataFec5[29:25],
									dataFec5[141:137], dataFec5[24:20],
									dataFec5[136:132], dataFec5[19:15],
									dataFec5[131:127], dataFec5[14:10],
									dataFec5[126:122], dataFec5[9:5],
									dataFec5[121:117], dataFec5[4:0],
									fec5[19:15], fec5[9:5], fec5[14:10], fec5[4:0]};
				end
			end
		end
		else begin
			if(txDataRate == TxDataRate5G12) begin
				if(bypass)
					upLinkFrame[127:0] = {HEADER, dataFec12, fec12};
				else begin
					upLinkFrame[127:0]   = {HEADER, dataFec12[101:100], dataFec12[67:66], dataFec12[33:32],
									dataFec12[99:96], dataFec12[65:62]         , dataFec12[31:28],
									dataFec12[95:92], dataFec12[61:58]		   , dataFec12[27:24],
									dataFec12[91:88], dataFec12[57:54]		   , dataFec12[23:20],
									dataFec12[87:84], dataFec12[53:50]		   , dataFec12[19:16],
									dataFec12[83:80], dataFec12[49:46]		   , dataFec12[15:12],
									dataFec12[79:76], dataFec12[45:42]		   , dataFec12[11:8],
									dataFec12[75:72], dataFec12[41:38]		   , dataFec12[7:4],
									dataFec12[71:68], dataFec12[37:34]		   , dataFec12[3:0],
									fec12[23:20]    , fec12[15:12]             , fec12[7:4],
									fec12[19:16]    , fec12[11:8]   		   , fec12[3:0]};
				end
				upLinkFrame[255:128] = 128'b0;
			end
			else begin
				if(bypass) 
					upLinkFrame[255:0]   = {HEADER, dataFec12, fec12};
				else begin
					upLinkFrame[255:0]   = {HEADER,                                        dataFec12[205:204], dataFec12[203:202], dataFec12[101:100], dataFec12[169:168], dataFec12[67:66], dataFec12[135:134], dataFec12[33:32], 
								dataFec12[201:198], dataFec12[167:164],                    dataFec12[133:130],                      dataFec12[99:96],                    dataFec12[65:62], dataFec12[31:28],
								dataFec12[197:194], dataFec12[163:160],                    dataFec12[129:126],                      dataFec12[95:92],                    dataFec12[61:58], dataFec12[27:24],
								dataFec12[193:190], dataFec12[159:156],                    dataFec12[125:122],                      dataFec12[91:88],                    dataFec12[57:54], dataFec12[23:20],
								dataFec12[189:186], dataFec12[155:152],                    dataFec12[121:118],                      dataFec12[87:84],                    dataFec12[53:50], dataFec12[19:16],
								dataFec12[185:182], dataFec12[151:148],                    dataFec12[117:114],                      dataFec12[83:80],                    dataFec12[49:46], dataFec12[15:12],
								dataFec12[181:178], dataFec12[147:144],                    dataFec12[113:110],                      dataFec12[79:76],                    dataFec12[45:42], dataFec12[11:8],
								dataFec12[177:174], dataFec12[143:140],                    dataFec12[109:106],                      dataFec12[75:72],                    dataFec12[41:38], dataFec12[7:4],
								dataFec12[173:170], dataFec12[139:136],                    dataFec12[105:102],                      dataFec12[71:68],                    dataFec12[37:34], dataFec12[3:0],
								      fec12[47:44],       fec12[39:36],                    fec12[31:28],                          fec12[23:20],                        fec12[15:12],     fec12[7:4],
								      fec12[43:40],       fec12[35:32],                    fec12[27:24],                          fec12[19:16],                         fec12[11:8],     fec12[3:0]};
				end
			end
		end			
	end
			
endmodule
