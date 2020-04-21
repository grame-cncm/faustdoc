
import("stdfaust.lib");
drive = 0.6;
offset = 0;
process = ef.cubicnl(drive,offset) <: dm.zita_light;

