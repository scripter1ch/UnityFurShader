#pragma target 3.0

#include "Lighting.cginc"
#include "UnityCG.cginc"

struct v2f
{
    float4 pos: SV_POSITION;
    half4 uv: TEXCOORD0;
    float3 worldNormal: TEXCOORD1;
    float3 worldPos: TEXCOORD2;
};

fixed4 _Color;
fixed4 _Specular;
half _Shininess;

sampler2D _MainTex;
half4 _MainTex_ST;
sampler2D _FurTex;
half4 _FurTex_ST;

fixed _FurLength;

sampler2D _EmissionMap;
fixed4 _EmissionColor;

float _Saturate;

v2f vert_surface(appdata_base v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    return o;
}

v2f vert_base(appdata_base v)
{
    v2f o;
    float3 P = v.vertex.xyz + v.normal * _FurLength * FURSTEP;
    o.pos = UnityObjectToClipPos(float4(P, 1.0));
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _FurTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    return o;
}

fixed4 frag_surface(v2f i): SV_Target
{
    
    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 worldHalf = normalize(worldView + worldLight);
    
    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
	fixed3 diffuse = _LightColor0.rgb * albedo;
    fixed3 specular = _LightColor0.rgb * _Specular.rgb;

    fixed3 color = ambient + diffuse + specular;
	fixed4 output = fixed4(color, 1.0);

	half4 emission = tex2D(_EmissionMap, i.uv) * _EmissionColor;
	output.rgb += emission.rgb;

    return output;
}

fixed4 frag_base(v2f i): SV_Target
{
    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 worldHalf = normalize(worldView + worldLight);

    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo;
    fixed3 specular = _LightColor0.rgb * _Specular.rgb;

    fixed3 color = ambient + diffuse + specular;
    fixed alpha = tex2D(_FurTex, i.uv.zw).rgb;
    
	fixed4 output = fixed4(color, alpha);

	half4 emission = tex2D(_EmissionMap, i.uv) * _EmissionColor;
	output.rgb += emission.rgb;

    return output;
}

fixed4 frag_surface_without_saturate(v2f i) : SV_Target
{

	fixed3 worldNormal = normalize(i.worldNormal);
	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
	fixed3 worldHalf = normalize(worldView + worldLight);

	fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
	fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
	fixed3 specular = _LightColor0.rgb * _Specular.rgb;

	fixed3 color = ambient + diffuse + specular;
	fixed4 output = fixed4(color, 1.0);

	half4 emission = tex2D(_EmissionMap, i.uv) * _EmissionColor;
	output.rgb += emission.rgb;

	return output;
}

fixed4 frag_base_without_saturate(v2f i) : SV_Target
{
	fixed3 worldNormal = normalize(i.worldNormal);
	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
	fixed3 worldHalf = normalize(worldView + worldLight);

	fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
	fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
	fixed3 specular = _LightColor0.rgb * _Specular.rgb;

	fixed3 color = ambient + diffuse + specular;
	fixed alpha = tex2D(_FurTex, i.uv.zw).rgb;

	fixed4 output = fixed4(color, alpha);

	half4 emission = tex2D(_EmissionMap, i.uv) * _EmissionColor;
	output.rgb += emission.rgb;

	return output;
}