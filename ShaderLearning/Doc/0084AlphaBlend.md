# 透明度混合

2020.4.19(7)

透明度混合 : 这种方法可以得到真正的半透明效果 . 它会使用当前片元的透明度作为混合因子 , 与已经存储在颜色缓冲区中的颜色值进行混合 , 从而得到新的颜色 . 但是 , 透明度混合需要关闭深度写入 , 这使得我们要非常小心物体的渲染顺序 .

为了进行混合 , 我们需要使用 Unity 提供的混合命令--Blend . Blend 是 Unity 提供的设置混合模式的命令 . 想要实现半透明的效果就需要把当前自身的颜色和已经存在于颜色缓冲中的颜色值进行混合 , 混合时使用的函数就是由该指令决定的 .

- `Blend Off` 关闭混合 .
- `Blend SrcFactor DstFactor` 开启混合 , 并设置混合因子 . 源颜色 ( 该片元产生的颜色 ) 会乘以 SrcFactor , 而目标颜色 ( 已经存在于颜色缓冲区中的颜色 ) 会乘以 DstFactor , 然后把两者相加后再存入颜色缓冲区中 .
- `Blend SrcFactor DstFactor` , SrcFactorA DstFactorA 和上面几乎一样 , 只是使用不同的因子来混合透明通道 .
- `BlendOp BlendOperation` 并非是把源颜色和目标颜色简单相加后混合 , 而是使用 BlendOperation 对它们进行其他操作 .

在本节 , 我们使用 `Blend SrcFactor DstFactor` 来进行混合 . 需要注意的是 , 这个命令在设置混合因子的同时也开启了混合模式 . 这是因为 , 只有开启了混合模式之后 , 设置片元的透明通道才有意义 , 而 Unity 在我们使用 Blend 命令的时候就自动帮我们打开了 . 我们会把源颜色的混合因子 SrcFactor 设为 SrcAlpha , 而目标颜色的混合因子 DstFactor 设为 OneMinusSrcAlpha . 这意味着 , 经过混合后新的颜色是 :

$$
    DstColor_{new}=SrcAlpha*SrcColor+(1-SrcAlpha)*DstColor_{old}
$$

通常 , 透明度混合使用的就是这样的混合命令 .
