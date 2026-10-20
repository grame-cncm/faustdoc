
import("stdfaust.lib");
drive = 0.6;
offset = 0;
process = par(i,2,dm.zita_light) :> par(i,2,ef.cubicnl(drive,offset));

