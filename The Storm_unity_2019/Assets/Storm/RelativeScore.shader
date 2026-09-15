Shader "Custom/RelativeScore"
{

    Properties
    {
        _MainTex ("Digit Atlas", 2D) = "white" {}
        _Color   ("Color", Color) = (1,1,1,1)
        _Number  ("Number", float) = 0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        LOD 100

        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
               UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION; 
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Number;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float len = 4;
                int num = 0;
                if (_Number >= 1.0) { num = 9999; } else { num = _Number * 10000; }

                float slotWidth = 1.0 / (len + 0.2);
                float gapOffset = (1.0/len) - (1.0/(len+0.2));
                float gapWidth  = gapOffset * 4.0;

                float gapStart = slotWidth * 2.0;
                float gapEnd   = gapStart + gapWidth;

                if (i.uv.x > gapStart && i.uv.x < gapEnd)
                {
                    if (i.uv.y < 0.1)
                        return float4(1,1,1,1) * _Color;
                    return float4(0,0,0,0);
                }
                
                float adjustedX = i.uv.x;
                if (i.uv.x >= gapEnd)
                {
                    adjustedX -= gapWidth;
                }

                float slotIndex   = clamp(floor(adjustedX / slotWidth), 0.0, len - 1.0);
                float posFromRight = (len - 1.0) - slotIndex;
                float place = pow(10.0, posFromRight);
                float digit = floor(num / place);

                float localU = saturate(frac(adjustedX / slotWidth));
                float2 atlasUV = float2((digit + localU) * 0.1, i.uv.y);
                return tex2D(_MainTex, atlasUV) * _Color;
            }
            ENDCG
        }
    }
}