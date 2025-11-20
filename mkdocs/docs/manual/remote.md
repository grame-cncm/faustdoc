# Remote compilation

Compiling a same Faust DSP program on different platforms and targets (applications and plugins) can be a tedious task when SDKs have to be installed and configurated, or when the user want to do cross-compilation. 

A remote compilation service has been developed to simplify this process. It allows to send DSP source code on a cloud based infrastructure, which hosts a lot of targets and can do cross-compilation. This service is accessible: 

- in several applications like [FaustLive](https://github.com/grame-cncm/faustlive), [Faust Editor](https://github.com/grame-cncm/fausteditor) or [Faust IDE](https://github.com/grame-cncm/faustide)

- with a dedicated API explained in more details in the [faustservice](https://github.com/grame-cncm/faustservice) project and in the [FaustWeb client](https://github.com/grame-cncm/faustservice/tree/master/client) tool

- with the [faustremote](#faustremote) script. 

  
## faustremote

The [faustremote](https://github.com/grame-cncm/faust/blob/master-dev/tools/faust2appls/faustremote) script (part of the Faust distribution), allows to access the remote compilation service and execute compilation requests: 

- `faustremote [<servurl>] [<platform> <arch> <srcfile>]` returns the list of *platform* and *arch* for each platform.  When no `<servurl>` is defined, the default GRAME Faust URL service is used. Then a given DSP file can be compiled using a command like `faustremote osx coreaudio-qt` to return the compiled result as a ZIP file. 

- if DSP libraries are needed in the DSP program, a ZIP file containing all required resources can be prepared and sent.

- the `source` and `any` parameters can be used to produce code for any of the supported backend. The wanted options have to be defined using a `compile_options` metadata, like for instance `declare compile_options -lang c -cn foo -double` to compile with the C backend. By default, the resulting file will have the `.txt`extension. 
