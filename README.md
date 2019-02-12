# CloudNoiseGen
A utility class for Unity which handles generating and loading cloud-like (perlin-worley) 3D noise textures for use with volumetric shaders. The noise is generated on the GPU, and so it is very fast.

# Usage
Use the InitializeNoise function to load/generate noise.
The generated noise is stored in Assets/Resources/CloudNoiseGen/<folderName>. If the folder already exists and contains noise with the same resolution, it will be loaded instead of generated (unless you set the mode parameter to ForceGenerate).
  
If you wish to display a preview of the noise, use the GetSlice function.
  
# Limitations
Generating new noise is limited to the editor.
Generated noise must be stored in the resources folder (so it can be loaded from script in built player).
If you want to modify the way the perlin/worley noise is blended together, you need to modify the CloudNoiseGen shader.
Changing the texture import settings of the generated z slices is not recommended.
