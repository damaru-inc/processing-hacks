# processing-hacks
This contains examples of [Processing](https://processing.org) scripts.

N.B. These depend on a new feature I hoping to add to the [Processing Sound library](https://github.com/processing/processing-sound/pull/82).
They won't work for you unless you download the branch I hope gets pulled, and install it yourself which is easy enough.

So far I have only documented one of these:

## fftStereo

This shows how to use the FFT library with a stereo signal.

A sound file is provided for testing. It produces a series of sine tones, panning left to right,
at the following frequencies: 300, 600, 900, 1200, 2000, 3000, 5000, 8000, 12,000, and 16,000.
It was created using [this code](https://github.com/damaru-inc/jsyn-hacks/blob/main/src/main/java/com/damaru/sound/PlayTonePanned.java).

The Processing script demonstrates a new feature with the FFT library that lets you analyze chunks of sound
so that you can run processing in non-real time, and generate an animation that
is in sync with the audio even when it takes a long time to render each frame.

Each time a frame is rendered, i.e. each time draw() is called, we take a frame's worth of data out of the sound file,
extract left and right channels, and get the fft results, which are used to draw a bar graph.

We also trim each chunk of audio so that it starts and ends near the zero crossing. This reduces some of the jitter.

The fft isn't always perfect. Because the audio is composed of simple sine tones, one would expect each tone to 
be in a single fft band. But this isn't always the case, probably because fft works best if given input that can loop perfectly,
i.e. it has a whole number of cycles.

We found that the quality improves if we trim each sample so that it starts and ends near the zero crossing. That's what the trimArray function is for.

Once you run this script, you can take the images in the resulting data subdirectory, along with the sound file,
and import them into a video editing tool such as Shotcut.

You can import the first image into a video track, and in its properties, select 'Image sequence'. Then import the sound file into an audio track.

The audio and video should be synchronized.

The resulting video can be found [here](https://drive.google.com/file/d/1RnATGCmQFcBhGEZFJz1kJ8kirmZO3rjo/view?usp=sharing).
