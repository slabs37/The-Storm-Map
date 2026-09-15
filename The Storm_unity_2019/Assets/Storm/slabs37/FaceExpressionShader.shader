Shader "Custom/FaceExpressionShader"
{
    Properties
    {
        [Header(Sliders)]
        _EyeIndex ("Eye Index", Range(0,7)) = 0
        _MouthIndex ("Mouth Index", Range(0,7)) = 0
        _BrowIndex ("Brow Index", Range(0,8)) = 0

        [Header(Base)]
        _NoFace ("No Face (Base)", 2D) = "white" {}
        _Nose ("Nose", 2D) = "white" {}
        _Freckles ("Freckles", 2D) = "white" {}

        [Header(Brow)]
        _BrowTex0 ("Brow Texture 0", 2D) = "white" {}
        _BrowTex1 ("Brow Texture 1", 2D) = "white" {}
        _BrowTex2 ("Brow Texture 2", 2D) = "white" {}
        _BrowTex3 ("Brow Texture 3", 2D) = "white" {}
        _BrowTex4 ("Brow Texture 4", 2D) = "white" {}
        _BrowTex5 ("Brow Texture 5", 2D) = "white" {}
        _BrowTex6 ("Brow Texture 6", 2D) = "white" {}
        _BrowTex7 ("Brow Texture 7", 2D) = "white" {}

        [Header(Eyes)]
        _EyeTex0 ("Eye Texture 0", 2D) = "white" {}
        _EyeTex1 ("Eye Texture 1", 2D) = "white" {}
        _EyeTex2 ("Eye Texture 2", 2D) = "white" {}
        _EyeTex3 ("Eye Texture 3", 2D) = "white" {}
        _EyeTex4 ("Eye Texture 4", 2D) = "white" {}
        _EyeTex5 ("Eye Texture 5", 2D) = "white" {}
        _EyeTex6 ("Eye Texture 6", 2D) = "white" {}
        _EyeTex7 ("Eye Texture 7", 2D) = "white" {}

        [Header(Mouth)]
        _MouthTex0 ("Mouth Texture 0", 2D) = "white" {}
        _MouthTex1 ("Mouth Texture 1", 2D) = "white" {}
        _MouthTex2 ("Mouth Texture 2", 2D) = "white" {}
        _MouthTex3 ("Mouth Texture 3", 2D) = "white" {}
        _MouthTex4 ("Mouth Texture 4", 2D) = "white" {}
        _MouthTex5 ("Mouth Texture 5", 2D) = "white" {}
        _MouthTex6 ("Mouth Texture 6", 2D) = "white" {}
        _MouthTex7 ("Mouth Texture 7", 2D) = "white" {}

        [Header(Lighting)]
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Emission ("Emission", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        ColorMask RGB
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        // Only _NoFace owns a real sampler. Every other texture reuses it via
        // UNITY_SAMPLE_TEX2D_SAMPLER below, so the whole shader only consumes
        // ONE sampler register instead of one per texture (avoids the
        // "maximum sampler register index exceeded" error with this many textures).
        UNITY_DECLARE_TEX2D(_NoFace);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_Nose);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_Freckles);

        UNITY_DECLARE_TEX2D_NOSAMPLER(_BrowTex0);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_BrowTex1);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_BrowTex2);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_BrowTex3);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_BrowTex4);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_BrowTex5);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_BrowTex6);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_BrowTex7);
        float _BrowIndex;

        UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeTex0);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeTex1);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeTex2);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeTex3);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeTex4);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeTex5);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeTex6);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeTex7);
        float _EyeIndex;

        UNITY_DECLARE_TEX2D_NOSAMPLER(_MouthTex0);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_MouthTex1);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_MouthTex2);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_MouthTex3);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_MouthTex4);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_MouthTex5);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_MouthTex6);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_MouthTex7);
        float _MouthIndex;

        half _Glossiness;
        half _Metallic;
        half _Emission;

        struct Input
        {
            float2 uv_NoFace;
               UNITY_VERTEX_INPUT_INSTANCE_ID
               UNITY_VERTEX_OUTPUT_STEREO
        };

        fixed4 GetEyeTex(float2 uv, int idx)
        {
            if (idx == 0) return UNITY_SAMPLE_TEX2D_SAMPLER(_EyeTex0, _NoFace, uv);
            if (idx == 1) return UNITY_SAMPLE_TEX2D_SAMPLER(_EyeTex1, _NoFace, uv);
            if (idx == 2) return UNITY_SAMPLE_TEX2D_SAMPLER(_EyeTex2, _NoFace, uv);
            if (idx == 3) return UNITY_SAMPLE_TEX2D_SAMPLER(_EyeTex3, _NoFace, uv);
            if (idx == 4) return UNITY_SAMPLE_TEX2D_SAMPLER(_EyeTex4, _NoFace, uv);
            if (idx == 5) return UNITY_SAMPLE_TEX2D_SAMPLER(_EyeTex5, _NoFace, uv);
            if (idx == 6) return UNITY_SAMPLE_TEX2D_SAMPLER(_EyeTex6, _NoFace, uv);
            return UNITY_SAMPLE_TEX2D_SAMPLER(_EyeTex7, _NoFace, uv);
        }

        fixed4 GetMouthTex(float2 uv, int idx)
        {
            if (idx == 0) return UNITY_SAMPLE_TEX2D_SAMPLER(_MouthTex0, _NoFace, uv);
            if (idx == 1) return UNITY_SAMPLE_TEX2D_SAMPLER(_MouthTex1, _NoFace, uv);
            if (idx == 2) return UNITY_SAMPLE_TEX2D_SAMPLER(_MouthTex2, _NoFace, uv);
            if (idx == 3) return UNITY_SAMPLE_TEX2D_SAMPLER(_MouthTex3, _NoFace, uv);
            if (idx == 4) return UNITY_SAMPLE_TEX2D_SAMPLER(_MouthTex4, _NoFace, uv);
            if (idx == 5) return UNITY_SAMPLE_TEX2D_SAMPLER(_MouthTex5, _NoFace, uv);
            if (idx == 6) return UNITY_SAMPLE_TEX2D_SAMPLER(_MouthTex6, _NoFace, uv);
            return UNITY_SAMPLE_TEX2D_SAMPLER(_MouthTex7, _NoFace, uv);
        }

        // idx here is 1-8 (0 = no brow, handled by caller)
        fixed4 GetBrowTex(float2 uv, int idx)
        {
            if (idx == 1) return UNITY_SAMPLE_TEX2D_SAMPLER(_BrowTex0, _NoFace, uv);
            if (idx == 2) return UNITY_SAMPLE_TEX2D_SAMPLER(_BrowTex1, _NoFace, uv);
            if (idx == 3) return UNITY_SAMPLE_TEX2D_SAMPLER(_BrowTex2, _NoFace, uv);
            if (idx == 4) return UNITY_SAMPLE_TEX2D_SAMPLER(_BrowTex3, _NoFace, uv);
            if (idx == 5) return UNITY_SAMPLE_TEX2D_SAMPLER(_BrowTex4, _NoFace, uv);
            if (idx == 6) return UNITY_SAMPLE_TEX2D_SAMPLER(_BrowTex5, _NoFace, uv);
            if (idx == 7) return UNITY_SAMPLE_TEX2D_SAMPLER(_BrowTex6, _NoFace, uv);
            return UNITY_SAMPLE_TEX2D_SAMPLER(_BrowTex7, _NoFace, uv);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            
               UNITY_SETUP_INSTANCE_ID(IN);
               UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
            float2 uv = IN.uv_NoFace;

            // Base layer
            fixed4 baseCol = UNITY_SAMPLE_TEX2D(_NoFace, uv);
            fixed4 col = baseCol;

            // Freckles Nose overlay
            fixed4 freckles = UNITY_SAMPLE_TEX2D_SAMPLER(_Freckles, _NoFace, uv);
            col.rgb = lerp(col.rgb, freckles.rgb, freckles.a);
            fixed4 nose = UNITY_SAMPLE_TEX2D_SAMPLER(_Nose, _NoFace, uv);
            col.rgb = lerp(col.rgb, nose.rgb, nose.a);

            // Eyes overlay
            int eyeIdx = (int)round(_EyeIndex);
            fixed4 eye = GetEyeTex(uv, eyeIdx);
            col.rgb = lerp(col.rgb, eye.rgb, eye.a);

            // Mouth overlay
            int mouthIdx = (int)round(_MouthIndex);
            fixed4 mouth = GetMouthTex(uv, mouthIdx);
            col.rgb = lerp(col.rgb, mouth.rgb, mouth.a);

            // Brow overlay (0 = none)
            int browIdx = (int)round(_BrowIndex);
            if (browIdx > 0)
            {
                fixed4 brow = GetBrowTex(uv, browIdx);
                col.rgb = lerp(col.rgb, brow.rgb, brow.a);
            }

            o.Albedo = col.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Emission = _Emission * col.rgb;
            // FOR BEATSABERRRR 0 ALPHA
            o.Alpha = 0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
