
# Guido Music Notation Format

The GUIDO Music Notation Format (GMN) is a general purpose formal language for representing score level music in a platform independent, plain-text and human-readable way. This repository is intended to build the documentation of the language, and to provide the corresponding examples. 

### Prerequisites
- you must have python and pip installed.
- you must have the Guidolib source code installed. You can get it from [github](https://github.com/grame-cncm/guidolib)
- you must have the following Guido tools available from the command line :
	- guido2svg
	- guidogetpagecount
  see the guidolib build process


### Building the documentation

The build process is based on `make`. Building the documentation site is based on [mkdocs](https://www.mkdocs.org/).
To install the required components type:
~~~~~~~~~~~~~~~~
$ make install
~~~~~~~~~~~~~~~~

The documentation embeds a lot of GMN examples that have to be embedded into html files. 
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

