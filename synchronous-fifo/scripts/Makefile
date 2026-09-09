compile:
	iverilog -g2012 -o sim/sync_fifo.out ../src/sync_fifo.sv ../tb/sync_fifo_tb.sv

run: compile
	vvp sim/traffic_light.out

wave: run
	gtkwave sim/traffic_light.vcd

clean:
	rm -f sim/*.out sim/*.vcd
