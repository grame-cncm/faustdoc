
# Faust Online Documentation

[Faust](https://faust.grame.fr) is a Functional Programming Language for sound synthesis and audio processing with a strong focus on the design of synthesizers, musical instruments, audio effects, etc. Faust targets high-performance signal processing applications and audio plug-ins for a variety of platforms and standards.

This repository is intended to build the documentation of the Faust environment, and to provide the corresponding examples.

### Prerequisites
- you must have python and pip installed.
- you must have the Faust source code installed. You can get it from [github](https://github.com/grame-cncm/faust)
- you must have openssl installed for base64 convertion.


### Building the documentation

The build process is based on `make`. Building the documentation site is based on [mkdocs](https://www.mkdocs.org/).
To install the required components type:
~~~~~~~~~~~~~~~~
$ make install
~~~~~~~~~~~~~~~~

The documentation embeds a lot of Faust examples that have to be embedded into html files. 
It also extracts tags documentation from the library source code.
To generate all these files type:
~~~~~~~~~~~~~~~~
$ make all
~~~~~~~~~~~~~~~~


### Testing and generating

You can test the web site using the mkdoc embedded web server. This server also scan any change in the source directory and refresh the pages dynamically which is really convenient for the development process. To launch the server type:
~~~~~~~~~~~~~~~~
$ make serve
~~~~~~~~~~~~~~~~

When ready, you can generate the documentation web site. Type:
~~~~~~~~~~~~~~~~
$ make build
~~~~~~~~~~~~~~~~
The web site will be available from the `docs` folder at the root of the `faustdoc` folder


More details on the build process:
~~~~~~~~~~~~~~~~
$ make help
~~~~~~~~~~~~~~~~

