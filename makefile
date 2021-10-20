###### NOMBRE MODULO QUE SE VA A SINTETIZAR SIN .v
NAME = muxpar
###### CAMBIAR PARAMETROS BUS_SIZE, WORD_SIZE
###### VALORES POR DEFECTO: BUS_SIZE = 32, WORD_SIZE = 4
BUS_SIZE = 32
WORD_SIZE = 4
all: copiar yosys compilar
compilar:
	iverilog testbench.v
	vvp ./a.out
	rm ./a.out
yosys:
	cp ./UTILIDADES/SEED/script.ys ./UTILIDADES/script.ys
	sed -i 's|SUSTITUIR|$(NAME)|g' ./UTILIDADES/script.ys
	yosys -f script ./UTILIDADES/script.ys
	sed -i 's|$(NAME)|synth_$(NAME)|g' ./synth_$(NAME).v
	sed -i 's|_out|_out_synt|g' ./synth_$(NAME).v
cambiar:
	sed -i 's|clk|clk_2f|g' mux4x2_8bits.v probador.v
copiar:
	bash ./UTILIDADES/script.sh $(BUS_SIZE) $(WORD_SIZE)
borrar:
	rm *~ *.v *.gtkw *.vcd

