
These are the Matlab files for the Revision 2.5 of the K6JCA FPGA SDR Simulink model, previously based on Dick Benson W1QG design of FPGA software radio logic using Simulink software. I have adapted to BeagleSDR board.

Notes:

    Before you start, install Matlab 2012b but not a recent version of Matlab because Xilinx System Generator component of Xilinx blockset really is NOT compatible with newer version of Matlab.
    Rename or copy Xcvr_SSB_AM_2p5-BeagleSDR.mdl to Xcvr_SSB_AM_2p5.mdl (or slx file). Some advices are given here :
    
    1.  The Matlab Simulink design should be adapted to BeagleSDR Xilinx 3s500e Development Board.
    
    2.  The Matlab version that I used is R2012b along with Simulink, and Xilinx ISE 14.7 DSP System Generator.
    
    3.  The Simulink Model file (Xcvr_SSB_AM_2p5.mdl) is the design file. All other files are ancillary files.
    
    4.  You will need the Xilinx ISE Design Suite 14.7 for the Xilinx blockset required by the Simulink model.
    
    5.  You have to click on the red X as "Xilinx System Generator" icon that is on the top level of the Simulink model. Around 43 minutes are required for the first time. The .xise files is created by Simulink model, click on "Generate program File".
    
    6.  In the Xilinx ISE Design Suite, use the Xilinx "Project Navigator" to convert the .xise file into the final .bit file.
    
    7.  Open netlist_2p5/xcvr_ssb_am_2p5_mcw.xise project. Edit the xcvr_ssb_am_2p5_mcw.ucf to set correct hf_adc and tx_dac pins among other pins and all other if necessary...
    
    8.  If you encounter some Xilinx ISE messages of :
    errors in XST stating that it cannot process timing constraints.
    ERROR:Xst:1617 - Processing TIMESPEC TS_clk_16384_dc300de7: TNM...
    ERROR:Xst:1489 - Constraint annotation failed.
    xst compilation stops. This is how we can resolve this issue :
    delete .XCF file from matlab simulink generation that XST was reading in
    right click on "Synthesize - XST" in Design menu
    Process > Properties > Synthesis Options > switch name -uc, property name Synthesis Constraints File option > delete the xcf file
    In same window, now double click on Generation Programming File
    
    9. Add "NET "clk_xxx" CLOCK_DEDICATED_ROUTE = FALSE;" in the .ucf file for each clock
    
    10.  Finally  use iMPACT (from the Xilinx ISE) to load the .bit file into the FPGA itself.


Ext link :

    http://k6jca.blogspot.com/2017/02/an-fpga-sdr-hf-transceiver-part-1.html
    http://www.w5cz.com/fpga_dsp1.pdf

The original files from :

   https://github.com/k6jca/fpga-sdr-rev-2.5
