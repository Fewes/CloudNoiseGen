# CloudNoiseGen
<img src="http://fewes.se/img/PerlinWorley.jpg" alt="Perlin-Worley noise"></img>

A utility class for Unity which handles generating and loading periodic, cloud-like (perlin-worley) 3D noise textures for use with volumetric shaders. The noise is generated on the GPU, and so it is very fast.

# Usage
Use the <i>InitializeNoise</i> function to load/generate noise.
The generated noise is stored in Assets/Resources/CloudNoiseGen/<i>folderName</i>.
If the folder already exists and contains noise with the same resolution, it will be loaded instead of generated (unless you set the mode parameter to ForceGenerate).
When generating noise, the asset database is refreshed upon completion. This takes a few seconds. When generating noise for the first time, texture import settings need to be set. This takes a bit longer but only needs to be done once. The actual noise generation is near-instant depending on your GPU.
  
If you wish to display a preview of the noise, use the <i>GetSlice</i> function.
If you don't want to use the automatic handling of loading/generating the noise textures, you can use the <i>LoadNoise</i> and <i>GenerateNoise</i> functions instead of InitializeNoise.
  
# Limitations
Generating new noise is limited to the editor.
Generated noise must be stored in the resources folder (so it can be loaded from script in built player).
If you want to modify the way the perlin/worley noise is blended together, you need to modify the CloudNoiseGen shader.
Changing the texture import settings of the generated z slices is recommended against.
