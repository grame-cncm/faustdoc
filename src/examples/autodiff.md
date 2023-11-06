# autodiff


## noise

<!-- faust-run -->

 import("stdfaust.lib");
 process = no.noise;

<!-- /faust-run -->


## noop

<!-- faust-run -->

import("stdfaust.lib");
process = _;

<!-- /faust-run -->


## ramp

<!-- faust-run -->

process = 1e-3 : + ~ _ : %(2) : -(1);

<!-- /faust-run -->

