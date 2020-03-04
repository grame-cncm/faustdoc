
import("stdfaust.lib");
process = _ <: attach(_,abs : ba.linear2db : vbargraph("Level",-60,0));

