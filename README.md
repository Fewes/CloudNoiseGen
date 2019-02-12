# CloudNoiseGen
<img src="http://fewes.se/img/PerlinWorley.jpg" alt="Perlin-Worley noise"></img>

A static utility class for Unity which handles generating and loading periodic, cloud-like (perlin-worley) 3D noise textures for use with volumetric shaders. The noise is generated on the GPU, and so it is very fast.

# Usage
Use the <i>perlin</i> and <i>worley</i> variables to set the amount of octaves, periods, brightness and contrast of the Perlin and Worley noise respectively.<br>
Use the <i>InitializeNoise</i> function to load/generate noise.<br>
The generated noise is stored in <i>Assets/Resources/CloudNoiseGen/folderName</i>.<br>
If the folder already exists and contains noise with the same resolution, it will be loaded instead of generated (unless you set the mode parameter to ForceGenerate).<br>
When generating noise, the asset database is refreshed upon completion. This takes a few seconds. When generating noise for the first time, texture import settings need to be set. This takes a bit longer but only needs to be done once. The actual noise generation is near-instant depending on your GPU.
  
If you wish to display a preview of the noise, use the <i>GetSlice</i> function.<br>
If you don't want to use the automatic handling of loading/generating the noise textures, you can use the <i>LoadNoise</i> and <i>GenerateNoise</i> functions instead of InitializeNoise.
  
# Limitations
Generating new noise is limited to the editor.<br>
Generated noise must be stored in the resources folder (so it can be loaded from script in built player).<br>
If you want to modify the way the perlin/worley noise is blended together, you need to modify the <i>CloudNoiseGen</i> shader.<br>
Changing the texture import settings of the generated z slices is recommended against.

# Credits
<b>Perlin Noise</b> <br>
Noise Shader Library for Unity - https://github.com/keijiro/NoiseShader <br>
Original work (webgl-noise) Copyright (C) 2011 Stefan Gustavson <br>
Translation and modification was made by Keijiro Takahashi

<b>Worley Noise</b> <br>
Worley noise implementation for WebGL shaders - https://github.com/Erkaman/glsl-worley <br>
Original work (GLSL-cellular-noise) Copyright (C) 2011 Stefan Gustavson <br>
Translation and modification was made by Eric Arnebäck <br>
Periodic modification was made by Felix Westin

All source code is distributed under the MIT license.<br>
See <i>CloudNoiseLib.cginc</i> for full details
