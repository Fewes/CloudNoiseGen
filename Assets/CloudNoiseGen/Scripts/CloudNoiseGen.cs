// MIT License

// Copyright (c) 2019 Felix Westin

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
#endif

/// <summary>
/// Utility class for handling loading and generating cloud-like 3D noise on the GPU.
/// Noise generation is limited to the editor (have to be able to write to the Resources folder).
/// </summary>
public static class CloudNoiseGen
{
	[System.Serializable]
	public enum Mode
	{
		LoadAvailableElseGenerate,
		LoadAvailableElseAbort,
		ForceGenerate
	}

	[System.Serializable]
	public enum NoiseMode
	{
		Mix			= 0,
		PerlinOnly	= 1,
		WorleyOnly	= 2
	}

	[System.Serializable]
	public struct NoiseSettings
	{
		[Range(1, 8)]
		public int octaves;
		[Range(1, 16)]
		public int periods;
		[Range(0f, 2f)]
		public float brightness;
		[Range(0f, 8f)]
		public float contrast;

		public Vector4 GetParams ()
		{
			return new Vector4(octaves, periods, brightness, contrast);
		}
	}

	public static NoiseSettings perlin;
	public static NoiseSettings worley;
	public static float previewSliceZ	= 0;

	static Material _generatorMat;
	static Material generatorMat
	{
		get
		{
			if (!_generatorMat)
				// This shader does not need to be included in the game build, as texture generation is only available in the editor anyway.
				_generatorMat = new Material(Shader.Find("Hidden/CloudNoiseGen"));
			return _generatorMat;
		}
		set
		{
			_generatorMat = value;
		}
	}

	/// <summary>
	/// Update the generator material with the noise parameters.
	/// </summary>
	static void UpdateGenerator ()
	{
		generatorMat.SetVector("_PerlinParams", perlin.GetParams());
		generatorMat.SetVector("_WorleyParams", worley.GetParams());
	}

	/// <summary>
	/// Load 3D noise texture from 'Resources/3DNoise/folderName'
	/// </summary>
	/// <param name="noiseTexture">The Texture3D to fill with the result.</param>
	/// <param name="folderName">The folder name to look for/put the noise in. Relateive to 'Resources/3DNoise'.</param>
	/// <param name="resolution">The resolution of the 3D noise texture (^3).</param>
	/// <returns>True if successful.</returns>
	public static bool LoadNoise (ref Texture3D noiseTexture, string folderName, int resolution)
	{
		// Load 3D noise from folder

		#if UNITY_EDITOR
			bool validFolder = AssetDatabase.IsValidFolder("Assets/Resources/CloudNoiseGen/" + folderName);
		#else
			// TODO: If you've built noise in the editor, it is PROBABLY safe to assume it exists in the built game.
			// We should, however, probably add a check here just in case.
			bool validFolder = true;
		#endif

		if (!validFolder)
			return false;

		// Make sure dimensions match
		var slices = Resources.LoadAll("CloudNoiseGen/" + folderName + "/", typeof(Texture2D));
		if (resolution != slices.Length)
			return false;
		foreach (var slice in slices)
		{
			var tex = ((Texture2D)slice);
			if (resolution != tex.width || resolution != tex.height)
				return false;
		}

		// The array holding the pixels
		var colorArray = new Color[resolution * resolution * resolution];
		noiseTexture   = new Texture3D (resolution, resolution, resolution, TextureFormat.ARGB32, true);

		// Default all pixels to 1
		for (int p = 0; p < colorArray.Length; p++)
			colorArray[p] = new Color(1, 1, 1, 1);

		// Load each slice
		RenderTexture rt = new RenderTexture(resolution, resolution, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
		rt.filterMode = FilterMode.Point;
		rt.Create();

		int u = 0;
		foreach (var slice in slices)
		{
			var tex = ((Texture2D)slice);

			// Transfer data from 2D pixels to 3D pixel container
			foreach (var pixel in tex.GetPixels())
				colorArray[u++] = pixel;
		}

		rt.DiscardContents();
		rt = null;

		noiseTexture.SetPixels(colorArray);
		noiseTexture.Apply();

		return true;
	}

	/// <summary>
	/// Render a single 3D noise slice.
	/// </summary>
	/// <param name="rt">The RenderTexture to blit the noise to.</param>
	/// <param name="z">The z coordiante of the slice.</param>
	public static void GetSlice (ref RenderTexture rt, float z, NoiseMode noiseMode = NoiseMode.Mix)
	{
		var wasActive = RenderTexture.active;
		UpdateGenerator();
		generatorMat.SetFloat("_Slice", z);
		generatorMat.SetInt("_Mode", (int)noiseMode);
		Graphics.Blit(null, rt, generatorMat);
		RenderTexture.active = wasActive;
	}

#if UNITY_EDITOR
	/// <summary>
	/// Generate 3D noise texture in 'Resources/3DNoise/folderName'
	/// </summary>
	/// <param name="folderName">The folder name to look for/put the noise in. Relateive to 'Resources/3DNoise'.</param>
	/// <param name="resolution">The resolution of the 3D noise texture (^3).</param>
	public static void GenerateNoise (string folderName, int resolution)
	{
		// Delete existing noise textures
		if (AssetDatabase.IsValidFolder("Assets/Resources/CloudNoiseGen/" + folderName))
			FileUtil.DeleteFileOrDirectory("Assets/Resources/CloudNoiseGen/" + folderName);
		else
		{
			if (!AssetDatabase.IsValidFolder("Assets/Resources"))
				AssetDatabase.CreateFolder("Assets", "Resources");
			if (!AssetDatabase.IsValidFolder("Assets/Resources/CloudNoiseGen"))
				AssetDatabase.CreateFolder("Assets/Resources", "CloudNoiseGen");
		}
		AssetDatabase.CreateFolder("Assets/Resources/CloudNoiseGen", folderName);

		RenderTexture rt = new RenderTexture(resolution, resolution, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
		rt.filterMode = FilterMode.Point;
		rt.Create();

		Texture2D slice = new Texture2D(resolution, resolution, TextureFormat.ARGB32, false, true);
		slice.filterMode = FilterMode.Point;

		for (int u = 0; u < resolution; u++)
		{			
			// Generate z slice
			GetSlice(ref rt, ((float)u + 0.5f) / (float)resolution);

			// Transfer to temporary texture
			var rtPrev = RenderTexture.active;
			RenderTexture.active = rt;
				
			slice.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
			slice.Apply();
			RenderTexture.active = rtPrev;
				
			// Store slice
			var bytes = slice.EncodeToPNG();
			string fileNumber;
			if (u < 10)
				fileNumber = "000" + u;
			else if (u < 100)
				fileNumber = "00" + u;
			else if (u < 1000)
				fileNumber = "0" + u;
			else
				fileNumber = u.ToString();
			var assetPath =  "/Resources/CloudNoiseGen/" + folderName + "/ZSlice_" + fileNumber + ".png";
			File.WriteAllBytes(Application.dataPath + assetPath, bytes);
		}

		rt.DiscardContents();
		rt = null;

		if (Application.isPlaying)
			Object.Destroy(slice);
		else
			Object.DestroyImmediate(slice);

		// Need to refresh the asset DB so the new textures are detected
		AssetDatabase.Refresh();

		// Texture settings need to be applied on newly generated textures
		for (int u = 0; u < resolution; u++)
		{
			// Get slice name
			string fileNumber;
			if (u < 10)
				fileNumber = "000" + u;
			else if (u < 100)
				fileNumber = "00" + u;
			else if (u < 1000)
				fileNumber = "0" + u;
			else
				fileNumber = u.ToString();
			var assetPath =  "/Resources/CloudNoiseGen/" + folderName + "/ZSlice_" + fileNumber + ".png";

			var tImporter = AssetImporter.GetAtPath("Assets" + assetPath) as TextureImporter;
			if (tImporter)
			{
				bool changed = false;
				if (tImporter.textureCompression != TextureImporterCompression.Uncompressed)
				{
					tImporter.textureCompression = TextureImporterCompression.Uncompressed;
					changed = true;
				}
				if (tImporter.sRGBTexture != false)
				{
					tImporter.sRGBTexture = false;
					changed = true;
				}
				if (tImporter.isReadable != true)
				{
					tImporter.isReadable = true;
					changed = true;
				}
				if (changed)
				{
					EditorUtility.DisplayProgressBar(
						"CloudNoiseGen",
						"Setting texture import settings for slice (" + (u+1) + "/" + resolution + ")",
						(float)(u+1) / (float)resolution
						);
					AssetDatabase.ImportAsset("Assets" + assetPath);
				}
				else
				{
					EditorUtility.ClearProgressBar();
				}
			}
		}
		EditorUtility.ClearProgressBar();

		AssetDatabase.Refresh();
	}
	#endif

	/// <summary>
	/// Load or generate 3D noise texture from/in 'Resources/3DNoise/folderName'
	/// </summary>
	/// <param name="noiseTexture">The Texture3D to fill with the result.</param>
	/// <param name="folderName">The folder name to look for/put the noise in. Relateive to 'Resources/3DNoise'.</param>
	/// <param name="resolution">The resolution of the 3D noise texture (^3).</param>
	/// <param name="mode">The load/generation mode.</param>
	/// /// <returns>True if successful.</returns>
	public static bool InitializeNoise (ref Texture3D noiseTexture, string folderName, int resolution, Mode mode = Mode.LoadAvailableElseGenerate)
	{
		noiseTexture = null;

		#if !UNITY_EDITOR
			// We cannot generate new textures in stand alone player, so we have to force this behaviour
			mode = Mode.LoadAvailableElseAbort;
		#endif

		bool noiseLoaded = false;

		// Attempt to load noise
		if (mode != Mode.ForceGenerate)
			noiseLoaded = LoadNoise(ref noiseTexture, folderName, resolution);

		#if UNITY_EDITOR // Noise textures can only be generated in the editor
		if ((!noiseLoaded && mode == Mode.LoadAvailableElseGenerate) || mode == Mode.ForceGenerate)
		{
			// Generate new noise
			GenerateNoise(folderName, resolution);

			// Attempt to load noise
			noiseLoaded = LoadNoise(ref noiseTexture, folderName, resolution);

			// If we failed to load noise right after generating it, something has gone seriously wrong
			if (!noiseLoaded)
				Debug.LogError("Fatal error: Unable to load noise after generating.");
		}
			
		#endif

		return noiseLoaded;
	}
}