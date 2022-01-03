# LightMode Tag

As mentioned , each pass includes a tag named **LightMode** , which describes to Unity how the pass is used .

The Univeral Render Pipeline uses the following modes :

- **"UniversalForward"** - Used to render objects in the **Forward** rendering path . Renders geometry with lighting .
- **"ShadowCaster"** - Used for casting shadows .
- **"DepthOnly"** - Used by the **Depth Prepass** to create the **Depth Texture**(_CameraDepthTexture) if MSAA is enabled or the platform doesn't support copying the depth buff .
- **"DepthNormals"** - Used by the **Depth Normals Prepass** to create the **Depth Texture**(_CameraDepthTexture) and **Normals Texture**(_CameraNormalsTexture) if a renderer feature requests if(via `ConfigureInput(ScriptableRenderPassInput.Normal);` in the ScriptableRenderPass , see [SSAO feature](https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/Runtime/RendererFeatures/ScreenSpaceAmbientOcclusion.cs) for example) .
- **"Meta"** - Used during Lightmap Baking
- **"Universal2D"** - Used for rendering when the 2D Renderer is enabled .
- **"SRPDefaultUnlit"** - Default if no LightMode tag is included in a Pass . Can be used to draw extra passes(in both forward/deferred rendering) , however this can break SRP Batcher compatibility . See **Multi-Pass** section below .

Future changes will also add these(v12+?):

- **"UniversalGBuffer"** - Used to render objects in the **Deferred** rendering path . Renders geometry into multiple buffers without lighting . Lighting is handled later in the path .
- **"UniversalForwardOnly"** - Similar to "UniversalForward" , but can be used to render objects as forward even in the Deferred path which is useful if the shader features data that won't fit in the GBuffer , such as Clear Coat normals .

I'm currently not including a section on the UniversalGBuffer pass since it hasn't been properly released yet . I may update the post in the future(but no promises!) .

Tags like "Always" , "ForwardAdd" , "PrepassBase" , "PrepassFinal" , "Vertex" , "VertexLMRGBM" , "VertexLM" are intened for the Built-in RP and are not supported in URP .

You can also use custom LightMode tag values , which you can trigger to be rendered via a Custom Renderer Feature or the RenderObjects feature that URP provides .