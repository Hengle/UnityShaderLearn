﻿Shader "Unity Shader Book/Chapter 7/Ramp Texture"
{
    Properties
    {
        _Color ("Tint Color", Color) = (1, 1, 1, 1)
        _RampTex ("Ramp Texture", 2D) = "white" { }
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 200)) = 20
    }
    
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            
            fixed4 _Color;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            
            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldPosition: TEXCOORD0;
                float3 worldNormal: NORMAL;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            
            fixed4 frag(v2f i): SV_TARGET
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPosition));
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPosition));
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                fixed halfLambert = dot(worldNormal, worldLight) * 0.5 + 0.5;
                fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * diffuseColor;
                
                fixed3 halfDir = normalize(worldLight + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                
                fixed3 color = ambient + diffuse + specular;
                
                return fixed4(color, 1);
            }
            
            ENDCG
            
        }
    }
    
    Fallback "Specular"
}
