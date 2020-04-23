# Unity 的渲染路径

在 Unity 里 , **渲染路径** 决定了光照是如何应用到 Unity Shader 中的 . 因此 , 如果想要和光源打交道 , 我们就需要为每个 Pass 指定它使用的渲染路径 . 也就是说 , 我们只有为 Shader 正确地选择和设置了需要的渲染路径 , 该 Shader 的光照计算才能被正确执行 .

我们可以在每个 Pass 中使用标签来指定该 Pass 使用的渲染路径 . 这是通过设置 Pass 的 `LightModel` 标签实现的 . 不同类型的渲染路径可能会包含多种标签设置 . 下面给出了 Pass 的 `LightModel` 标签支持的渲染路径设置选项 .

`Always` 不管使用哪种渲染路径 , 该 Pass 总是会被渲染 , 但不会计算任何光照 .

`ForwardBase` 用于**前向渲染** , 该 Pass 会计算环境光 , 最重要的平行光 , 逐顶点 / SH 光源和 Lightmaps .

`ForwardAdd` 用于**前向渲染** , 该 Pass 会计算额外的逐像素光源 , 每个 Pass 对应一个光源 .

`Deferred` 用于**延迟渲染** , 该 Pass 会渲染 G 缓冲 .

`ShadowCaster` 把物体的深度信息渲染到阴影映射纹理 ( shadowmap ) 或一张深度纹理中 .

那么指定渲染路径到底有什么用呢 ? 如果一个 Pass 没有指定任何任何渲染路径会有什么问题吗 ? 我们来看看 Unity 的渲染引擎是如何处理这些渲染路径的吧 .

## 前向渲染路径

前向渲染路径是传统的渲染方式 , 也是我们最常用的一种渲染路径 .

### 前向渲染路径的原理

每进行一次完整的前向渲染 , 我们需要渲染该对象的渲染图元 , 并计算颜色缓冲区和深度缓冲区的信息 . 我们利用深度缓冲区来决定一个片元是否可见 , 如果可见就更新颜色缓冲区中的颜色 . 我们可以用伪代码来描述前向渲染路径的大致过程 :

```cs
Pass {
    for ( each primitive in this mode ) {
        for ( each fragment covered by this primitive ) {
            if ( failed in depth test ) {
                // 如果没有通过深度测试,说明该片元不可见.
                discard;
            } else {
                // 如果该片元可见,就计算光照
                float4 color = Shadering(materialInfo, pos, normal, lightDir, viewDir);
                // 更新帧缓冲区
                writeFrameBuffer( fragment, color );
            }
        }
    }
}
```
