# Theory

PBR, or more commonly known as **physically based rendering**, is a collection of render techniques that are more or less based on the same underlying theory that more closely matches that of the physical world. As physically based rendering aims to mimic light in a physically plausible way, it generally looks more realistic compared to our original lighting algorithms like Phone and Blinn-Phone. Not only does it look better, as it closely approximates actual physics, we (and especially the artists) can author surface materials based on physical parameters without having to resort to cheap hacks and tweaks to make the lighting look right. One of the bigger advantages of authoring materials based on physical parameters is that these materials will look correct regardless of lighting conditions; something that is not true in non-PBR pipelines.

Physically based rendering is still nonetheless an approximation of reality (based on the principles of physics) which is why not called physical shading, but physically *based* shading. For a PBR lighting model to be considered physically based, it has to satisfy the following3 conditions:

1. Be based on the microfacet surface model.
2. Be energy conserving.
3. Use a physically based BRDF.

In the next PBR chapters we'll be focusing on the PBR approach as originally explored by Disney and adopted for real-time display by Epic Games. Their approach, based on the **metallic workflow**, is decently documented, widely adopted on most popular engines, and looks visually amazing. By the end of these chapters we'll have something that looks like this:

![](./Images/01.png)

Keep in mind, the topics in these chapters are rather advanced so it is advised to have a good understanding of OpenGL a shader lighting. Some of the more advanced knowledge you'll need for this series are: framebuffers, cubemaps, gamma correction, HDR, and normal mapping. We'll also delve into some advanced mathematics, but I'll do my best to explain the concepts as clear as possible.

## The microfacet model

All the PBR techniques are based on the theory of microfacets. The theory describes that any surface at a microscopic scale can be described by tiny little perfectly reflective mirrors called **microfacets**. Depending on the roughness of a surface, the alignment of these tiny little mirrors can differ quite a lot:

![surface](./Images/02.png)

The rougher a surface is, the more chaotically aligned each microfacet will be along the surface. The effect of these tiny-like mirror alignments is, that when specifically talking about specular lighting/reflection, the incoming light rays are more likely to scatter along completely different directions on rougher surfaces, resulting in a more widespread specular reflection. In contrast, on a smooth surface the light rays are more likely to reflect in roughly the same direction, giving us smaller and sharper reflections:

![surface](./Images/03.png)

No surface is completely smooth on a microscopic level, but seeing as these microfacets are small enough that we can't make a distinction between them on a per-pixel basis, we statistically approximate the surface's microfacet roughness give a **roughness** parameter. Based on the roughness of a surface, we can calculate the ratio of microfacets roughly aligned to some vector.

The more the microfacets are aligned to the halfway vector, the sharper and stronger the specular reflection. Together with roughness parameter that varies between 0 and 1, we can statistically approximate the alignment of the microfacets:

![surface](./Images/04.png)

We can see that higher roughness values display a much larger specular reflection shape, in contrast with the smaller and sharper specular reflection shape of smooth surfaces.

## Energy conservation

The microfacet approximation employs a form of **energy consercation**: outgoing light energy should never exceed the incoming light energy (excluding emissive surfaces). Looking at the above image we see the specular reflection are incres, but also its brightness decrease at increasing roughness levels. If the specular intensity were to be the same at each pixel (regardless of the size of the specular shape) the rougher surfaces would emit much more energy, violating the energy conservation principle. This is why we see specular reflections more intensely on smooth surfaces and more dimly on rough surfaces.

For energy conservation to hold, we need to make a clear distinction between diffuse and specular light. The moment of a light ray hits a surface, it gets split in both a **refraction** part and a **reflection** part. The reflection part is light that directly gets reflected and doesn't enter the surface; this is what we know as specular lighting. The refraction part is the remaining light that enters the surface and gets absorbed; this is what we know as diffuse lighting.

There are some nuances here as refracted light doesn't immediately get absorbed by touching the surface. From physics, we know that light can be modeled as a beam of energy that keeps moving forward until it loses all of its energy; the way a light beam loses energy is by collision. Each material consists of tiny little particles that can collide with the light ray as illustrate in the following image. The particles absorb some, or all, of the light's energy at each collision which is converted into heat.

![energy conservation](./Images/05.png)

Generally, not all energy is absorbed and the light will continue to **scatter** in a (mostly) random direction at which point it collides with other particles until its energy is depleted or it leaves the surface again. Light rays re-emerging out of the surface contribute to the surface's observed (diffuse) color. In physically based rendering however, we make the simplifying assumption that all refracted light gets absorbed and scattered at a very small area of impact, ignoring the effect of scattered light rays that would've exited the surface at a distance. Specific shader techniques that do take this into account are known as **subsurface scattering** techniques that significantly improve the visual quality on materials like skin, marble, or wax, but come at the price of performance.

An additional subtlety when it comes to reflection and refraction are surfaces that are **metallic**. Metallic surfaces react different to light compared to non-metallic surfaces (also known as **dielectrics**). Metallic surfaces follow the same principles of reflection and refraction, but **all** refracted light gets directly absorbed without scattering. This means metallic surfaces only leave reflected or specular light; metallic surfaces show no diffuse colors. Because of this apparent distinction between metals and dielectrics, they're both treated differently in the PBR pipeline which we'll delve into further down the chapter.

This distinction between reflected and refracted light bring us to another observation regarding energy preservation: they're **mutually exclusive**. Whatever light energy gets reflected will no longer be absorbed by the material itself. Thus, the energy to enter the surface as refracted light is directly the resulting energy after we've taken reflection into account.

We preserve this energy conserving relation by first calculating the specular fraction that amounts the percentage the incoming light's energy is reflected. The fraction of refracted light is then directly calculated from the specular fraction as:

```shader
// reflection/specular fraction
float kS = calculateSpecularComponent(...);
// refraction/diffuse fraction
float kD = 1.0 - kS;
```

This way we know both the amount the incoming light reflects and the amount the incoming light refracts, while adhering to the energy conservation principle. Given this approach, it is impossible for both the refracted/diffuse and reflected/specular contribution to exceed 1.0, thus ensuring the sum of their energy never exceeds the incoming light energy. Something we did not take into account in the previous lighting chapters.

## The reflectance equation

This brings us to something called the **render equation**, an elaborate equation some very smart folks out there came up with that is currently the best model we have for simulating the visuals of light. Physically based rendering strongly follows a more specialized version of the render equation known as the reflectance equation. To properly understand PBR, it's important to first build a solid understanding of the reflectance equation:

$$
L_{o}(p,w_{o})=\int \limits_{\Omega} f_{r}(p,w_{i},w_{o})L_{i}(p,w_{i})n\cdot w_{i}dw_{i}
$$

The reflectance equation appears daunting at first, but as we'll dissect it you'll see it slowly starts to makes sense. To understand the equation, we have to delve into a bit of **radiometry**. Radiometry is the measurement of electromagnetic radiation, including visible light. There are several radiometric quantities we can use to measure light over surfaces and directions, but we will only discuss fa single one that's relevant to the reflectance equation known as **radiance**, denoted here as L. Radiance is used to quantify the magnitude or strength of light coming from a single direction. It's a bit tricky to understand at first as radiance is a combination of multiple physical quantities so we'll focus on those first:

**Radiant flux**: radiant flux $\Phi$ is the transmitted energy of a light source measured in Watts. Light is a collective sum of energy over multiple different wavelengths, each wavelength associated with a particular (visible) color. The emitted energy of a light source can therefore be thought of as a function of all its different wavelengths. Wavelengths between 390nm to 700nm are considered part of the visible light spectrum i.e. wavelengths the human eye is able to perceive. Below you'll find an image of the different energies per wavelength of daylight:

![radiant](./Images/06.png)

The radiant flux measures the total area of this function of different wavelengths. Directly taking this measure of wavelengths as input is slightly impractical so we often make the simplification of representing radiant flux, not as a function of varying wavelength strengths, but as a light color triplet encoded as RGB (or as we'd commonly call it: light color). This encoding does come at quite a loss of information, but this is generally negligible for visual aspects.

**Solid angle**: the solid angle,denoted as $\omega$, tells us the size of area of a shape projected onto a unit sphere. The area of the projected shape onto this unit sphere is known as the **solid angle**; you can visualize the solid angle as a direction with volume:

![solid angle](./Images/07.png)

Think of being an observer at the center of this unit sphere and looking in the direction of the shape; the size of the silhouette you make out of it is the solid angle.

**Radiant intensity**: radiant intensity measures the amount of radiant flux per solid angle, or the strength of a light source over a projected area onto the unit sphere. For instance, given an omnidirectional light that radiates equally in all directions, the radiant intensity can give us its energy over a specific area (solid angle):

![radiant intensity](./Images/08.png)

The equation to describe the radiant intensity is defined as follows:

$$
I = \frac{d\Phi}{d\omega}
$$

Where $I$ is the radiant flux $\Phi$ over the solid angle $\omega$.

With knowledge of radiant flux, radiant intensity, and the solid angle, we can finally describe the equation for **radiance**. Radiance is described as the total observed energy in an area **A** over the solid angle $\omega$ of a light of radiant intensity $\Phi$:

$$
L = \frac{d^2\Phi}{dAd\omega\cos\theta}
$$

![radiant](./Images/09.png)

Radiance is a radiometric measure of the amount of light in an area, scaled by the **incident** (or incoming) angle $\theta$ of the light to the surface's normal as $\cos\theta$: light is weaker the less it directly radiates onto the surface, and strongest when it is directly perpendicular to the surface. This is similar to our perception of diffuse lighting from the basic lighting chapter as $\cos\theta$ directly corresponds to the dot product between the light's direction vector and the surface normal:

```hlsl
float cosTheta = dot(lightDir, N);
```

The radiance equation is quite useful as it contains most physical quantities we're interested in.
