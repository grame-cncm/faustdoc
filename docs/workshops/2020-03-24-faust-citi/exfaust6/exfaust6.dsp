
import("stdfaust.lib");

// Phénomène de repliement de fréquence si l'on va au-delà de SR/2

process = os.osc(hslider("freq", 440, 20, 20000, 1));


