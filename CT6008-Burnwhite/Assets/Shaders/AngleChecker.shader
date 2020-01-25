Shader "Unlit/AngleChecker"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_DepthThreshold("Depth Threshold", range(0, 0.25)) = 0.00006
		_AngleThreshold("Angle Threshold", range(0, 0.01)) = 0.0013
		_AngleColour("Angle Colour", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			float _DepthThreshold;
			float _AngleThreshold;
			float4 _AngleColour;

			float CheckAngles(v2f a_i, float2 a_uvOffset1, float2 a_uvOffset2)
			{
				float depth0 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, a_i.uv) * _ZBufferParams.y;
				float depth1 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, a_i.uv + (a_uvOffset1 / _ScreenParams.xy)) * _ZBufferParams.y;
				float depth2 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, a_i.uv + (a_uvOffset2 / _ScreenParams.xy)) * _ZBufferParams.y;

				float angle1 = acos(dot(float2(depth0, 0), float2(depth1, 1)) / 180);
				float angle2 = acos(dot(float2(depth0, 0), float2(depth2, 1)) / 180);
				
				float angle = abs(angle1 - angle2);
				
				return step(_AngleThreshold, angle);
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv) * _ZBufferParams.x;

				// Horizontal
				//float depthLeft = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + (float2(-1, 0) / _ScreenParams.xy)) * _ZBufferParams.x;
				//float depthRight = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + (float2(1, 0) / _ScreenParams.xy)) * _ZBufferParams.x;

				//if (abs(depth - ((depthLeft + depthRight) * 0.5)) > _DepthThreshold)
				//	return _AngleColour;

				// Vertical
				//float depthTop = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + (float2(0,  1) / _ScreenParams.xy)) * _ZBufferParams.x;
				//float depthBtm = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + (float2(0, -1) / _ScreenParams.xy)) * _ZBufferParams.x;

				//if (abs(depth - ((depthTop + depthBtm) * 0.5)) > _DepthThreshold)
				//	return _AngleColour;

				// Diagonals
				//float depthTopRight = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + (float2(1, 1) / _ScreenParams.xy)) * _ZBufferParams.x;
				//float depthTopLeft = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + (float2(-1, 1) / _ScreenParams.xy)) * _ZBufferParams.x;
				//float depthBtmRight = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + (float2(1, -1) / _ScreenParams.xy)) * _ZBufferParams.x;
				//float depthBtmLeft = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + (float2(-1, -1) / _ScreenParams.xy)) * _ZBufferParams.x;

				//if (abs(depth - ((depthTopRight + depthBtmLeft) * 0.5)) > _DepthThreshold)
				//	return _AngleColour;
				//if (abs(depth - ((depthTopLeft + depthBtmRight) * 0.5)) > _DepthThreshold)
				//	return _AngleColour;

				float lerpAmount = 0;

				lerpAmount += CheckAngles(i, float2(-1, 1), float2(1, -1));
				lerpAmount += CheckAngles(i, float2(0, 1), float2(0, -1));
				lerpAmount += CheckAngles(i, float2(1, 1), float2(-1, -1));
				lerpAmount += CheckAngles(i, float2(-1, 0), float2(1, 0));

				lerpAmount = sign(lerpAmount);

                fixed4 col = lerp(tex2D(_MainTex, i.uv), _AngleColour, lerpAmount);
                return col;
            }
            ENDCG
        }
    }
}
