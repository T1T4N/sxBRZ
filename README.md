# sxBRZ
A Swift port of the [xBRZ](https://sourceforge.net/projects/xbrz/) high quality image upscaling filter by Zenju

#### This project is a WIP.

It is not production ready and performance optimized. 
If you need that please use the [original library.](https://sourceforge.net/projects/xbrz/)

There is a known bug (and probably some unknown) present because of which the output differs slightly from the original library's in that it's more pixelated. Example with 3x magnification:

![sxBRZ Output](http://i.imgur.com/KS7vobw.png "sxBRZ Output")
![xBRZ Output](http://i.imgur.com/ETN1UTy.png "xBRZ Output")

#### I am actively working on the project and sooner or later this issue should be resolved.
If anyone manages to figure it out in the meantime, pull requests are welcome.

#### This project also contains the [original library](https://sourceforge.net/projects/xbrz/) and an Objective-C wrapper to use it directly from Swift. 
#### The wrapper was made after [romitagl's example](https://github.com/romitagl/shared)
