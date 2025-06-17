# Sound files Support

Sound files can be used with the `soundfile` language primitive. Sound files will be fully loaded in memory at init time and will be accessed with an input read index. The length and sample rate of the sound files can be accessed to implement more sophisticated playing schemes. A more complete description of the `soundfile` primitive can be [found here](../manual/syntax.md#soundfile-primitive).

## Using sound files with the faust2xx scripts

Since using sound files (actually all formats that can be read by the [libsndfile library](http://www.mega-nerd.com/libsndfile/), or by JUCE if you use the *faust2juce* tool), have to be *embedded with the generated binary* (application or plugin), the *-soundfile* option has been added in some of the *faust2xx* scripts to do that. Assuming a DSP program using the  `soundfile` primitive is written, the following commands can be used to generate binaries:

- `faust2caqt -soundfile foo.dsp` to embed the needed sound files in the application bundle on OSX

- `faust2max6 -soundfile foo.dsp` to embed the needed sound files in the Max/MSP external bundle on OSX

Check the [faust2xx]( ../manual/tools.md) script description page to know which ones currently support the *-soundfile* option.

## The Soundfile Library

There are some additional functions in the [soundfiles.lib](https://faustlibraries.grame.fr/libs/soundfiles/) library. Three basic functions are fully documented for now. There is more code already written in the [library source](https://github.com/grame-cncm/faustlibraries/blob/master/soundfiles.lib) that can read sound files with different kinds of interpolation.

The `soundfile` primitive can be used in the Web platform. See the [Faust Web IDE](https://github.com/grame-cncm/faustide?tab=readme-ov-file#soundfiles-access) related documentation.
