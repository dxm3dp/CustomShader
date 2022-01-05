# Multi-Pass

If you have additinal passes without using a LightMode tag (or using SRPDefaultUnlit) , it will be used alongside rendering the main UniversalForward one . This is commonly referred to as "Multi-pass" . However while this may work in URP , it is **not recommended** as again it is something that breaks the SRP Batcher compatibility , which means rendering objects with the shader will be more expensive .

Instead , the recommended way to achieve Multi-pass is via one of the following :

- A separate shader , applied as a **second material** to the Mesh Renderer . If using submeshes , more materials can be added and it loops back around .
- **RenderObjects** feature on the Forward Renderer can be used to re-render all Opaque or Transparent objects on a **specific unity Layer** with an **Override Material** (which uses a separate shader) . This is only really useful if you want to render a lot of objects with this second pass - don't waste an entire Layer on a single object . Using the Override Material also **will not keep properties/textures** from the previous shader .
- **RenderObjects** feature again , but instead of an Override Material you can use a **Pass with a custom LightMode tag** in your shader and use the **Shader Tag ID** setting on the feature to render it . This method will keep properties/textures since it's the same shader still , however it is only suitable for code-written shaders as Shader Graph doesn't provides a way to inject custom passes .