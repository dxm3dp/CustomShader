# Pass 

Pass blocks are defined in each SubShader . There can be multiple passes , where each should include a specific tag named **LightMode** with **determines when/how the pass is used**(explained further in the next section) .

```shader
SubShader
{
    Tags {"RenderPipeline"="UniversalPipeline" "Queue"="Geometry"}

    Pass
    {
        Name "Forward"
	Tags {"LightMode"="UniversalForward"}
	...
    }
    Pass
    {
        Name "ShadowCaster"
	Tags {"LightMode"="ShadowCaster"}
	...
    }
    Pass
    {
        Name "DepthOnly"
	Tags {"LightMode"="DepthOnly"}
	...
    }

    // UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    ...
}
```

You can also give them an optional **Name** which allows `UsePass` to be used in a different shader . An example is shown with using the ShadowCaster pass from the URP Lit shader , however I've commented it out . This is because it actually isn't recommended to use `UsePass` . In order to keep SRP Batcher compatibility , **all passes in the shader must have the same UnityPerMaterial CBUFFER** , and `UsePass` currently can break that as it uses the CBUFFER as defined in that previous shader . Instead , you should write each pass yourself or copy it manually . We'll be going over some of these passes in a later section .

Depending on what the shader is for you might not even need additinal passes . A shader used in a Blit render feature to apply a fullscreen image effect for example will only need a single pass where the LightMode tag could be left out completely .