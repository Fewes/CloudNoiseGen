// MIT License

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

#ifndef CLOUDNOISELIB_INCLUDED
#define CLOUDNOISELIB_INCLUDED

// ------------------------------ PERLIN NOISE ------------------------------

//
// Noise Shader Library for Unity - https://github.com/keijiro/NoiseShader
//
// Original work (webgl-noise) Copyright (C) 2011 Stefan Gustavson
// Translation and modification was made by Keijiro Takahashi.
//
// This shader is based on the webgl-noise GLSL shader. For further details
// of the original shader, please see the following description from the
// original source code.
//

//
// GLSL textureless classic 3D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-10-11
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
//

float3 mod(float3 x, float3 y)
{
	return x - y * floor(x / y);
}

float3 mod289(float3 x)
{
	return x - floor(x / 289.0) * 289.0;
}

float4 mod289(float4 x)
{
	return x - floor(x / 289.0) * 289.0;
}

float3 permute(float3 x)
{
	return mod289(((x*34.0)+1.0)*x);
}

float4 permute(float4 x)
{
	return mod289(((x*34.0)+1.0)*x);
}

float4 taylorInvSqrt(float4 r)
{
	return (float4)1.79284291400159 - r * 0.85373472095314;
}

float3 fade(float3 t) {
	return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise, periodic variant
float pnoise (float3 P, float3 rep)
{
	P *= rep;
	float3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
	float3 Pi1 = mod(Pi0 + (float3)1.0, rep); // Integer part + 1, mod period
	Pi0 = mod289(Pi0);
	Pi1 = mod289(Pi1);
	float3 Pf0 = frac(P); // fracional part for interpolation
	float3 Pf1 = Pf0 - (float3)1.0; // fracional part - 1.0
	float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
	float4 iy = float4(Pi0.y, Pi0.y, Pi1.y, Pi1.y);
	float4 iz0 = (float4)Pi0.z;
	float4 iz1 = (float4)Pi1.z;

	float4 ixy = permute(permute(ix) + iy);
	float4 ixy0 = permute(ixy + iz0);
	float4 ixy1 = permute(ixy + iz1);

	float4 gx0 = ixy0 / 7.0;
	float4 gy0 = frac(floor(gx0) / 7.0) - 0.5;
	gx0 = frac(gx0);
	float4 gz0 = (float4)0.5 - abs(gx0) - abs(gy0);
	float4 sz0 = step(gz0, (float4)0.0);
	gx0 -= sz0 * (step((float4)0.0, gx0) - 0.5);
	gy0 -= sz0 * (step((float4)0.0, gy0) - 0.5);

	float4 gx1 = ixy1 / 7.0;
	float4 gy1 = frac(floor(gx1) / 7.0) - 0.5;
	gx1 = frac(gx1);
	float4 gz1 = (float4)0.5 - abs(gx1) - abs(gy1);
	float4 sz1 = step(gz1, (float4)0.0);
	gx1 -= sz1 * (step((float4)0.0, gx1) - 0.5);
	gy1 -= sz1 * (step((float4)0.0, gy1) - 0.5);

	float3 g000 = float3(gx0.x,gy0.x,gz0.x);
	float3 g100 = float3(gx0.y,gy0.y,gz0.y);
	float3 g010 = float3(gx0.z,gy0.z,gz0.z);
	float3 g110 = float3(gx0.w,gy0.w,gz0.w);
	float3 g001 = float3(gx1.x,gy1.x,gz1.x);
	float3 g101 = float3(gx1.y,gy1.y,gz1.y);
	float3 g011 = float3(gx1.z,gy1.z,gz1.z);
	float3 g111 = float3(gx1.w,gy1.w,gz1.w);

	float4 norm0 = taylorInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
	g000 *= norm0.x;
	g010 *= norm0.y;
	g100 *= norm0.z;
	g110 *= norm0.w;
	float4 norm1 = taylorInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
	g001 *= norm1.x;
	g011 *= norm1.y;
	g101 *= norm1.z;
	g111 *= norm1.w;

	float n000 = dot(g000, Pf0);
	float n100 = dot(g100, float3(Pf1.x, Pf0.y, Pf0.z));
	float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
	float n110 = dot(g110, float3(Pf1.x, Pf1.y, Pf0.z));
	float n001 = dot(g001, float3(Pf0.x, Pf0.y, Pf1.z));
	float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
	float n011 = dot(g011, float3(Pf0.x, Pf1.y, Pf1.z));
	float n111 = dot(g111, Pf1);

	float3 fade_xyz = fade(Pf0);
	float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
	float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
	float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
	return 2.2 * n_xyz;
}
// --------------------------------------------------------------------------

// ------------------------------ WORLEY NOISE ------------------------------
//
// Worley noise implementation for WebGL shaders - https://github.com/Erkaman/glsl-worley
//

float3 dist (float3 x, float3 y, float3 z,  bool manhattanDistance)
{
	return manhattanDistance ?  abs(x) + abs(y) + abs(z) :  (x * x + y * y + z * z);
}

// Worley noise, periodic variant
float2 worley (float3 P, float jitter, bool manhattanDistance, float rep)
{
	P *= rep;

	float K = 0.142857142857; // 1/7
	float Ko = 0.428571428571; // 1/2-K/2
	float  K2 = 0.020408163265306; // 1/(7*7)
	float Kz = 0.166666666667; // 1/6
	float Kzo = 0.416666666667; // 1/2-1/6*2

	float3 Pi = mod(floor(P), 289.0);
 	float3 Pf = frac(P) - 0.5;

 	float3 oi = float3(-1.0, 0.0, 1.0);
 	float3 io = float3( 1.0, 0.0,-1.0);

	float3 Pfx = Pf.x + io;
	float3 Pfy = Pf.y + io;
	float3 Pfz = Pf.z + io;

	float3 p  = permute(mod(Pi.x + oi, rep));
	float3 p1 = permute(mod(p + Pi.y - 1.0, rep));
	float3 p2 = permute(mod(p + Pi.y, rep));
	float3 p3 = permute(mod(p + Pi.y + 1.0, rep));

	float3 p11 = permute(mod(p1 + Pi.z - 1.0, rep));
	float3 p12 = permute(mod(p1 + Pi.z, rep));
	float3 p13 = permute(mod(p1 + Pi.z + 1.0, rep));

	float3 p21 = permute(mod(p2 + Pi.z - 1.0, rep));
	float3 p22 = permute(mod(p2 + Pi.z, rep));
	float3 p23 = permute(mod(p2 + Pi.z + 1.0, rep));

	float3 p31 = permute(mod(p3 + Pi.z - 1.0, rep));
	float3 p32 = permute(mod(p3 + Pi.z, rep));
	float3 p33 = permute(mod(p3 + Pi.z + 1.0, rep));

	float3 ox11 = frac(p11*K) - Ko;
	float3 oy11 = mod(floor(p11*K), 7.0)*K - Ko;
	float3 oz11 = floor(p11*K2)*Kz - Kzo; // p11 < 289 guaranteed

	float3 ox12 = frac(p12*K) - Ko;
	float3 oy12 = mod(floor(p12*K), 7.0)*K - Ko;
	float3 oz12 = floor(p12*K2)*Kz - Kzo;

	float3 ox13 = frac(p13*K) - Ko;
	float3 oy13 = mod(floor(p13*K), 7.0)*K - Ko;
	float3 oz13 = floor(p13*K2)*Kz - Kzo;

	float3 ox21 = frac(p21*K) - Ko;
	float3 oy21 = mod(floor(p21*K), 7.0)*K - Ko;
	float3 oz21 = floor(p21*K2)*Kz - Kzo;

	float3 ox22 = frac(p22*K) - Ko;
	float3 oy22 = mod(floor(p22*K), 7.0)*K - Ko;
	float3 oz22 = floor(p22*K2)*Kz - Kzo;

	float3 ox23 = frac(p23*K) - Ko;
	float3 oy23 = mod(floor(p23*K), 7.0)*K - Ko;
	float3 oz23 = floor(p23*K2)*Kz - Kzo;

	float3 ox31 = frac(p31*K) - Ko;
	float3 oy31 = mod(floor(p31*K), 7.0)*K - Ko;
	float3 oz31 = floor(p31*K2)*Kz - Kzo;

	float3 ox32 = frac(p32*K) - Ko;
	float3 oy32 = mod(floor(p32*K), 7.0)*K - Ko;
	float3 oz32 = floor(p32*K2)*Kz - Kzo;

	float3 ox33 = frac(p33*K) - Ko;
	float3 oy33 = mod(floor(p33*K), 7.0)*K - Ko;
	float3 oz33 = floor(p33*K2)*Kz - Kzo;

	float3 dx11 = Pfx + jitter*ox11;
	float3 dy11 = Pfy.x + jitter*oy11;
	float3 dz11 = Pfz.x + jitter*oz11;

	float3 dx12 = Pfx + jitter*ox12;
	float3 dy12 = Pfy.x + jitter*oy12;
	float3 dz12 = Pfz.y + jitter*oz12;

	float3 dx13 = Pfx + jitter*ox13;
	float3 dy13 = Pfy.x + jitter*oy13;
	float3 dz13 = Pfz.z + jitter*oz13;

	float3 dx21 = Pfx + jitter*ox21;
	float3 dy21 = Pfy.y + jitter*oy21;
	float3 dz21 = Pfz.x + jitter*oz21;

	float3 dx22 = Pfx + jitter*ox22;
	float3 dy22 = Pfy.y + jitter*oy22;
	float3 dz22 = Pfz.y + jitter*oz22;

	float3 dx23 = Pfx + jitter*ox23;
	float3 dy23 = Pfy.y + jitter*oy23;
	float3 dz23 = Pfz.z + jitter*oz23;

	float3 dx31 = Pfx + jitter*ox31;
	float3 dy31 = Pfy.z + jitter*oy31;
	float3 dz31 = Pfz.x + jitter*oz31;

	float3 dx32 = Pfx + jitter*ox32;
	float3 dy32 = Pfy.z + jitter*oy32;
	float3 dz32 = Pfz.y + jitter*oz32;

	float3 dx33 = Pfx + jitter*ox33;
	float3 dy33 = Pfy.z + jitter*oy33;
	float3 dz33 = Pfz.z + jitter*oz33;

	float3 d11 = dist(dx11, dy11, dz11, manhattanDistance);
	float3 d12 = dist(dx12, dy12, dz12, manhattanDistance);
	float3 d13 = dist(dx13, dy13, dz13, manhattanDistance);
	float3 d21 = dist(dx21, dy21, dz21, manhattanDistance);
	float3 d22 = dist(dx22, dy22, dz22, manhattanDistance);
	float3 d23 = dist(dx23, dy23, dz23, manhattanDistance);
	float3 d31 = dist(dx31, dy31, dz31, manhattanDistance);
	float3 d32 = dist(dx32, dy32, dz32, manhattanDistance);
	float3 d33 = dist(dx33, dy33, dz33, manhattanDistance);

	float3 d1a = min(d11, d12);
	d12 = max(d11, d12);
	d11 = min(d1a, d13); // Smallest now not in d12 or d13
	d13 = max(d1a, d13);
	d12 = min(d12, d13); // 2nd smallest now not in d13
	float3 d2a = min(d21, d22);
	d22 = max(d21, d22);
	d21 = min(d2a, d23); // Smallest now not in d22 or d23
	d23 = max(d2a, d23);
	d22 = min(d22, d23); // 2nd smallest now not in d23
	float3 d3a = min(d31, d32);
	d32 = max(d31, d32);
	d31 = min(d3a, d33); // Smallest now not in d32 or d33
	d33 = max(d3a, d33);
	d32 = min(d32, d33); // 2nd smallest now not in d33
	float3 da = min(d11, d21);
	d21 = max(d11, d21);
	d11 = min(da, d31); // Smallest now in d11
	d31 = max(da, d31); // 2nd smallest now not in d31
	d11.xy = (d11.x < d11.y) ? d11.xy : d11.yx;
	d11.xz = (d11.x < d11.z) ? d11.xz : d11.zx; // d11.x now smallest
	d12 = min(d12, d21); // 2nd smallest now not in d21
	d12 = min(d12, d22); // nor in d22
	d12 = min(d12, d31); // nor in d31
	d12 = min(d12, d32); // nor in d32
	d11.yz = min(d11.yz,d12.xy); // nor in d12.yz
	d11.y = min(d11.y,d12.z); // Only two more to go
	d11.y = min(d11.y,d11.z); // Done! (Phew!)
	return sqrt(d11.xy); // F1, F2

}

// --------------------------------------------------------------------------

#endif // CLOUDNOISELIB_INCLUDED