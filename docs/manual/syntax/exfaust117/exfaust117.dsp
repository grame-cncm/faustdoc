
import("stdfaust.lib");
process = _ <: attach(_,abs : ba.linear2db : vbargraph("Level[unit:dB]",-60,0));

