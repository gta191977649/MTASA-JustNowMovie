// wet roads
// by ren712, ccw, Sam@ke

#define GENERATE_NORMALS   
#include "mta-helper.fx"


float Time : Time;
float TextureSize = 4096.0; // higher amount gets better result in bump results
float bumpFactor = 0.45;
float shiftXValue = 0.0;
float shiftYValue = 0.0;
float zoomXValue = 1;
float zoomYValue = 1;
float reflectionStrength = 0.5;
float diffuseFactor = 0.7;
float4 waterColor = float4(0.7, 0.6, 0.8, 1.0);

bool specularsEnabled = true;
float3 lightDirection = float3(1500, -500, 450);
float3 sunColor = float3(0.95, 0.85, 0.8);
float specularPower = 4;
float specularBrightness = 1;
float specularStrength = 2;
float fadeStart = 10;
float fadeEnd = 65;

int wetStage = 1;
float fadeValue = 0.5;

bool sFogEnable = true;
int fCullMode = 1;
float nLerpRef = 0.2;

texture screenSource;
texture puddleMask;
texture waterNormal;

//--------------------------------------------------------------------------------------
// Variables set by MTA
//--------------------------------------------------------------------------------------
float4 gFogColor < string renderState="FOGCOLOR"; >;
float gFogStart < string renderState="FOGSTART"; >;
float gFogEnd < string renderState="FOGEND"; >;
int gCapsMaxAnisotropy < string deviceCaps="MaxAnisotropy"; >;

sampler2D MainSampler = sampler_state{
    Texture = (gTexture0);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy;
    MinFilter = Anisotropic;
    AddressU = Mirror;
    AddressV = Mirror;
};


sampler2D ReflectionSampler = sampler_state{
    Texture = (screenSource);
    AddressU = Mirror;
    AddressV = Mirror;
    AddressW = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};


sampler2D PuddleMaskSampler = sampler_state{
    Texture = (puddleMask);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};


sampler2D WaterNormalSampler = sampler_state{
    Texture = (waterNormal);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};


// The Sobel filter extracts the first order derivates of the image,
// that is, the slope. The slope in X and Y directon allows us to
// given a heightmap evaluate the normal for each pixel. This is
// the same this as ATI's NormalMapGenerator application does,
// except this is in hardware.
//
// These are the filter kernels:
//
//  SobelX       SobelY
//  1  0 -1      1  2  1
//  2  0 -2      0  0  0
//  1  0 -1     -1 -2 -1

float3 calculateTextureNormals(float2 TexCoords, float4 color) {
   float off = 1.0 / TextureSize;

   // Take all neighbor samples
   float4 s00 = tex2D(MainSampler, TexCoords + float2(-off, -off));
   float4 s01 = tex2D(MainSampler, TexCoords + float2( 0,   -off));
   float4 s02 = tex2D(MainSampler, TexCoords + float2( off, -off));

   float4 s10 = tex2D(MainSampler, TexCoords + float2(-off,  0));
   float4 s12 = tex2D(MainSampler, TexCoords + float2( off,  0));

   float4 s20 = tex2D(MainSampler, TexCoords + float2(-off,  off));
   float4 s21 = tex2D(MainSampler, TexCoords + float2( 0,    off));
   float4 s22 = tex2D(MainSampler, TexCoords + float2( off,  off));

   // Slope in X direction
   float4 sobelX = s00 + 2 * s10 + s20 - s02 - 2 * s12 - s22;
   // Slope in Y direction
   float4 sobelY = s00 + 2 * s01 + s02 - s20 - 2 * s21 - s22;

   // Weight the slope in all channels, we use grayscale as height
   float sx = dot(sobelX, color);
   float sy = dot(sobelY, color);

   // Compose the normal
   float3 normal = normalize(float3(sx, sy, 1));

   // Pack [-1, 1] into [0, 1]
   return float3(normal * 0.5 + 0.5);
}


float4 calculateLuminance(float4 color) {
    float lum = (color.r + color.g + color.b) / 3;
    float adj = saturate(lum - 0.1);
    adj = adj / (1.01 - 0.3);
    color = color * adj;
    color += 0.17;
	color.rgb *= 1 + gCameraDirection.z;
	
	return color;
}


float4 getPuddleMask(float2 worldCoords) {
	float4 puddleMask1 = tex2D(PuddleMaskSampler, worldCoords * 2);
    float4 puddleMask2 = tex2D(PuddleMaskSampler, worldCoords / 128);
	
    puddleMask1 = 1 - ((1 - puddleMask1) * (1 - puddleMask2) * 2);
	
	return puddleMask1;
}


float4 getPuddleMaskNegative(float2 worldCoords) {
	float4 puddleMask1 = tex2D(PuddleMaskSampler, worldCoords * 2);
    float4 puddleMask2 = tex2D(PuddleMaskSampler, worldCoords / 128);
	
    puddleMask1 = (1 - puddleMask1) * (1 - puddleMask2) * 2;
	
	return puddleMask1;
}


float4 getPuddleMaskSmall(float2 worldCoords, float timerIN) {
	float timer = timerIN * 4;
	worldCoords.y -= timer;
	worldCoords.x += timer;
	float4 puddleMask1 = tex2D(PuddleMaskSampler, worldCoords / 3);
	worldCoords.y += timer;
	worldCoords.x -= timer;
    float4 puddleMask2 = tex2D(PuddleMaskSampler, worldCoords * 4);
	
    puddleMask1 = ((1 - puddleMask1) + (1 - puddleMask2)) / 4;
	
	return puddleMask1;
}


float3 getReflectionCoords(float3 coords, float factor) {
	float3 newCoords = float3((coords.xy / coords.z), 0) ;
	newCoords.xy += float2(shiftXValue * factor, shiftYValue * factor);
    newCoords.xy *= float2(zoomXValue, zoomYValue);
	
	return newCoords;
}


float3 getReflectionBumpCoords(float3 coords, float3 normals, float3 tangent, float3 binormal, float factor) {
	float3 newCoords = float3((coords.xy / coords.z), 0) ;
	newCoords += normalize(normals.x * tangent + normals.y * binormal);	
	newCoords.xy += float2(shiftXValue * factor, shiftYValue * factor);
    newCoords.xy *= float2(zoomXValue, zoomYValue);
	
	return newCoords;
}


float2 fixReflectionCoords(float2 coords) {
	if (gCameraDirection.z < 0.1) {
		coords.y = 1 - coords.y;
		coords.y -= 0.2;
		coords.y += gCameraDirection.z * 2;
	} else {
		coords.y -= gCameraDirection.z * 2;
		coords.y += 0.2;
	}
	
	return coords;
}


float2 getFakeLightDot(float3 normals) {
	float3 fakeLightDir = normalize(float3(1.0f, 1.0, 0.8f));   
    fakeLightDir.xy = gCameraDirection.xy;
	
	return dot(normals, fakeLightDir);
}


float3 addSpecularLight(float3 normal, float3 normalWorld, float3 lightDir, float3 worldPos, float specul, float intensity, float distance) {
    float3 h = normalize(normalize(gCameraPosition - worldPos) - lightDir);
    float specLighting = pow(saturate(dot(h, normal)), specul);

    float lightAwayDot = -dot(normalize(lightDir), normal);
	
    if (lightAwayDot < 0) specLighting = 0;
		
	return saturate(specLighting) * saturate(distance) * intensity * 0.15; 
}


struct VertexShaderinput {
    float4 Position : POSITION0;
    float4 Color : COLOR0;
    float2 TexCoords : TEXCOORD0;
};


struct VertexShaderOutput {
    float4 Position : POSITION0;
    float2 TexCoords : TEXCOORD0;
    float3 TexCoords_proj : TEXCOORD1;
    float4 Diffuse: TEXCOORD3;
    float DistFade: TEXCOORD4;
    float3 Normal : TEXCOORD2;
    float3 Binormal : TEXCOORD5;
    float3 Tangent : TEXCOORD6;
	float3 worldPosition : TEXCOORD7;
	float2 WorldCoords : TEXCOORD8;
};

//-----------------------------------------------------------------------------
//	VertexShader
//-----------------------------------------------------------------------------

VertexShaderOutput VertexShaderFunction(VertexShaderinput input) {
	VertexShaderOutput output;
   
    output.Position = mul(input.Position, gWorldViewProjection);
    output.TexCoords = input.TexCoords;
    output.worldPosition = mul(float4(input.Position.xyz,1), gWorld).xyz;
  
    float4 Po = float4(input.Position.xyz,1.0);
    float4 pPos = mul(Po, gWorldViewProjection); 

    output.TexCoords_proj.x = 0.5 * (pPos.w + pPos.x);
    output.TexCoords_proj.y = 0.5 * (pPos.w - pPos.y);
    output.TexCoords_proj.z = pPos.w;
	
	float3 fakeNormal = float3(0,0,1);
    float3 Tangent = fakeNormal;
    Tangent.xz = input.TexCoords.xy;
    float3 Binormal = normalize( cross(Tangent, fakeNormal));
    Tangent = normalize(cross(Binormal, fakeNormal));
	
	output.Normal = normalize(mul(fakeNormal, (float3x3)gWorld));
    output.Tangent = normalize(mul(Tangent, (float3x3)gWorld));
    output.Binormal = normalize(mul(-Binormal, (float3x3)gWorld));

    float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, output.worldPosition );
    output.DistFade = MTAUnlerp(fadeEnd, fadeStart, DistanceFromCamera);
	
    output.Diffuse = MTACalcGTABuildingDiffuse( input.Color );
	output.WorldCoords = output.worldPosition.xy / 150;

    return output;
}

//-----------------------------------------------------------------------------
//	PixelShader
//-----------------------------------------------------------------------------

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0 {
	
	float timer = Time / 2048;
	float4 puddleMask = getPuddleMask(input.WorldCoords);
	float4 puddleMaskNegative = getPuddleMaskNegative(input.WorldCoords);
	float4 puddleMaskSmall = getPuddleMaskSmall(input.WorldCoords, timer);
	
	// ***************************** DRY ROADS  *********************************** //
	float4 mainColor = tex2D(MainSampler, input.TexCoords) * input.Diffuse;
	
	// ********************* COLOR WET ROADS **********************//
	float3 bumpNormals = calculateTextureNormals(input.TexCoords, mainColor) * 2.0 - 1.0;
	bumpNormals = normalize(float3(bumpNormals.x * bumpFactor, bumpNormals.y * bumpFactor, bumpNormals.z)); 

	float fakeLightRoads = getFakeLightDot(bumpNormals); 
	
	float3 reflectionCoordsWetRoad = getReflectionBumpCoords(input.TexCoords_proj, bumpNormals, input.Tangent, input.Binormal, 1);
	float4 wetRoadColorBase = tex2D(ReflectionSampler, fixReflectionCoords(reflectionCoordsWetRoad)) * (reflectionStrength) * 0.5;
	
	wetRoadColorBase = calculateLuminance(wetRoadColorBase);
	
	float4 wetRoadAmbient = saturate((mainColor) / 1.2); 
	float4 wetRoadDiffuse = (input.Diffuse * wetRoadColorBase) * diffuseFactor * 0.6;

	float4 wetRoadColor = saturate(wetRoadAmbient * fakeLightRoads) + saturate(input.DistFade) * wetRoadDiffuse;  
	wetRoadColor.a = mainColor.a;
	// ********************* COLOR WET ROADS **********************//

	
	// ********************* COLOR PUDDLES **********************//
	float2 waterNormalCoords = input.WorldCoords;
	waterNormalCoords.y += timer * 1.7;
	waterNormalCoords.x -= timer / 0.6;
	float4 waterNormal1 = tex2D(WaterNormalSampler, waterNormalCoords * 16);
	waterNormalCoords.y -= timer / 0.6;
	waterNormalCoords.x += timer * 1.7;
	float4 waterNormal2 = tex2D(WaterNormalSampler, waterNormalCoords * 128);
	float4 waterNormalMap = (waterNormal1 + waterNormal2) / 2;
	float3 waterNormals = (waterNormalMap.xyz * 0.5f) - 0.25f;
	
	float fakeLightPuddles = getFakeLightDot(waterNormals); 
	
	float3 reflectionCoordsPuddles1 = getReflectionBumpCoords(input.TexCoords_proj, waterNormals, input.Tangent, input.Binormal, 4);
	float4 puddleColorBase1 = tex2D(ReflectionSampler, fixReflectionCoords(reflectionCoordsPuddles1)) * (reflectionStrength) * 1.2;
	puddleColorBase1 = calculateLuminance(puddleColorBase1);
	
	float3 refactUV = getReflectionCoords(input.TexCoords_proj, 2);
	refactUV.xy += waterNormals.xy / 8;

	float4 puddleColorBase2 = tex2D(ReflectionSampler, fixReflectionCoords(refactUV)) * (reflectionStrength) * 1.4;
	puddleColorBase2 = calculateLuminance(puddleColorBase2);

	float4 puddleColorBase = (float4(puddleColorBase1.rgb * puddleMaskSmall, puddleColorBase1.a) + float4(puddleColorBase2.rgb * (1 - puddleMaskSmall), puddleColorBase1.a)) / 2;
	//float4 puddleColorBase = puddleColorBase1;
	
	float2 reFractMainUV = input.TexCoords;
	reFractMainUV.xy += waterNormals.xy / 8;
	
	float4 reFractedMainColor = tex2D(MainSampler, reFractMainUV) * input.Diffuse;
	
	float4 puddleAmbient = saturate((reFractedMainColor) / 1.8); 
	float4 puddleDiffuse = (input.Diffuse * puddleColorBase) * diffuseFactor * 1.5;

	float4 puddleColor = saturate(puddleAmbient * fakeLightPuddles) + saturate(input.DistFade) * puddleDiffuse;
	puddleColor.a = reFractedMainColor.a;
	
	puddleColor.rgb += reFractedMainColor.rgb * 0.25;
	puddleColor /= 1.5;
	// ********************* COLOR PUDDLES **********************//
	
	
	// ********************* Speculars  **********************//
	float3 specLightingRoad = addSpecularLight(bumpNormals, input.Normal, lightDirection, input.worldPosition.xyz, specularPower, specularStrength, input.DistFade);
	float3 specLightingPuddles = addSpecularLight(waterNormals, input.Normal, lightDirection, input.worldPosition.xyz, specularPower, specularStrength, input.DistFade);
	// ********************* Speculars **********************//
	
	float4 finalColor = 0;
	float4 wetColorWithPuddles = wetRoadColor;
	
	if (wetStage == 0) {
		mainColor.rgb += (specLightingRoad / 2) * mainColor.r * mainColor.r;
		
		return mainColor;
	} else if (wetStage == 1) {
		wetRoadColor.rgb += (specLightingRoad * 1.5) * wetRoadColor.r * wetRoadColor.r;
		mainColor.rgb += (specLightingRoad / 2) * mainColor.r * mainColor.r;
		
		finalColor = (wetRoadColor * fadeValue) + (mainColor * (1 - fadeValue));
		
		return finalColor;
	} else if (wetStage == 2) {
		wetRoadColor.rgb += (specLightingRoad * 1.5) * wetRoadColor.r * wetRoadColor.r;
		
		puddleColor *= saturate(puddleMaskNegative);
		puddleColor.rgb += (specLightingPuddles * 1.5) * puddleColor.g * puddleColor.g;
		wetColorWithPuddles.rgb += (specLightingRoad * 1.5) * wetColorWithPuddles.r * wetColorWithPuddles.r;
		wetColorWithPuddles -= (mainColor * saturate(puddleMaskNegative)) / 1.5;
		wetColorWithPuddles *= saturate(puddleMask);
		wetColorWithPuddles += puddleColor;
		wetColorWithPuddles /= 2;
		
		finalColor = (wetColorWithPuddles * fadeValue) + (wetRoadColor * (1 - fadeValue));
		
		return finalColor;
	} else if (wetStage == 3) {
		float4 dryColorWithWetPlaces = wetRoadColor;
		float4 tempBaseColor = mainColor;
		
		dryColorWithWetPlaces *= saturate(puddleMaskNegative);
		dryColorWithWetPlaces.rgb += (specLightingRoad * 1.5) * dryColorWithWetPlaces.r * dryColorWithWetPlaces.r;
		tempBaseColor *= saturate(puddleMask);
		tempBaseColor.rgb += (specLightingRoad / 2) * tempBaseColor.r * tempBaseColor.r;
		dryColorWithWetPlaces += tempBaseColor;
		dryColorWithWetPlaces /= 2;
		
		puddleColor *= saturate(puddleMaskNegative);
		puddleColor.rgb += specLightingPuddles * puddleColor.r * puddleColor.r;
		wetColorWithPuddles.rgb += (specLightingRoad * 1.5) * wetColorWithPuddles.r * wetColorWithPuddles.r;
		wetColorWithPuddles -= (mainColor * saturate(puddleMaskNegative)) / 1.5;
		wetColorWithPuddles *= saturate(puddleMask);
		wetColorWithPuddles += puddleColor;
		wetColorWithPuddles /= 2;
		
		finalColor = (dryColorWithWetPlaces * fadeValue) + (wetColorWithPuddles * (1 - fadeValue));
		
		return finalColor;
	} else if (wetStage == 4) {
		float4 dryColorWithWetPlaces = wetRoadColor;
		float4 tempBaseColor = mainColor;
		
		dryColorWithWetPlaces *= saturate(puddleMaskNegative);
		dryColorWithWetPlaces.rgb += (specLightingRoad / 2) * dryColorWithWetPlaces.r * dryColorWithWetPlaces.r;
		tempBaseColor *= saturate(puddleMask);
		tempBaseColor.rgb += (specLightingRoad / 2) * tempBaseColor.r * tempBaseColor.r;
		dryColorWithWetPlaces += tempBaseColor;
		dryColorWithWetPlaces /= 2;
		
		mainColor.rgb += (specLightingRoad / 2) * mainColor.r * mainColor.r;
		
		finalColor = (mainColor * fadeValue) + (dryColorWithWetPlaces * (1 - fadeValue));
		
		return finalColor;
	}

	return finalColor;
}


technique wetRoadsWithPuddles {
	pass P0 {
		ZEnable = true;
		ZFunc = LessEqual;
		ZWriteEnable = true;
		CullMode = fCullMode;
		ShadeMode = Gouraud;
		AlphaTestEnable = true;
		AlphaRef = 1;
		AlphaFunc = GreaterEqual;
		Lighting = false;
		FogEnable = sFogEnable;
		FogStart = gFogStart * (1 + saturate((gFogStart / gFogEnd) * saturate(1 - nLerpRef)));
		FogEnd = gFogEnd * (1 + saturate((gFogStart / gFogEnd) * saturate(1 - nLerpRef)));
		FogColor = float4(saturate(gFogColor.rgb * 1.6), gFogColor.a);
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader = compile ps_3_0 PixelShaderFunction();
	}
}

technique fallback {
    pass P0 {
	
    }
}
