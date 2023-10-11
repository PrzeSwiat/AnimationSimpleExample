#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

#define MAX_BONES 180

sampler textureSampler = sampler_state
{
    Texture = (Texture);
    MinFilter = Linear;
    MagFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};

float4x4 World; // The view transformation 
float4x4 View; // The projection transformation  float4x4
float4x4 Projection; // The transpose of the inverse of the world
float3x3 WorldInverseTranspose;

float4 DiffuseColor = float4(1, 1, 1, 1);

matrix Bones[MAX_BONES];


struct VS_In
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
    float3 Normal : NORMAL0;
    float2 TexCoord : TEXCOORD0;
    uint4 Indices : BLENDINDICES0;
    float4 Weights : BLENDWEIGHT0;
};

struct VS_Out
{
	float4 Position : SV_POSITION;
    float3 Normal : NORMAL0;
    float2 TexCoord : TEXCOORD0;
};

void Skin(inout VS_In vin)
{
    float4x3 skinning = 0;
    [unroll]
    for (int i = 0; i < 4;i++)
    {
        skinning += Bones[vin.Indices[i]] * vin.Weights[i];
    }
    vin.Position.xyz = mul(vin.Position, skinning);
    vin.Normal = mul(vin.Normal, (float3x3)skinning);

}

VS_Out VertexShader_Skin(VS_In vin)
{
    VS_Out vout;
    Skin(vin);
	
    float3 wpos = mul(vin.Position, World);
    vout.Normal = normalize(mul(vin.Normal, WorldInverseTranspose));
    vout.Position = mul(mul(mul(vin.Position, World),View), Projection);
    vout.TexCoord = vin.TexCoord;
    
    
    return vout;
}

float4 PixelShader_Skin(VS_Out pin) : COLOR0
{
    float4 color = tex2D(textureSampler, pin.TexCoord) * DiffuseColor;
    color.a = 1;
    
    return color;

}

#define TECHNIQOUE(name, vsname, psname) technique name {pass {VertexShader = compile VS_SHADERMODEL vsname(); PixelShader = compile PS_SHADERMODEL psname();}}

TECHNIQOUE(skin_effect, VertexShader_Skin, PixelShader_Skin);