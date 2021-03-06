# 延迟渲染路径

前向渲染的问题是 : 当场景中包含大量实时光源时 , 前向渲染的性能会急剧下降 , 这是因为计算量增长迅速 . 例如 , 如果我们在场景的某一区域放置了多个光源 , 这些光源影响的区域互相重叠 , 那么为了得到最终的光照效果 , 我们就需要为该区域的每个物体执行多个 Pass 来计算不同光源对物体的光照结果 , 然后在颜色缓冲区中把这些结果混合起来得到最终的光照 . 然而 , 每执行一个 Pass 我们都需要重新渲染一遍物体 , 但很多计算实际上是重复的 .

延迟渲染是一种更古老的渲染方法 , 但由于上述前向渲染可能造成的瓶颈问题 , 近几年又流行起来 . 除了前向渲染中使用的颜色缓冲和深度缓冲外 , 延迟渲染还会利用额外的缓冲区 , 这些缓冲区也被统称为 G 缓冲 ( G-buffer ) . 其中 G 是英文 Geometry 的缩写 . G 缓冲区存储了我们所关心的表面 ( 通常指的是离摄像机最近的表面 ) 的其他信息 , 例如该表面的法线 , 位置 , 用于光照计算的材质属性等 . 还是一种用空间换时间的处理策略 .

## 延迟渲染的原理

延迟渲染主要包含了两个 Pass . 在第一个 Pass 中 , 我们不进行任何光照计算 , 而是仅仅计算哪些片元是可见的 , 这主要是通过深度缓冲技术来实现 . 当法线一个片元是可见的 , 我们就把它的相关信息存储到 G 缓冲区中 . 然后 , 在第二个 Pass 中 , 我们利用 G 缓冲区的各个片元信息 , 例如表面法线 , 视角方向 , 漫反射系数等 , 进行真正的光照计算 .

延迟渲染的过程大致可以用下面的伪代码来描述 :

```cs
Pass 1 {
    // 第一个 Pass 不进行真正的光照计算
    // 仅仅把光照计算需要的信息存储到 G 缓冲中
    for (each primitive in this model) {
        for (each fragment covered by this primitive) {
            if (failed in depth test) {
                // 如果没有通过深度测试 , 说明该片元是不可见的
                discard;
            } else {
                // 如果该片元可见 , 就把需要的信息存储到 G 缓冲中
                writeGBuffer(materialInfo , pos , normal , lightDir , viewDir);
            }
        }
    }
}

Pass 2 {
    // 利用 G 缓冲中的信息进行真正的光照计算
    for (each pixel in the screen) {
        if (the pixel is valid) {
            // 如果该像素是有效的,则读取它对应的G缓冲中的信息
            readGBuffer(pixel, materialInfo, pos, normal, lightDir, viewDir);
            // 根据读取到的信息进行光照计算
            float4 color = Shading(materialInfo, pos, normal, lightDir, viewDir);
            // 更新帧缓冲
            writeFrameBuffer(pixel, color);
        }
    }
}
```

可以看出 , 延迟渲染使用的 Pass 数目通常就是两个 , 这跟场景中包含的光源数目是没有关系的 . 换句话说 , 延迟渲染的效率不依赖于场景的复杂度 , 而是和我们使用的屏幕空间的大小有关 . 这是因为 , 我们需要的信息都存储在缓冲区中 , 而这些缓冲区可以理解成是一张张 2D 图像 , 我们的计算实际上就是在这些图像空间中进行的 .

## Unity 中的延迟渲染

