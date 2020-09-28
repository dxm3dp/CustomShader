# 纹理动画

纹理动画效果往往都是把时间因子添加到一些变量的计算中 , 以便在时间变化时画面也随之变化 .

Unity 内置的时间变量 , 以秒为单位 , 如下所示 :

- _Time , float4 , Time since level load , (t / 20 , t , t * 2 , t * 3) , use to animate things inside the shaders .
- _SinTime , float4 , Sine of time , (t / 8 , t / 4 , t / 2 , t) .
- _CosTime , float4 , Cosine of time , (t / 8 , t / 4 , t / 2 , t) .
- unity_DeltaTime , float4 , Delta time , (dt , 1 / dt , smoothDt , 1 / smoothDt ) .

## 序列帧动画 ( Sequence Frame )

实现序列帧动画 , 我们需要在每个时刻计算该时刻下应该播放的关键帧图像的位置 , 并对该关键帧进行纹理采样 .

```cpp
Properties
{
    _Color("Color Tint", Color) = (1, 1, 1, 1)
    _MainTex("Image Sequence", 2D) = "white" {}
    _HorizontalAmount("Horizontal Amount", float) = 4
    _VerticalAmount("Vertical Amount", float) = 4
    _Speed("Speed", Range(1, 100)) = 30
}
SubShader
{
    Tags { "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent" }
    Pass
    {
        Tags {"LightMode"="ForwardBase"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            //UNITY_TRANSFER_FOG(o,o.vertex);
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            // 计算时间因子
            float time = floor(_Time.y * _Speed);
            // 计算当前关键帧图像的行索引
            float row = floor(time / _HorizontalAmount);
            // 计算当前关键帧图像的列索引
            float column = time - row * _VerticalAmount;
            // 计算一个关键帧图像的uv坐标范围
            half2 uv = float2(i.uv.x / _HorizontalAmount, 
                i.uv.y / _VerticalAmount);
            // 计算当前关键帧图像uv坐标的x分量
            uv.x += column/_HorizontalAmount;
            // 计算当前关键帧图像uv坐标的y分量
            uv.y -= row/_VerticalAmount;
            // 对序列帧纹理进行采样
            fixed4 c = tex2D(_MainTex, uv);
            c.rgb *= _Color;

            return c;
        }
```
