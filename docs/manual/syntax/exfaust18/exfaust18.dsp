
import("stdfaust.lib");
Xi(expr) = si.bus(n) <: par(i,n,ba.selector(n-i-1,n)) : expr 
with { 
  n = inputs(expr); 
};
process = Xi(-);

