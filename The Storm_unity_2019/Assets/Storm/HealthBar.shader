Shader "Custom/HealthBar" {

Properties {
	_Color ("Color", Color) = (0.2,0.2,0.2,0.2)
	_MainTex ("Main Tex (RGBA)", 2D) = "white" {}
	_Health ("Health", Range(0.0,1.0)) = 0.0
}
 
SubShader {
    Tags  {"RenderType"="Opaque"}
	Blend SrcAlpha OneMinusSrcAlpha
	Pass {
	 
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"
uniform sampler2D _MainTex;
uniform float4 _Color;
uniform float _Health;
 
struct v2f {
	float4 pos : POSITION;
	float2 uv : TEXCOORD0;
	float light : _LightColor;
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};

v2f vert (appdata_base v)
{
	v2f o;
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_INITIALIZE_OUTPUT(v2f, o);
	UNITY_TRANSFER_INSTANCE_ID(v, o);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	o.pos = UnityObjectToClipPos (v.vertex);
	o.uv = TRANSFORM_UV(0);
	 
	return o;
}
 
float4 frag( v2f i ) : SV_TARGET
{
	UNITY_SETUP_INSTANCE_ID(i);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
	float4 tex = tex2D( _MainTex, i.uv);
	tex *= i.uv.x < _Health;
	return float4(tex*_Color*_LightColor0);
}
 
ENDCG
 
	}
}
 
}