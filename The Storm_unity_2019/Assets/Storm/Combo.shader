Shader "Custom/Combo"
{

    Properties
    {
        _MainTex ("Digit Atlas", 2D) = "white" {}
        _Color   ("Color", Color) = (1,1,1,1)
        _Length  ("Length", Int) = 1
        _Number  ("Number", Int) = 0
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
            int _Length;
            int _Number;

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
                float len = max(1.0, (float)_Length);
                float num = abs((float)_Number);
                
                float numDigits = 1.0;
                if (num > 1.0) { numDigits = floor(log10(num)) + 1.0; }

                float slotWidth = 1.0 / len;
                float slotIndex = clamp(floor(i.uv.x / slotWidth), 0.0, len - 1.0);
                float localU = frac(i.uv.x / slotWidth);

                float posFromRight = (len - 1.0) - slotIndex;

                if (posFromRight >= numDigits)
                {
                    return fixed4(0, 0, 0, 0);
                }

                float place = pow(10.0, posFromRight);
                // the 1e-2 is for rounding error i was getting with numbers like 71, the division gave 70.9998 and it rounded down to 70
                float digit = floor(fmod(floor(num / place + 1e-2), 10.0) + 1e-2);

                float2 atlasUV = float2((digit + localU) * 0.1, i.uv.y);

                return tex2D(_MainTex, atlasUV) * _Color;
            }
            ENDCG
        }
    }
}