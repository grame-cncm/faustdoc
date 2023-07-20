
declare options "[midi:on]";
import("stdfaust.lib");

vel = hslider("vel[midi:ctrl 10]", 0, 0, 127, 1);
freq = hslider("freq[midi:ctrl 11]", 50, 50, 1000, 0.1);

process = os.osc(freq) * 0.1 * (vel / 127);

