module bootloader_tb;

  reg clk;
  reg reset;
  wire [31:0] address;
  wire [31:0] data;
  wire read;
  wire write;
  wire [31:0] instruction;
  wire [7:0] error_code;
  wire [7:0] status;

  bootloader bootloader_inst (
    .clk(clk),
    .reset(reset),
    .address(address),
    .data(data),
    .read(read),
    .write(write),
    .instruction(instruction),
    .error_code(error_code),
    .status(status)
  );

  initial begin
    clk <= 0;
    reset <= 1;
    #100;
    reset <= 0;
    #100;
