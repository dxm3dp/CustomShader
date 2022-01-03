# Queue

The **Queue** tag is important to determine when the object is rendered , though it can also be overriden on the **Material**(via the Inspector , **Render Queue**) .

The tag has to be set to one of these predefined names , each of which correspond with a Render Queue value :

- "Background"(1000)
- "Geometry"(2000)
- "AlphaTest"(2450)
- "Transparent"(3000)
- "Overlay"(4000)

We can also append +N or -N to the name to change the queue value the shader uses . e.g. "Geometry+1" will be 2001 , so rendered after other objects using 2000 . "Transparent-1" would be 2999 so would be rendered before other transparent objects using 3000 .

Values up to 2500 are considered **Opaque** so objects using the same queue value render front-to-back(objects nearer the camera render first). This is for optimised rendering so later fragments can be discarded if they fail the depth test(explained in more detail later) .

2501 onwards is **Transparent** and renders back-to-front(objects further away are rendered first) . Because transparent shaders tend not to use depth test/write , altering the queue will change how the shader sorts with other transparent objects .

You can also find other tags that can be used listed in the [Unity SubShaderTags documentation](https://docs.unity3d.com/Manual/SL-SubShaderTags.html) .