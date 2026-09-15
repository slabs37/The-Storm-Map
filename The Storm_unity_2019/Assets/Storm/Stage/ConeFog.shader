// ai'd intensely from https://www.shadertoy.com/view/XljGDy

Shader "Custom/ConeFog"
{
    Properties
    {
        [HDR] _FogColor ("Fog Color", Color) = (0.2, 0.5, 1.0, 1.0)
        _Density ("Density", Range(0, 5)) = 1.0
        _MaxDensity ("Max Density (Clamp)", Range(0, 1)) = 1.0
        _ConeHeight ("Cone Height (local space / light Range)", Float) = 1.0
        _ConeRadius ("Cone Base Radius (local space / Range * tan(SpotAngle/2))", Float) = 0.3
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
            float _ConeHeight;
            float _ConeRadius;

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

            bool solveQuadratic(float a, float b, float c, out float r1, out float r2)
            {
                float disc = b * b - 4.0 * a * c;
                if (disc < 0.0)
                {
                    r1 = 0.0; r2 = 0.0;
                    return false;
                }
                float s = sqrt(disc);
                float q = (b >= 0.0) ? -0.5 * (b + s) : -0.5 * (b - s);
                float x1 = (abs(a) > 1e-9) ? q / a : 1e9;
                float x2 = (abs(q) > 1e-9) ? c / q : 1e9;
                r1 = min(x1, x2);
                r2 = max(x1, x2);
                return true;
            }

            
            float coneDensity(float3 roObj, float3 rdObjRaw, float height, float baseRadius, float dbuffer)
            {
                float objLen = length(rdObjRaw);
                if (objLen < 1e-8) return 0.0;

                float3 rd = rdObjRaw / objLen;
                float3 ro = roObj;
                height = max(height, 1e-4);
                baseRadius = max(baseRadius, 1e-4);
                float k2 = (baseRadius * baseRadius) / (height * height);

                float perp0 = dot(ro, ro) - ro.z * ro.z;
                float perp1 = 2.0 * (dot(ro, rd) - ro.z * rd.z);
                float perp2 = 1.0 - rd.z * rd.z;

                float la = perp2 - k2 * rd.z * rd.z;
                float lb = perp1 - 2.0 * k2 * ro.z * rd.z;
                float lc = perp0 - k2 * ro.z * ro.z;

                float ndbuffer = dbuffer * objLen;
                if (ndbuffer <= 0.0) return 0.0;

                float pts[6];
                pts[0] = 0.0;
                pts[1] = ndbuffer;

                float r1, r2;
                if (solveQuadratic(la, lb, lc, r1, r2))
                {
                    pts[2] = r1;
                    pts[3] = r2;
                }
                else
                {
                    pts[2] = 0.0;
                    pts[3] = 0.0;
                }

                if (abs(rd.z) > 1e-6)
                {
                    pts[4] = -ro.z / rd.z;
                    pts[5] = (height - ro.z) / rd.z;
                }
                else
                {
                    pts[4] = 0.0;
                    pts[5] = 0.0;
                }

                [unroll]
                for (int ci = 0; ci < 6; ci++) pts[ci] = clamp(pts[ci], 0.0, ndbuffer);

                [unroll]
                for (int i = 0; i < 5; i++)
                {
                    [unroll]
                    for (int j = 0; j < 5 - i; j++)
                    {
                        if (pts[j] > pts[j + 1])
                        {
                            float tmp = pts[j];
                            pts[j] = pts[j + 1];
                            pts[j + 1] = tmp;
                        }
                    }
                }

                float invR2 = 1.0 / (baseRadius * baseRadius);
                float d0 = 1.0 - perp0 * invR2;
                float d1 = -perp1 * invR2;
                float d2 = -perp2 * invR2;

                float total = 0.0;
                [unroll]
                for (int g = 0; g < 5; g++)
                {
                    float ta = pts[g];
                    float tb = pts[g + 1];
                    if (tb - ta < 1e-6) continue;

                    float mid = 0.5 * (ta + tb);
                    float zMid = ro.z + mid * rd.z;
                    float perpSqAtMid = perp0 + perp1 * mid + perp2 * mid * mid;
                    bool inside = (perpSqAtMid <= k2 * zMid * zMid) && (zMid >= 0.0) && (zMid <= height);

                    if (inside)
                    {
                        float Ia = d0 * ta + d1 * ta * ta * 0.5 + d2 * ta * ta * ta / 3.0;
                        float Ib = d0 * tb + d1 * tb * tb * 0.5 + d2 * tb * tb * tb / 3.0;
                        total += (Ib - Ia);
                    }
                }

                return max(total, 0.0);
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

                float dens = coneDensity(roObj, rdObj, _ConeHeight, _ConeRadius, dbuffer);
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
