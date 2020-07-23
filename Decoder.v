module Decoder(
	input     [31:0] instr,      // Instruktionswort
	input            zero,       // Liefert aktuelle Operation im Datenpfad 0 als Ergebnis?
        output reg       memtoreg,   // Verwende ein geladenes Wort anstatt des ALU-Ergebis als Resultat
	output reg       memwrite,   // Schreibe in den Datenspeicher
	output reg       dobranch,   // Führe einen relativen Sprung aus
	output reg       alusrcbimm, // Verwende den immediate-Wert als zweiten Operanden
	output reg [4:0] destreg,    // Nummer des (möglicherweise) zu schreibenden Zielregisters
	output reg       regwrite,   // Schreibe ein Zielregister
	output reg       dojump,     // Führe einen absoluten Sprung aus
        output reg [2:0] alucontrol // ALU-Kontroll-Bits
);
	// Extrahiere primären und sekundären Operationcode
	wire [5:0] op = instr[31:26];
	wire [5:0] funct = instr[5:0];

	always @*
	begin
            case (op)
                6'b000000: // Rtype Instruktion
                    begin
                        regwrite = 1;
                        destreg = instr[15:11];
                        alusrcbimm = 0;
                        dobranch = 0;
                        memwrite = 0;
                        memtoreg = 0;
                        dojump = 0;
                        case (funct)
                            6'b100001: alucontrol = 3'b101; // Addition unsigned
                            6'b100011: alucontrol = 3'b001; // Subtraktion unsigned
                            6'b100100: alucontrol = 3'b111; // and
                            6'b100101: alucontrol = 3'b110; // or
                            6'b101011: alucontrol = 3'b000; // set-less-than unsigned
                            6'b010010:
                                begin
                                    alucontrol = 3'b011; // mflo
                                    alusrcbimm = 1;
                                end
                            6'b010000:
                                begin
                                    alucontrol = 3'b011; // mfhi
                                    alusrcbimm = 1;
                                end
                            6'b011001:
                                begin
                                    alucontrol = 3'b100; // multu
                                    alusrcbimm = 0;
                                end
                            default:   alucontrol = 3'bx;// undefiniert
                        endcase
                    end
                6'b100011, // Lade Datenwort aus Speicher
                6'b101011: // Speichere Datenwort
                    begin
                       regwrite = ~op[3];
                       destreg = instr[20:16];
                       alusrcbimm = 1;
                       dobranch = 0;
                       memwrite = op[3];
                       memtoreg = 1;
                       dojump = 0;
                       alucontrol = 3'b101; // Addition: (Basisregister + Offset)
                    end
                6'b000100: // Branch Equal
                    begin
                       regwrite = 0;
                       destreg = 5'bx;
                       alusrcbimm = 0;
                       dobranch = zero; // Gleichheitstest
                       memwrite = 0;
                       memtoreg = 0;
                       dojump = 0;
                       alucontrol = 3'b001; // Subtraktion
                    end
                6'b001001: // Addition immediate unsigned
                    begin
                       regwrite = 1;
                       destreg = instr[20:16];
                       alusrcbimm = 1;
                       dobranch = 0;
                       memwrite = 0;
                       memtoreg = 0;
                       dojump = 0;
                       alucontrol = 3'b101; // Addition
                    end
                6'b000010: // Jump immediate
                    begin
                       regwrite = 0;
                       destreg = 5'bx;
                       alusrcbimm = 0;
                       dobranch = 0;
                       memwrite = 0;
                       memtoreg = 0;
                       dojump = 1;
                       alucontrol = 3'bx; // unused
                    end
                6'b001111: // Load upper immediate LUI
                    begin
                        regwrite = 1;
                        destreg = instr[20:16];
                        alusrcbimm = 1;
                        dobranch = 0;
                        memwrite = 0;
                        memtoreg = 0;
                        dojump = 0;
                        alucontrol = 3'b010; // Addition (a = 0; b = imm)
                    end
                6'b001101: // Or immediate ORI
                    begin
                        regwrite = 1;
                        destreg = instr[20:16];
                        alusrcbimm = 1;
                        dobranch = 0;
                        memwrite = 0;
                        memtoreg = 0;
                        dojump = 0;
                        alucontrol = 3'b110; // a or b
                    end
                6'b000001: // Branch Less Than Zero BLTZ
                    begin
                        regwrite = 0;
                        destreg = 5'bx;
                        alusrcbimm = 0;
                        dobranch = ~zero; //Wenn !zero 1 ist, ist a < 0
                        memwrite = 0;
                        memtoreg = 0;
                        dojump = 0;
                        alucontrol = 3'b010; // a < b (mit b=0)
                    end
                6'b000011: // jal jump and save pc+4 in reg31
                    begin
                        regwrite = 1;
                        destreg = 5'd31;
                        alusrcbimm = 1'b0;
                        dobranch = 0;
                        memwrite = 0;
                        memtoreg = 0;
                        dojump = 1;
                        alucontrol = 3'b101; // a + b
                    end
                default: // Default Fall
                    begin
                       regwrite = 1'bx;
                       destreg = 5'bx;
                       alusrcbimm = 1'bx;
                       dobranch = 1'bx;
                       memwrite = 1'bx;
                       memtoreg = 1'bx;
                       dojump = 1'bx;
                       alucontrol = 3'bx; // unused
                    end
            endcase
	end
endmodule

