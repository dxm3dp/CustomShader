using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderCubemapWizard : ScriptableWizard
{
    public Transform renderFromPosition;
    public Cubemap cubemap;

    private void OnWizardUpdate()
    {
        string helpString = "Select transform to render from and cubemap to render into";
        bool isValid = (renderFromPosition != null) && (cubemap != null);
    }
    private void OnWizardCreate()
    {
        GameObject go = new GameObject("CubeCamera");
        go.AddComponent<Camera>();
        go.transform.position = renderFromPosition.position;
        go.transform.rotation = Quaternion.identity;
        go.GetComponent<Camera>().RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }

    [MenuItem("GameObject/Render into Cubemap")]
    private static void RenderCubemap()
    {
        ScriptableWizard.DisplayWizard<RenderCubemapWizard>("Render cubemap", "Render!");
    }
}
