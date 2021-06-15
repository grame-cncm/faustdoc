# Remote compilation

Compiling a same Faust DSP program on different platforms and targets (applications and plugins) can be a tedious task when SDKs have to be installed and configurated, or when the user want to do cross-compilation. 

A remote compilation service has been developed to simplify this process. It allows to send DSP source code on a cloud based infrastructure, which hosts a lot of targets and can do cross-compilation. This service is accessible in several applications like [FaustLive](https://github.com/grame-cncm/faustlive), [Faust Editor](https://github.com/grame-cncm/fausteditor) or [Faust IDE](https://github.com/grame-cncm/faustide), but can also be used with a dedicated API explained in more details in the [faustservice](https://github.com/grame-cncm/faustservice) project and in the [FaustWeb client](https://github.com/grame-cncm/faustservice/tree/master/client) tool. 



