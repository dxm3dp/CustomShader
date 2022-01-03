# Cull

Each pass can include **Cull** to control which sides of a triangle is rendered .

```shader
Pass
{
    //Cull Back
    //Cull Front
    Cull Off
    ...
}
```

Which faces correspond to the "front" or "back" sides depends on the winding order of the vertices per triangle . In Blender , this is determined by the Normals .