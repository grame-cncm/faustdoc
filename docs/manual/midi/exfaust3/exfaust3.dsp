
declare options "[midi:on]";
import("stdfaust.lib");
process = (os.osc(500)*en.adsr(0.1, 0.1, 0.8, 0.5, button("gate1[midi:key 60]")),
          os.osc(800)*en.adsr(0.1, 0.1, 0.8, 1.0, button("gate2[midi:key 62]")),
          os.osc(200)*en.adsr(0.1, 0.1, 0.8, 1.5, button("gate3[midi:key 64]"))) :> _;

