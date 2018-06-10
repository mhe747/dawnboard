
These are the Matlab files for the Revision 2.5 of the K6JCA FPGA SDR Simulink model, previously based on Dick Benson W1QG design of FPGA software radio logic using Simulink software.
I have adapted to BeagleSDR board.

Notes:

    Before you start, install Matlab 2012b but not a recent version of Matlab because Xilinx System Generator component of Xilinx blockset really is NOT compatible with newer version of Matlab.
    Rename or copy Xcvr_SSB_AM_2p5-BeagleSDR.mdl to Xcvr_SSB_AM_2p5.mdl    
    1.  The Matlab Simulink design has been adapted to BeagleSDR Xilinx 3s500e Development Board.
    2.  The Matlab version that I used R2012b along with Simulink, along with Xilinx ISE 14.7 DSP System Generator.
    3.  The Simulink Model file (Xcvr_SSB_AM_2p5.mdl) is THE design file. All other files are ancillary files.
    4.  You will also need the Xilinx ISE Design Suite for the Xilinx blockset required by the Simulink model.
    5.  You have to click on the red X as "Xilinx System Generator" icon that is on the top level of the Simulink model. 
    6.  In the Xilinx ISE Design Suite, use the Xilinx "Project Navigator" to convert the .xise file into the final .bit file.
    7.  The .xise files is created by Simulink model.
    8.  And then use iMPACT (from the Xilinx ISE) to load the .bit file into the FPGA itself.


Ext link :

    http://k6jca.blogspot.com/2017/02/an-fpga-sdr-hf-transceiver-part-1.html
    http://www.w5cz.com/fpga_dsp1.pdf

The original files from :

   https://github.com/k6jca/fpga-sdr-rev-2.5