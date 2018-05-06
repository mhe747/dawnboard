# c2verilog adapted to BeagleSDR    - Tested, working

## 

The tool had been conceived by J. Dawson, which should be capable of running any implementable C codes in sequential execution pipeline.
      http://dawsonjon.pythonanywhere.com/
      
It allows the automatical conversion without human effort from C computer programming language to Verilog hardware description language used to model electronic systems. It is most commonly used in the design of FPGA. You may wonder how this is possible ? 
Actually, each instruction in C is sequentially processed by FPGA Soft Processor in 3 stages.
This just is quite simple 16-bit 3-stages processor, one clock by stage.
The CPU can access to peripheral parts by STB/ACK techniques, but need specific hdl design usually with FIFO buffer.
If you want something more specific with parallelism data processing, the technique may not be suitable to your requirement.      
This approach really is something similar to Butterfly/Papilio FPGA project if you are not unfamiliar to that kind of products.
The goal was to convert any Arduino sketch written in pseudo-C language into Verilog implementable in FPGA.
Then, the design flow may be integrated in Xilinx ISE project.

------

## FPGA / C co-design

      Open to edit "user_design.c" in /source directory
      The pin configuration "beagleSDR.ucf" is inside directory /xilinx_input
      Launch make.bat in windws command prompt (you need to install python 2.7 and all required libs)
      Watch out user_design.v from user_design.c now converted according to c2verilog
      Open BeagleSDR.xise with Xilinx ISE, check every user_design.v and other vhd files
      Compile all project files to create program .bit file
      Program the FPGA with Impact
