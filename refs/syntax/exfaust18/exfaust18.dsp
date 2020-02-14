
import("stdfaust.lib");
Xi(expr) = si.bus(n) <: par(i,n,ba.selector(n-i-1,n)) : expr 
with { 
  n = inputs(expr); 
};
toto = os.osc(440),os.sawtooth(440), os.triangle(440);
process = Xi(-);

