
import("stdfaust.lib");
ar(a,r,g) = v
letrec {
  'n = (n+1) * (g<=g');
  'v = max(0, v + (n<a)/a - (n>=a)/r) * (g<=g');
};
gate = button("gate");
process = os.osc(440)*ar(1000,1000,gate);

