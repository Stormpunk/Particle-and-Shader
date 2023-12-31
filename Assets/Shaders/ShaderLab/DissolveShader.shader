Shader "Custom/dissolve"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0

        _DissolveTexture("Dissolve Texture", 2D) = "white" {}
        _Amount("Amount", Range(0,1)) = 0   
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200
            Cull Off
            //Zwrite Off

            //Blend One One

            CGPROGRAM


            // Physically based Standard lighting model, and enable shadows on all light types
            #pragma surface surf Standard addshadow 

            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 3.0

            sampler2D _MainTex;
            sampler2D _DissolveTexture;
            half _Amount; // half a float

            struct Input
            {
                float2 uv_MainTex;
            };

            half _Glossiness;
            half _Metallic;
            fixed4 _Color;

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)

            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                half dissolve_value = tex2D(_DissolveTexture, IN.uv_MainTex).r;

                clip(dissolve_value - _Amount);

                // Albedo comes from a texture tinted by color
                fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb * (1 - step(dissolve_value - _Amount, 0.05f));
                // Metallic and smoothness come from slider variables
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
                o.Emission = fixed3(1, 0, 0) * step(dissolve_value - _Amount, 0.05f);
                o.Alpha = c.a;// (0 > dissolve_value - _Amount);
            }
            ENDCG
        }
            Fallback "Transparent/VertexLit"
}