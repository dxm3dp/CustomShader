# Blend & Transparency

For a shader to support transparency , a **Blend** mode can be defined . This determines how the fragment result is combined with existing values in the camera's colour target/buffer . The syntax is :

```shader
Blend SrcFactor DstFactor
// or
Blend SrcFactor DstFactor, SrcFactorA DstFactorA
// to support different factors for Alpha channel
```

Where the shader colour result is multiplied with the `SrcFactor` , and the existing colour target/buffer pixel is multiplied with the `DstFactor` . Each of these values is then combined based on a separate **BlendOp** operation , (which defaults to **Add**) , to produce the final colour result which replaces the value in the buffer .

The factors can be one of the following :

- One
- Zero
- SrcColor
- SrcAlpha
- DstColor
- DstAlpha
- OneMinusSrcColor
- OneMinusSrcAlpha
- OneMinusDstColor
- OneMinusDstAlpha

Also see the [Blend docs page](https://docs.unity3d.com/Manual/SL-Blend.html) for a list of the supported `BlendOp` operations if you want to select a different one than `Add` .

The most common blends include :

- Blend SrcAlpha OneMinusSrcAlpha - **Traditional transparency**
- Blend One OneMinusSrcAlpha - **Premultiplied transparency**
- Blend One One - **Additive**
- Blend OneMinusDstColor One - **Soft Additive**
- Blend DstColor Zero - **Multiplicative**
- Blend DstColor SrcColor - **2x Multiplicative**

A few examples :

```shader
Pass
{
    Blend SrcAlpha OneMinusSrcAlpha // (Traditional transparency)
    BlendOp Add // (is default anyway)

    /*
    This means ,
    newBufferColor = (fragColor * fragColor.a) + (bufferColor * (1 - fragColor.a))

    Which in this case is also equal to what a lerp does :
    newBufferColor = lerp(bufferColor, fragColor, fragColor.a)

    Of note :
    - If fragColor.a is 0, the bufferColor is not changed .
    - If fragColor.a is 1, fragColor is used fully.
    */
}

Pass
{
    Blend One One // (Additive)
    BlendOp Add // (is default anyway)

    /*
    This means ,
    newBufferColor = (fragColor * 1) + (bufferColor * 1)

    Of note :
    - Alpha does not affect this blending (though the final alpha value may change , likely affecting DstAlpha if used in the future . Hence why you may want different factors to be used for the alpha channel) .
    - In order to not change the bufferColor , fragColor must be black (0, 0, 0, 0)
    */
}
```