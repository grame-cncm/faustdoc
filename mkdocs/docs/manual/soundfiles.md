# Soundfiles Support

Soundfiles can be used with the  `soundfile`  language primitive. Soundfiles will be fully loaded in memory at runtime and will be accessed with an input read index. The length and sample rate of the soundfiles can be accessed to implement more sphisticated playing schemes. A more complete description of the  `soundfile`  primitive can be [found here](https://faustdoc.grame.fr/manual/syntax/).

## Using soudnfiles with the faust2xx scripts

Since using sound files (actually all formats that can be read by the [libsndfile library](http://www.mega-nerd.com/libsndfile/), have to be « embedded with the generated binary » (application or plugin), we added a *-soundfile* option in some of the *faust2xx* scripts to deal with that. Assuming a DSP program using the  `soundfile` primitive is written, the following commands can be used to generate binaries:

- `faust2caqt -soundfile foo.dsp` to embed the needed sound files in the application bundle on OSX

- `faust2max6 -soundfile foo.dsp` to embed the needed sound files in the Max/MSP external bundle on OSX

Check the [faust2xx]( https://faustdoc.grame.fr/manual/tools/) script description page to know which one currently support the *-soundfile* option.

### The Soundfile Library

They are some additional functions in the [soundfiles.lib](https://faustlibraries.grame.fr/libs/soundfiles/) library. Three basic functions are fully documented for now. There is more code already written in the [library source](https://github.com/grame-cncm/faustlibraries/blob/master/soundfiles.lib) that allows to read sound files with different kind of interpolation.

Note that the soundfile primitive is not yet managed in the [Faust Web IDE](https://faustide.grame.fr).
