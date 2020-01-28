Shader "Unlit/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ScreenRender("Screen Texture", 2D) = "white" {}
		_OutlineRadius("OutlineRadius", int) = 5
		_OutlineColour("OutlineColour", Color) = (0, 0, 0, 1)
		_Depth("Depth", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest Off
			ZWrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float4 projPos : TEXCOORD1;
				float depth : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;

			uniform sampler2D _ScreenRender;
			uniform float4 _ScreenRender_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.projPos = ComputeScreenPos(o.vertex);
				o.depth = -mul(UNITY_MATRIX_MV, o.vertex).z *_ProjectionParams.w;
                return o;
            }

			float GetAlpha(v2f a_i, float2 a_offset)
			{
				fixed4 mainCol = tex2D(_MainTex, a_i.uv + (a_offset / _ScreenParams.xy)).a;
				fixed4 screenCol = tex2D(_ScreenRender, a_i.uv + (a_offset / _ScreenParams.xy)).a;
				return mainCol.a;
			}

			float LinearToDepth(float linearDepth)
			{
				return (1.0 - _ZBufferParams.w * linearDepth) / (linearDepth * _ZBufferParams.z);
			}

			int _OutlineRadius;
			float4 _OutlineColour;
			float _Depth;

            fixed4 frag (v2f i) : SV_Target
            {
				//_ProjectionParams
				//float screenDepth = DecodeFloatRG(tex2D(_CameraDepthTexture, i.projPos.xy / i.projPos.w).zw);
				//float diff = (screenDepth - i.depth);
				//float depth = 1 - smoothstep(0, _ProjectionParams.w, diff);
				//return fixed4(depth, depth, depth, 1);

				fixed4 mainCol = tex2D(_MainTex, i.uv);
				fixed4 screenCol = tex2D(_ScreenRender, i.uv);
				fixed4 col = mainCol;

				//if (mainCol.r == screenCol.r && mainCol.g == screenCol.g && mainCol.b == screenCol.b)
				//	return fixed4(0, 0, 0, 1);

				int radius = 2;
				
				//if (SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv) > depth)
				//	return fixed4(1, 0, 0, 1);

				if (col.a == 1)
					return fixed4(0, 0, 0, 0);

				col = fixed4(_OutlineColour.xyz, 0);

				for (int y = -radius; y <= radius; ++y)
				{
					for (int x = -radius; x <= radius; ++x)
					{
						if (x*x + y*y <= radius*radius)
						{
							if (GetAlpha(i, float2(x, y)) > 0)
							{
								col.a = 1;
								break;
							}
						}
					}
				}

                return col;
            }
            ENDCG
        }
    }
}
