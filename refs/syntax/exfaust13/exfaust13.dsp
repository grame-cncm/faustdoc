
import("stdfaust.lib");
drive = 0.6;
offset = 0;
process = dm.zita_light :> ef.cubicnl(drive,offset);

