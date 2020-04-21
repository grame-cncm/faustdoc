
import("stdfaust.lib");
process = 
	dm.cubicnl_demo : // distortion 
	dm.wah4_demo <: // wah pedal
	dm.phaser2_demo : // stereo phaser 
	dm.compressor_demo : // stereo compressor
	dm.zita_light; // stereo reverb

