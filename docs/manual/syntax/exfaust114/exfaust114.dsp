
import("stdfaust.lib");
process = _ <: attach(_,abs : ba.linear2db : vbargraph("Level[style:dB]",-60,0));

