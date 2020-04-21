
import("stdfaust.lib");
tableSize = 48000;
recIndex = (+(1) : %(tableSize)) ~ *(record);
readIndex = readSpeed/float(ma.SR) : (+ : ma.decimal) ~ _ : *(float(tableSize)) : int;
readSpeed = hslider("[0]Read Speed",1,0.001,10,0.01);
record = button("[1]Record") : int;
looper = rwtable(tableSize,0.0,recIndex,_,readIndex);
process = looper;

