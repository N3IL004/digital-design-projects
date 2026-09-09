compile:
	iverilog -g2012 -o sim/traffic_light.out ../src/traffic_light.sv ../tb/traffic_light_tb.sv

run: compile
	vvp sim/traffic_light.out

wave: run
	gtkwave sim/traffic_light.vcd

clean:
	rm -f sim/*.out sim/*.vcd