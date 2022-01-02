# Shading models in Universal Render Pipeline

A shading model defines how a Material's color caries depending on factors such as surface orientation , viewer direction , and lighting . Your choice of a shading model depends on the artistic direction and performance budget of your application . Universal Render Pipeline (URP) provides Shaders with the following shading models :

- Physically Based Shading
- Simple Shading
- Baked Lit Shading
- No lighting

## Physically Based Shading

Physically Based Shading simulates how objects look in real life by computing the amount of light reflected from the surface based on physics principles . This lets you create photo-realistic objects and surfaces .

This PBS model follows two principles :

**Energy conservation** - Surfaces never reflect more light than the total incoming light . The only exception to this is when an object emits light . For example , a neon sign . **Microgeometry** - Surfaces have geometry at a microscopic level . Some objects have smooth microgeometry , which gives them a mirror-like appearance . Other objects have rough microgeometry , which makes them look more dull . In URP , you can mimic the level of smoothness of a rendered object's surface .

When light hits a rendered object's surface , part of the light is reflected and part is refracted . The reflected light is called **specular reflection** . This varies depending on the camera direction and the point at which the light hits a surface , also called the angle of incidence . In this shading model , the shape of specular highlight is approximated with a GGX function .

For metal objects , the surface absorbs and changes the light . For non-metallic objects , also called dielectric objects , the surface reflects parts of the light .

Light attenuation is only affected by the light intensity . This means that you don't have to increase the range of your light to control the attenuation .

The following URP Shaders use Physically Based Shading :

- Lit
- Parricles Lit

Note : This shading model is not suitable for low-end mobile hardware . If you're targeting this hardware , use Shaders with a **Simple Shading** model .

## Simple shading

This shading model is suitable for stylized visuals or for games that run on less powerful platforms . With this shading model , Materials are not truly photorealistic . The Shaders do not conserve energy . This shading model is based on the Blinn-Phong model .

In this Simple shading model , Materials reflect diffuse and specular light , and there's no correlation between the two . The amount of diffuse and specular light reflected from Materials depends on the properties you select for the Material and the total reflected light can therefore exceed the total incoming light . Specular reflection varies only with camera direction .

Light attenuation is only affected by the light intensity .

The following URP Shaders use Simple Shading :

- Simple Lit
- Particles Simple Lit

## Baked Lit shading

The Baked Lit shading model doesn't have real-time lighting . Materials can receive baked lighting from either lightmaps or Light Probes . This adds some depth to your Scenes at a small performance cost . Games with this shading model can run on less powerful platforms .

The URP Baked Lit shader is the only shader that uses the Baked Lit shading model .

## Shaders with no lighting

URP comes with some Shaders that are Unlit . This means that they have no directional lights and no baked lighting . Because there are no light calculations , these shaders compile faster than Shaders with lighting . If you know in advance that your GameObject or visual doesn't need lighting , choose an Unlit shader to save calculation and build time in your final product .

The following URP Shaders have no lighting :

- Unlit
- Particles Unlit
