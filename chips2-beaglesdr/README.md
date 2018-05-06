# c2verilog adapted to BeagleSDR    - Tested, working

## User
This tools allows the automatical conversion from C instructions to verilog. You may wonder how it is possible ? 
Actually, each instruction in C is processed by FPGA Soft Processor in 3 stages.
Each stage needs one cpu clock. This is quite simple yet efficient 16-bit 3-stages processor created by the tool.
The CPU can access to peripheral parts by STB/ACK techniques.

The tool had been conceived by J. Dawson, which should be capable of running any implementable C codes in sequential execution pipeline
      http://dawsonjon.pythonanywhere.com/
      
This approach really is something similar to Butterfly/Papilio FPGA project if you are not unfamiliar to that kind of products.
The goal was to convert any Arduino sketchs written in C language to Verilog language implemented in FPGA.
Then, the design flow may be integrated in Xilinx ISE project.

------

## FPGA / C co-design

First open to edit "user_design.c" in /source directory
The pin configuration "beagleSDR.ucf" is in directory /xilinx_input
launch make.bat in windws command prompt (you need to install python and all required libs)
user_design.v had to be created according to user_design.c in /source directory
open BeagleSDR.xise with Xilinx ISE
compile all project files to create program .bit file
Program the FPGA with Impact
