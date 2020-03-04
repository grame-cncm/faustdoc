
import("stdfaust.lib");
drive = 0.6;
offset = 0;
autoWahLevel = 1;
process = ef.cubicnl(drive,offset) : ve.autowah(autoWahLevel);

