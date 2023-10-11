#if OPENGL
#define SV_POSITION POSITION
#define VS_SHADERMODEL vs_3_0
#define PS_SHADERMODEL ps_3_0
#else
#define VS_SHADERMODEL vs_4_0_level_9_1
#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

#define MaxBones 60
float4x3 Bones[MaxBones];
float4x4 World; 
float4x4 View;
float4x4 Projection; 
float4x4 transformation; 
float4x4 WorldInverseTranspose;

float3 DiffuseLightDirection = float3(0, 0.5, 0.5);
float4 DiffuseColor = float4(1, 1, 1, 1);
float DiffuseIntensity = 5.7;

float4 LineColor = float4(0, 0, 0, 1);
float4 LineThickness = 0.12;

texture Texture;
sampler2D textureSampler = sampler_state
{
    Texture = (Texture);
    MinFilter = Linear;
    MagFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};


struct AppToVertex
{
    float4 Position : POSITION0;
    float3 Normal : NORMAL0;
    float2 TexCoord : TEXCOORD0;
    int4 Indices : BLENDINDICES0;
    float4 Weights : BLENDWEIGHT0;
};

struct VertexToPixel
{
    float4 Position : POSITION0;
    float2 TextureCoordinate : TEXCOORD0;
    float3 Normal : TEXCOORD1;
};

void Skin(inout AppToVertex vin, uniform int boneCount)
{
    float4x3 skinning = 0;

    [unroll] 
    for (int i = 0; i < boneCount; i++)
    {
        skinning += Bones[vin.Indices[i]] * vin.Weights[i];
    }

    vin.Position.xyz = mul(vin.Position, skinning);
    vin.Normal = mul(vin.Normal, (float3x3) skinning);
}

VertexToPixel CelVertexShader(AppToVertex input)
{
    VertexToPixel output;
    Skin(input, 4);
 
    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);
    
    float4 norm = normalize(mul(input.Normal, (float3x4) WorldInverseTranspose));
    output.Normal = norm.xyz;
    
    output.TextureCoordinate = input.TexCoord;

    return output;
}

float4 CelPixelShader(VertexToPixel input) : COLOR0
{
    float intensity = dot(normalize(DiffuseLightDirection), input.Normal);
    if (intensity < 0) 
        intensity = 0;
    
    float4 color = tex2D(textureSampler, input.TextureCoordinate) * DiffuseColor * DiffuseIntensity;
    clip(color.a < 0.75f ? -1 : 1);
    
    if (intensity > 0.95) 
        color = float4(1.0, 1, 1, 1.0) * color;
    else if (intensity > 0.5) 
        color = float4(0.7, 0.7, 0.7, 1.0) * color;
    else if (intensity > 0.05) 
        color = float4(0.35, 0.35, 0.35, 1.0) * color;
    else
        color = float4(0.1, 0.1, 0.1, 1.0) * color;

    return color;
}

VertexToPixel OutlineVertexShader(AppToVertex input)
{
    VertexToPixel output = (VertexToPixel) 0;
    Skin(input, 4);
    
    float4 original = mul(mul(mul(input.Position, World), View), Projection);
    
    float4 normal = mul(mul(mul(input.Normal, (float3x4) World), View), Projection);
    
    output.Position = original + (mul(LineThickness, normal));

    return output;
}

float4 OutlinePixelShader(VertexToPixel input) : COLOR0
{
    return LineColor;
}

technique Toon
{
    pass Pass1
    {
        VertexShader = compile VS_SHADERMODEL OutlineVertexShader();
        PixelShader = compile PS_SHADERMODEL OutlinePixelShader();
        CullMode = CW;
    }

    pass Pass2
    {
        VertexShader = compile VS_SHADERMODEL CelVertexShader();
        PixelShader = compile PS_SHADERMODEL CelPixelShader();
        CullMode = CCW;
    }
}