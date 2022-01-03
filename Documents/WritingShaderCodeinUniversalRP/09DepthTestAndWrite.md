# Depth Test/Write

Each pass can include the depth test (ZTest) and depth write (ZWrite) operations .

```shader
Pass
{
    ZTest LEqual // Default
    // ZTest Less | Greater | GEqual | Equal | NotEqual | Always

    ZWrite On // Default
    // ZWrite Off
}
```

Depth test determines how fragments are rendered depending on how their depth value compares to the value in the depth buffer . For example , **LEqual** (which is also the default if not included) , will only render fragments if their depth is **less or equal** to the buffer value .

Depth write determines whether the fragment's depth value replaces the value in the buffer when the test passes . With `ZWrite off` , the value remains unchanged . This is mainly useful for Transparent objects in order to achieve the correct blending , however this is also why sorting them is diffcult and they sometimes can render in the incorrect order .

Also related , the **Offset** operation allows you to offset the depth value with two parameters (factor , units) . I'm actually not very familiar with it myself , so ... copying the explanation from the docs (sorry) :

Factor scales the maximum Z slope , with respect to X or Y of the polygon , and units scale the minimum resolvable depth buffer value . This allows you to force one polygon to be drawn on top of another although they are actually in the same position . For example `Offset 0, -1` pulls the polygon closer to the camera , ignoring the polygon's slope , whereas `Offset -1, -1` will pull the polygon even closer when looking at a grazing angle .

```shader
Pass
{
    Offset 0, -1
}
```