
import("stdfaust.lib");
process = _ <: attach(_,abs : ba.linear2db : hbargraph("Level",-60,0));

