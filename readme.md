# Matrix
![image](https://github.com/Alkaliii/Matrix/assets/53021785/f636a1ef-8f2d-4eb4-bb2b-9ef8fc38d548)

<i>A small tool that converts images into text for screens in <b>Starship Evo</b>.</i>

Matrix Downscales, Cuts, and converts each pixel of a file into a color code preceding an "." to create a "dot matrix" of text that can be pasted into a transparent screen in the game <b>Starship Evo</b>. These screens can be restitched back together to produce the inital image in a retro style without all the hassle of literal pixel art in a bad interface.

## How to Matrix
- Click 'Upload Image' or click an example button. If you're uploading, PNGs are good 👍
- Use the options on the left and below the image to tweak how the screen code is generated. Optimize and Better Colors really should be on by default.
  - <b>Subdivisions</b>, how many times an image is cut up. Results in multiple screens.
  - <b>Alpha Threshold</b>, important when 'With Transparency' isn't turned on. Pixels with an Alpha value below this value will be culled.
  - <b>Interpolation</b>, how the image is scaled.
  - <b>Vertical Offset</b>, how much the image should be offset from the screen. With 0 offset the image will appear quite a bit above the screen.
  - <b>Size</b>, the size of a section in pixels. Matrix works best with (48x48).
  - <b>Optimize</b>, reduces character count in a section by not repeating color tags between pixels that share a color.
  - <b>Better Colors</b>, uses full hex codes instead of truncating them. 'Optimize' must be on.
  - <b>With Transparency</b>, uses transparency instead of culling. Allows for semi transparent pixels.
- After you set the options to your liking click 'Regenerate'.
- Click on the buttons beside the pixel preview to copy a screen section into your clipboard. In Starship Evo press [CTRL] + [V] in the screen dialogue to set it.
- Once you're finished press the X in the corner to terminate matrix.


--

An example of Matrix Magic using Ram from Re:Zero.
![image](https://github.com/Alkaliii/Matrix/assets/53021785/fd300b43-7e3d-41f0-b4c0-5708b335868c)

