`timescale 1ns / 1ps
module bootloader (
  input wire clk,
  input wire reset,
  output wire [31:0] address,
  output wire [31:0] data,
  output wire read,
  output wire write,
  output wire [31:0] instruction,
  output wire [7:0] error_code,
  output wire [7:0] status
);

  reg [31:0] state;
  reg [31:0] counter;
  reg [31:0] program_counter;
  reg [31:0] program_size;
  reg [7:0] error_code_reg;
  reg [7:0] status_reg;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= 0;
      error_code_reg <= 0;
      status_reg <= 0;
    end else begin
      case (state)
        0: begin
          // Başlangıç durumu
          state <= 1;
          counter <= 0;
          program_counter <= 0;
          program_size <= 0;
          error_code_reg <= 0;
          status_reg <= 8'h01; // Başlatılıyor
        end
        1: begin
          // QSPI Flash Bellek'ten başlık bilgisi okuma
          if (counter < 8) begin
            read <= 1;
            address <= counter;
            counter <= counter + 1;
          end else begin
            read <= 0;
            state <= 2;
          end
        end
        2: begin
          // Başlık bilgisi işleme
          if (counter < 8) begin
            data <= data_in;
            counter <= counter + 1;
          end else begin
            program_size <= data[31:0];
            counter <= 0; // Sayaç sıfırlanır
            state <= 3;
          end
        end
        3: begin
          // QSPI Flash Bellek'ten program okuma
          if (counter < program_size) begin
            read <= 1;
            address <= program_counter + counter;
            counter <= counter + 1;
          end else begin
            read <= 0;
            state <= 4;
          end
        end
        4: begin
          // Programı buyruk belleğine yazma
          if (counter < program_size) begin
            write <= 1;
            address <= counter;
            data <= data_in;
            counter <= counter + 1;
          end else begin
            write <= 0;
            state <= 5;
          end
        end
        5: begin
          // Programı başlatma
          program_counter <= 0;
          state <= 6;
        end
        6: begin
          // Program çalışıyor
          instruction <= program_memory[program_counter];
          program_counter <= program_counter + 1;
        end
      endcase
    end
  end

  always @(posedge clk) begin
    if (error_code_reg != 0) begin
      status_reg <= 8'h02; // Hata
    end else if (state == 6) begin
      status_reg <= 8'h03; // Çalışıyor
    end
  end

  assign error_code = error_code_reg;
  assign status = status_reg;

endmodule
