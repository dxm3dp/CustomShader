using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;
    private Texture2D generatedTexture = null;

    #region Material properties

    [SerializeField, SetProperty("TextureWidth")]
    private int textureWidth = 512;
    public int TextureWidth
    {
        get { return textureWidth; }
        set
        {
            textureWidth = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("BackgroundColor")]
    private Color backgroundColor = Color.white;
    public Color BackgroundColor
    {
        get
        {
            return backgroundColor;
        }
        set
        {
            backgroundColor = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("CircleColor")]
    private Color circleColor = Color.yellow;
    public Color CircleColor
    {
        get
        {
            return circleColor;
        }
        set
        {
            circleColor = value;
            UpdateMaterial();
        }
    }

    private float blurFactor = 2.0f;
    public float BlurFactor
    {
        get
        {
            return blurFactor;
        }
        set
        {
            blurFactor = value;
            UpdateMaterial();
        }
    }
    #endregion

    void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null)
            {
                Debug.LogWarning("Cannor find a renderer.");
                return;
            }

            material = renderer.sharedMaterial;
        }

        UpdateMaterial();
    }

    void UpdateMaterial()
    {
        if (material != null)
        {
            generatedTexture = GenerateProceduralTexture();
            material.SetTexture("_MainTex", generatedTexture);
        }
    }

    Texture2D GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);
        // 定义圆与圆之间的间距
        float circleInterval = textureWidth / 4f;
        // 定义圆的半径
        float radius = textureWidth / 10f;
        // 定义模糊系数
        float edgeBlur = 1f / blurFactor;

        for (int w = 0; w < textureWidth; w++)
        {
            for (int h = 0; h < textureWidth; h++)
            {
                // 使用背景颜色进行初始化
                Color pixel = backgroundColor;

                // 
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        // 计算当前所绘制的圆的圆心位置
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        // 
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        // 
                    }
                }
                proceduralTexture.SetPixel(w, h, color);
            }
        }
        proceduralTexture.Apply();

        return proceduralTexture;
    }
    Color color = Color.blue;
}