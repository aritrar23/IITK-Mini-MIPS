`timescale 1ns / 1ps
module main_file 
(
    input wire clk
//    input wire rst,
//    input wire data_write,
//    input wire instr_write,
//    input wire [31:0] data,
//    input wire [9:0] address
);

reg [31:0] registers[31:0];             
wire[31:0] instruction;                 
reg [4:0] PC;                           
//reg [31:0] em[20:0];

reg [31:0] HI;
reg [31:0] LO;

//memory_wrapper(a,d,dpra,clk,we,dpo);

reg im_we;                          //we
reg [31:0] im_d;                    //d
reg [9:0] im_a, im_dpra;            //write address

//memory_wrapper(a,d,dpra,clk,we,dpo);

reg dm_we;
reg[31:0] dm_d;
reg[9:0] dm_a, dm_dpra;
wire[31:0] dm_dpo;

//alu 
wire [31:0] alu_output;
reg [31:0] alu_A, alu_B;

reg [3:0] alu_op;
reg [63:0] product;
reg [63:0] sum;
integer i;

reg [31:0] final_mem_dump [0:10];  // Stores final array (adjust size as needed)
reg dump_trigger = 0;               // Flag to trigger memory dump

reg [31:0] f_registers[31:0];  // 32 floating-point registers (f0-f31)
reg [7:0] cc;                  // Comparison flags (8 bits for multiple conditions)

//-----------------------------------Instantiating ALU, imem, dmem -------------------------------------

ALU alu_inst (
    .A(alu_A),
    .B(alu_B),
    .ALUop(alu_op),
    .ALUout(alu_output)
);

dist_mem_gen_0 imem(
  .a(9'b0),        // input wire [8 : 0] a  //write address
  .d(im_d),        // input wire [31 : 0] d  //write data
  .dpra({5'b0,PC}),  // input wire [8 : 0] dpra  //read address
  .clk(clk),    // input wire clk       
  .we(im_we),      // input wire we
  .dpo(instruction)     // output wire [31 : 0] dpo   //read output
);


dist_mem_gen_1 dmem (
  .a(dm_a),        // input wire [8 : 0] a  //write address
  .d(dm_d),        // input wire [31 : 0] d  //write data
  .dpra(dm_dpra),  // input wire [8 : 0] dpra  //read address
  .clk(clk),    // input wire clk       
  .we(dm_we),      // input wire we
  .dpo(dm_dpo)     // output wire [31 : 0] dpo   //read output
);

//--------------------------------------------------------------------------------------------------------

initial begin
    alu_A=0;
    alu_B=0;
    im_we=0;
    dm_we=0;        //both write enables are 0
    PC=5'b0;        //PC is 0 initially
    im_d=32'b0;     // both input data 0
    dm_d=31'b0;        
    dm_a=10'b0;     //write address =0 for dmem
    dm_dpra=10'b0;  //read address=0 initially
    HI = 32'b0;     
    LO = 32'b0;     

  
    for (i = 0; i < 32; i = i + 1)
        registers[i] = 32'b0;
            
    for (i = 0; i < 32; i = i + 1)
        f_registers[i] = 32'b0;
        
    cc = 8'b0;

//    registers[0] = 32'b0;    // $zero
//    registers[29] = 32'd63;  // $sp
//    registers[16] = 32'd0;    // $s0 = address of an array
//    registers[17] = 32'd11;  // $s1 = size of an array
    
//    registers[16] = 2; //$s0
//    registers[17] = 3; //$s1
    f_registers[0] = 32'b01000000010011001100110011001101; //3.2;
    f_registers[1] = 32'b01000000000001100110011001100110; //2.1
    
//    $readmemb("dmem.coe",em);
    $monitor("%d %d",PC,instruction);
end

// always@(posedge clk) begin
// if (rst==1) begin
// if (data_write == 1) begin
//    dm_a=address;
//    dm_we=1;
//    dm_d=data;
// end
 
// if(instr_write==1) begin
//    im_a=address;
//    im_we=1;
//    im_d=data;
//    end
// end
//end
//--------------------------------------------------------------------------------------------------------------

always@(posedge clk) begin
//if(rst==0)begin
    case(instruction[31:26])
        6'd0: begin                                                     //opcode=0 : R instructions
            case(instruction[5:0])                                      // funct is used to identify the case
                6'b100000: begin // add
                    alu_B = registers[instruction[20:16]];
                    alu_A = registers[instruction[25:21]];
                    alu_op = 4'b0001;
                    #10
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                6'b100010: begin // sub
                    alu_B = registers[instruction[20:16]];
                    alu_A = registers[instruction[25:21]];
                    alu_op = 4'b0010;
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                6'b100001: begin // addu
                    alu_B = registers[instruction[20:16]];
                    alu_A = registers[instruction[25:21]];
                    alu_op = 4'b0001;
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                6'b101111: begin // subu
                    alu_B = registers[instruction[20:16]];
                    alu_A = registers[instruction[25:21]];
                    alu_op = 4'b0010;
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                6'b100100: begin // and
                    alu_B = registers[instruction[20:16]];
                    alu_A = registers[instruction[25:21]];
                    alu_op = 4'b0011;
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                6'b100101: begin // or
                    alu_B = registers[instruction[20:16]];
                    alu_A = registers[instruction[25:21]];
                    alu_op = 4'b0100;
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                6'b000000: begin // sll
                    alu_B = instruction[10:6];
                    alu_A = registers[instruction[20:16]];
                    alu_op = 4'b0101;
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                6'b000010: begin // srl
                    alu_B = instruction[10:6];
                    alu_A = registers[instruction[20:16]];
                    alu_op = 4'b0110;
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                 6'b101010: begin // slt
                     alu_B = registers[instruction[20:16]];
                     alu_A = registers[instruction[25:21]];
                     alu_op = 4'b1000;
                     registers[instruction[15:11]] = alu_output;
                     PC = PC + 1;
                 end

                6'b001000: begin // jr
                    alu_A = 32'b0;
                    alu_B = 32'b0;
                    alu_op = 4'b0000;
                    PC = registers[instruction[25:21]];
                end

                6'b000001: begin // madd
                    begin
                      
                        
                        product = $signed(registers[instruction[25:21]]) * $signed(registers[instruction[20:16]]);
                        sum = {HI, LO} + product;
                        HI = sum[63:32];
                        LO = sum[31:0];
                        PC = PC + 1;
                    end
                end

                6'b000011: begin // maddu
                    begin
                        
                        
                        product = registers[instruction[25:21]] * registers[instruction[20:16]];
                        sum = {HI, LO} + product;
                        HI = sum[63:32];
                        LO = sum[31:0];
                        PC = PC + 1;
                    end
                end

                6'b011000: begin // mul
                    begin
                        
                        
                        product = $signed(registers[instruction[25:21]]) * $signed(registers[instruction[20:16]]);
                        HI = product[63:32];
                        LO = product[31:0];
                        
                        registers[instruction[15:11]] = product[31:0];
                        PC = PC + 1;
                    end
                end

                6'b100110: begin // xor
                    alu_B = registers[instruction[20:16]];
                    alu_A = registers[instruction[25:21]];
                    alu_op = 4'b1010;
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                // 6'b000100: begin // sllv (shift left logical variable)
                //     alu_B = registers[instruction[20:16]];
                //     alu_A = registers[instruction[25:21]];
                //     alu_op = 4'b0101;
                //     registers[instruction[15:11]] = alu_output;
                //     PC = PC + 1;
                // end

                // 6'b000110: begin // srlv (shift right logical variable)
                //     alu_B = registers[instruction[20:16]];
                //     alu_A = registers[instruction[25:21]];
                //     alu_op = 4'b0110;
                //     registers[instruction[15:11]] = alu_output;
                //     PC = PC + 1;
                // end

                // 6'b000111: begin // srav (shift right arithmetic variable)
                //     alu_B = registers[instruction[20:16]];
                //     alu_A = registers[instruction[25:21]];
                //     alu_op = 4'b1011;
                //     registers[instruction[15:11]] = alu_output;
                //     PC = PC + 1;
                // end

                6'b100111: begin // not (implemented as nor with zero)
                    alu_A = registers[instruction[25:21]];
                    alu_B = 32'b0;
                    alu_op = 4'b0100; // OR operation (but we'll invert it)
                    registers[instruction[15:11]] = ~alu_A;
                    PC = PC + 1;
                end

                6'b000011: begin // sra
                    alu_B = instruction[10:6]; // shift amount
                    alu_A = registers[instruction[20:16]];
                    alu_op = 4'b1011;
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end

                6'b000100: begin // sla
                    alu_B = registers[instruction[20:16]];
                    alu_A = registers[instruction[25:21]];
                    alu_op = 4'b0101; 
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end
                
                
                6'b101100: begin // seq (set equal)
                    alu_B = registers[instruction[20:16]];
                    alu_A = registers[instruction[25:21]];
                    alu_op = 4'b0111; // Equality operation
                    registers[instruction[15:11]] = alu_output;
                    PC = PC + 1;
                end
                
                6'b000100: begin // add.s (floating-point addition)
           
                alu_A = f_registers[instruction][25:21];
                alu_B = f_registers[instruction][20:16];
                alu_op = 4'b1100;
                f_registers[instruction[15:11]] = alu_output;
                PC = PC + 1;
            end
            
            6'b000101: begin // sub.s (floating-point subtraction)
                alu_A = f_registers[instruction[25:21]];
                alu_B = f_registers[instruction[20:16]];
                alu_op = 4'b1101;
                f_registers[instruction[15:11]] = alu_output;
                PC = PC + 1;
            end
            
            
            6'b010000: begin // mov.s (move floating-point)
    f_registers[instruction[15:11]] = f_registers[instruction[20:16]];
    PC = PC + 1;
end

6'b010001: begin // mfc1 (move from floating-point to integer)
    registers[instruction[15:11]] = f_registers[instruction[20:16]];
    PC = PC + 1;
end

6'b010010: begin // mtc1 (move to floating-point from integer)
    f_registers[instruction[15:11]] = registers[instruction[20:16]];
    PC = PC + 1;
end

                default: begin
                    alu_A = 32'd0;
                    alu_B = 32'd0;
                    alu_op = 4'b0000;
                    PC = PC + 1;
                end

            endcase
        end

        6'b001000: begin // addi
            alu_A = registers[instruction[25:21]];
            alu_B = {{16{instruction[15]}}, instruction[15:0]}; // sign-extended 
            registers[instruction[20:16]] = alu_output;
            PC = PC + 1;
        end

        6'b001001: begin // addiu
            alu_A = registers[instruction[25:21]];
            alu_B = {{16{instruction[15]}}, instruction[15:0]}; // sign-extended
            alu_op = 4'b0001;
            registers[instruction[20:16]] = alu_output;
            PC = PC + 1;
        end

        6'b001100: begin // andi
            alu_A = registers[instruction[25:21]];
            alu_B = {16'b0, instruction[15:0]}; // zero-extended immediate
            alu_op = 4'b0011;
            registers[instruction[20:16]] = alu_output;
            PC = PC + 1;
        end

        6'b001101: begin // ori
            alu_A = registers[instruction[25:21]];
            alu_B = {16'b0, instruction[15:0]}; // zero-extended immediate
            alu_op = 4'b0100;
            registers[instruction[20:16]] = alu_output;
            PC = PC + 1;
        end

        6'b001110: begin // xori
            alu_A = registers[instruction[25:21]];
            alu_B = {16'b0, instruction[15:0]}; // zero-extended immediate
            alu_op = 4'b1010;
            registers[instruction[20:16]] = alu_output;
            PC = PC + 1;
        end

        6'b001111: begin // lui
            registers[instruction[20:16]] = {instruction[15:0], 16'b0};
            PC = PC + 1;
        end

   
        6'b001010: begin // slti
            alu_A = registers[instruction[25:21]];
            alu_B = {{16{instruction[15]}}, instruction[15:0]}; // Sign-extended 
            alu_op = 4'b1000; // Less than operation
            registers[instruction[20:16]] = alu_output;
            PC = PC + 1;
        end
        
//        ist_mem_gen_1 dmem (
//  .a(dm_a),        // input wire [8 : 0] a  //write address
//  .d(dm_d),        // input wire [31 : 0] d  //write data
//  .dpra(dm_dpra),  // input wire [8 : 0] dpra  //read address
//  .clk(clk),    // input wire clk       
//  .we(dm_we),      // input wire we
//  .dpo(dm_dpo)     // output wire [31 : 0] dpo   //read output
//);

        6'b100011: begin // lw
            alu_A = registers[instruction[25:21]];
            alu_B = {{16{instruction[15]}}, instruction[15:0]}; // sign-extended offset
            alu_op = 4'b0001;
            dm_dpra = alu_output;
            
            dm_a = 10'b0;
            dm_d = 32'b0;
            dm_we = 1'b0;
            registers[instruction[20:16]] = dm_dpo;
            PC = PC + 1;
        end

        6'b101011: begin // sw
            alu_A = registers[instruction[25:21]];
            alu_B = {{16{instruction[15]}}, instruction[15:0]}; // sign-extended offset
            alu_op = 4'b0001;
            #10
            dm_a = alu_output;
            dm_we = 1'b1;
            dm_d = registers[instruction[20:16]];
            PC = PC + 1;
        end

        6'b000100: begin // beq
            alu_A = registers[instruction[25:21]];
            alu_B = registers[instruction[20:16]];
            alu_op = 4'b0111;
            //PC = (alu_output == 0) ? PC + {{16{instruction[15]}}, instruction[15:0]} : PC + 1;  
            // Current (incorrect):
            //PC = (alu_output == 0) ? PC + {{16{instruction[15]}}, instruction[15:0]} : PC + 1;

            // Should be:
            PC = (alu_output == 0) ? PC + 1 + $signed(instruction[15:0]) : PC + 1;    
        end

        6'b000101: begin // bne
            alu_A = registers[instruction[25:21]];
            alu_B = registers[instruction[20:16]];
            alu_op = 4'b0111; // Equality check
            PC = (alu_output == 1) ? PC + {{16{instruction[15]}}, instruction[15:0]} : PC + 1;
        end

        6'b000110: begin // bgt (using less than comparison)
            alu_A = registers[instruction[20:16]]; // B
            alu_B = registers[instruction[25:21]]; // A
            alu_op = 4'b1000; // Less than
            PC = (alu_output == 0) ? PC + {{16{instruction[15]}}, instruction[15:0]} : PC + 1;
        end

        6'b000111: begin // bgte (using less than comparison)
            alu_A = registers[instruction[25:21]]; // A
            alu_B = registers[instruction[20:16]]; // B
            alu_op = 4'b1000; // Less than
            PC = (alu_output == 1) ? PC + 1 : PC + {{16{instruction[15]}}, instruction[15:0]};
        end

        6'b111000: begin // ble (using less than comparison)
            alu_A = registers[instruction[25:21]]; // A
            alu_B = registers[instruction[20:16]]; // B
            alu_op = 4'b1000; // Less than
            PC = (alu_output == 1) ? PC + {{16{instruction[15]}}, instruction[15:0]} : PC + 1;
        end

        6'b001001: begin // bleq (less than or equal)
          
            alu_A = registers[instruction[25:21]];
            alu_B = registers[instruction[20:16]];
            alu_op = 4'b0111; // Equality
            if (alu_output == 1) begin
                PC = PC + {{16{instruction[15]}}, instruction[15:0]};
            end
            else begin
               
                alu_op = 4'b1000;
                PC = (alu_output == 1) ? PC + {{16{instruction[15]}}, instruction[15:0]} : PC + 1;
            end
        end

        6'b001010: begin // bleu (unsigned)
            
            alu_A = registers[instruction[25:21]];
            alu_B = registers[instruction[20:16]];
            alu_op = 4'b0010; // Subtraction
       
            PC = (alu_output[31] == 1 || alu_output == 0) ? 
                PC + {{16{instruction[15]}}, instruction[15:0]} : PC + 1;
        end

        6'b001011: begin // bgtu (unsigned)
            
            alu_A = registers[instruction[20:16]]; 
            alu_B = registers[instruction[25:21]]; 
            alu_op = 4'b0010; // Subtraction
            
            PC = (alu_output[31] == 1) ? PC + 1 : PC + {{16{instruction[15]}}, instruction[15:0]};
        end

        
        6'b000010: begin // j (jump)
            PC = instruction[9:0];
        end

        6'b000011: begin // jal (jump and link)
            registers[31] = PC + 1; 
            PC = instruction[9:0];  
        end
        
        6'b110001: begin // lwc1 (load word to floating-point register)
    alu_A = registers[instruction[25:21]];
    alu_B = {{16{instruction[15]}}, instruction[15:0]};
    alu_op = 4'b0001;
    dm_dpra = alu_output;
    dm_a = 10'b0;
    dm_d = 32'b0;
    dm_we = 1'b0;
    f_registers[instruction[20:16]] = dm_dpo;
    PC = PC + 1;
end

6'b111001: begin // swc1 (store word from floating-point register)
    alu_A = registers[instruction[25:21]];
    alu_B = {{16{instruction[15]}}, instruction[15:0]};
    alu_op = 4'b0001;
    dm_a = alu_output;
    dm_we = 1'b1;
    dm_d = f_registers[instruction[20:16]];
    PC = PC + 1;
end

        default: begin
            PC = PC + 1;
        end
        
        
    endcase
end
//end


always @(posedge clk) begin
    if (instruction == 32'b11111111111111111111111111111111) begin  // Exit condition
        dump_trigger <= 1;
    end
end

// Capture final memory contents when dump_trigger is set
always @(posedge dump_trigger) begin
    // Read the entire array into final_mem_dump
    for (i = 0; i < registers[10]; i = i + 1) begin
        dm_dpra = registers[9] + i;  // $s0 + offset
        #1;  // Small delay for memory read
        final_mem_dump[i] = dm_dpo;
    end

//    $monitor("\n--- FINAL SORTED ARRAY ---\nAddr\tValue\n------------------");
//    for (i = 0; i < registers[10]; i = i + 1) begin
//        $monitor("%4d\t%d", i, final_mem_dump[i]);
//    end

    $monitor("\nRegisters:\n$s0 = %d\n$s1 = %d\n$s2 = %d",
             registers[16], registers[17], registers[18]);
             
             $monitor("\nRegisters:\n$f0 = %d\n$f1 = %d\n$f2 = %d",
             f_registers[0], f_registers[1], f_registers[2]);

    #10 $finish;  
end
// ------------------------------------------------------
endmodule