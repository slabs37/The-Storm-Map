// ai'd with manual fixes from https://www.shadertoy.com/view/XljGDy

Shader "Custom/SphereFog"
{
    Properties
    {
        [HDR] _FogColor ("Fog Color", Color) = (0.2, 0.5, 1.0, 1.0)
        _Density ("Density", Range(0, 5)) = 1.0
        _MaxDensity ("Max Density (Clamp)", Range(0, 1)) = 1.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        LOD 100

        Pass
        {
            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float4 scrPos   : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _FogColor;
            float _Density;
            float _MaxDensity;

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.scrPos = ComputeScreenPos(o.pos);
                return o;
            }
            
            float sphDensity(float3 roObj, float3 rdObjRaw, float radius, float dbuffer)
            {
                float objLen = length(rdObjRaw);
                if (objLen < 1e-8) return 0.0;

                float3 rd = rdObjRaw / objLen;   // unit direction, local space
                float3 rc = roObj / radius;       // camera pos in canonical unit-sphere space

                // find intersection with the canonical unit sphere
                float b = dot(rd, rc);
                float c = dot(rc, rc) - 1.0;
                float h = b * b - c;

                // not intersecting
                if (h < 0.0) return 0.0;

                h = sqrt(h);

                float t1 = -b - h;
                float t2 = -b + h;

                // convert world-space depth distance into the same parameterization
                float ndbuffer = dbuffer * objLen / radius;

                // not visible (behind camera or behind the depth buffer)
                if (t2 < 0.0 || t1 > ndbuffer) return 0.0;

                // clip integration segment from camera to depth buffer
                t1 = max(t1, 0.0);
                t2 = min(t2, ndbuffer);

                // analytical integration of an inverse-squared density
                float i1 = -(c * t1 + b * t1 * t1 + t1 * t1 * t1 / 3.0);
                float i2 = -(c * t2 + b * t2 * t2 + t2 * t2 * t2 / 3.0);
                return (i2 - i1) * (3.0 / 4.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                //float3 ro = _WorldSpaceCameraPos.xyz;
                float3 ro = mul(UNITY_MATRIX_I_V, float4(0.0, 0.0, 0.0, 1.0)).xyz;
                float3 rd = normalize(i.worldPos - ro);
                float3 roObj = mul(unity_WorldToObject, float4(ro, 1.0)).xyz;
                float3 rdObj = mul((float3x3)unity_WorldToObject, rd); 

                float2 uv = i.scrPos.xy / i.scrPos.w;
                float rawDepth = UNITY_SAMPLE_DEPTH(UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraDepthTexture, uv));
                float sceneEyeDepth = LinearEyeDepth(rawDepth);

                float3 camForward = normalize(mul((float3x3)unity_CameraToWorld, float3(0, 0, 1)));
                float cosAngle = max(dot(rd, camForward), 1e-4);
                float dbuffer = sceneEyeDepth / cosAngle;

                float dens = sphDensity(roObj, rdObj, 0.5, dbuffer);
                dens *= _Density;
                dens = min(dens, _MaxDensity);

                clip(dens - 0.0005);

                fixed4 col = _FogColor;
                col.a = dens;
                return col;
            }
            ENDCG
        }
    }

    FallBack Off
}