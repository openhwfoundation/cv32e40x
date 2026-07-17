// Copyright 2026 TODO:Contribution figure out the necessity and/or what to
// put here.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// TODO:Contribution find out if the common description thingy is necessary.

module cv32e40x_zicond_decoder import cv32e40x_pkg::*;
(
   // from IF/ID pipeline
   input logic [31:0] instr_rdata_i,
   output decoder_ctrl_t decoder_ctrl_o
);

  always_comb
  begin

    // Default assignments
    decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
    decoder_ctrl_o.illegal_insn = 1'b0;

    unique case (instr_rdata_i[6:0])

      OPCODE_OP: begin  // Register-Register ALU operation
        if ((instr_rdata_i[31:30] == 2'b11) || (instr_rdata_i[31:30] == 2'b10)) begin
          decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
        end else begin
          decoder_ctrl_o.alu_en           = 1'b1;
          decoder_ctrl_o.alu_op_a_mux_sel = OP_A_REGA_OR_FWD;
          decoder_ctrl_o.alu_op_b_mux_sel = OP_B_REGB_OR_FWD;
          decoder_ctrl_o.rf_we            = 1'b1;
          decoder_ctrl_o.rf_re[0]         = 1'b1;
          decoder_ctrl_o.rf_re[1]         = 1'b1; // both instructions have two operands

          unique case ({instr_rdata_i[30:25], instr_rdata_i[14:12]})
            {6'b00_0111, 3'b101}: decoder_ctrl_o.alu_operator = ALU_CZEQZ; // Conditional-zero equal-to-zero
            {6'b00_0111, 3'b111}: decoder_ctrl_o.alu_operator = ALU_CZNEZ; // Conditional-zero not-equal-to-zero
            default: begin
              decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
            end
          endcase
        end
      end

      default: begin
        decoder_ctrl_o = DECODER_CTRL_ILLEGAL_INSN;
      end
    endcase

  end // always_comb

endmodule
