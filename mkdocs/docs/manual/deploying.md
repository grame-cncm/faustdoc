# Deploying Faust DSP on the Web

Using developments done for the Web (WebAssembly backends and **libfaust** library compiled in WebAssembly with [Emscripten](https://emscripten.org/)), statically and dynamically Faust generated WebAudio nodes can be easily produced and deployed on the Web. 

## The faustwasm package

The [FaustWasm library](https://www.npmjs.com/package/@grame/faustwasm?activeTab=readme) presents a convenient, high-level API that wraps around Faust compiler. This library's interface is primarily designed for TypeScript usage, although it also provides API descriptions and documentation for pure JavaScript. The WebAssembly version of the Faust Compiler, compatible with both Node.js and web browsers, has been compiled using Emscripten 3.1.31.

The library offers functionality for compiling Faust DSP code into WebAssembly, enabling its utilization as WebAudio nodes within a standard WebAudio node graph. Moreover, it supports offline rendering scenarios. Furthermore, supplementary tools can be employed for generating SVGs from Faust DSP programs.

## Exporting for the Web

Web targets can be exported from the [Faust Editor](https://fausteditor.grame.fr) or [Faust IDE](https://faustide.grame.fr) using the remote compilation service. Choose `Platform = web`, then `Architecture` with one of the following target:

- `wasmjs` allows you to export a ready to use Web audio node to be integrated in an application. An example of HTML and JavaScript files demonstrates how the node can be loaded and activated.

- `wasmjs-poly` allows you to export a ready to use polyphonic MIDI controllable Web audio node to be integrated in an application. An example of HTML and JavaScript files demonstrates how the node can be loaded and activated.

- `webaudiowasm` allows you to export a ready to use Web audio node with a prebuilt GUI, that can be installed as a [Progressive Web Application](https://en.wikipedia.org/wiki/Progressive_web_app). An example of HTML and JavaScript files demonstrates how the node can be loaded and activated.

- `webaudiowasm-poly` allows you to export a ready to use polyphonic MIDI controllable Web audio node with a prebuilt GUI, that can be installed as a [Progressive Web Application](https://en.wikipedia.org/wiki/Progressive_web_app). An example of HTML and JavaScript files demonstrates how the node can be loaded and activated.

- `pwa` allows you to export a ready to use [Progressive Web Application](https://en.wikipedia.org/wiki/Progressive_web_app) with a prebuilt GUI, directly usable in the page, and that can possibly be installed and run on smartphone or tablet using the QR Code.

- `pwa-poly` allows you to export a ready to use polyphonic MIDI controllable [Progressive Web Application](https://en.wikipedia.org/wiki/Progressive_web_app) with a prebuilt GUI, directly usable in the page, and that can possibly be installed and run on smartphone or tablet using the QR Code.

## The faust-web-component package

Tthe [faust-web-component](https://github.com/grame-cncm/faust-web-component) package provides two web components for embedding interactive Faust snippets in web pages:

- `<faust-editor>` displays an editor (using [CodeMirror 6](https://codemirror.net/)) with executable, editable Faust code, along with some bells & whistles (controls, block diagram, plots) in a side pane.
This component is ideal for demonstrating some code in Faust and allowing the reader to try it out and tweak it themselves without having to leave the page, and can [been tested here](https://codepen.io/St-phane-Letz/pen/YzdZZoK). 

- `<faust-widget>` just shows the controls and does not allow editing, so it serves simply as a way to embed interactive DSP, and can [been tested here](https://codepen.io/St-phane-Letz/pen/LYMWybP).

These components are built on top of [faustwasm](https://github.com/grame-cncm/faustwasm) and [faust-ui](https://github.com/Fr0stbyteR/faust-ui) packages and is released as a [npm package](https://www.npmjs.com/package/@grame/faust-web-component).

## Exporting WAM 2.0 plugins

[WAM 2.0 plugin](http://www.webaudiomodules.com/docs/intro/) can be exported from the [Faust Editor](https://fausteditor.grame.fr) or [Faust IDE](https://faustide.grame.fr) using the remote compilation service, and are built using the [faust2wam](https://github.com/Fr0stbyteR/faust2wam) project. A complete tutorial can be [found here](http://www.webaudiomodules.com/docs/usage/generate-with-faustide). Choose `Platform = web`, then `Architecture` with one of the following target:

- `wam2-ts` allows you to export a ready to use WAM 2.0 plugin.  

- `wam2-poly-ts` allows you to export a ready to use polyphonic MIDI controllable WAM 2.0 plugin. 

- `wam2-fft-ts` allows you to export a ready to use WAM 2.0 plugin using the FFT architecture presented in [this paper](https://inria.hal.science/hal-04507625/document).

