using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutlineEffect : MonoBehaviour
{
    private int m_defaultLayer;
    [SerializeField]
    private string m_outlineLayerName;
    [SerializeField]
    private Transform[] m_outlineGroup;

    private void Start()
    {
        m_defaultLayer = gameObject.layer; 
    }

    private void OnMouseEnter()
    {
        SetOutline(true);
    }

    private void OnMouseExit()
    {
        SetOutline(false);
    }

    private void SetOutline(bool state)
    {
        // �������Ч��
        if (state)
        {
            for (int i = 0; i < m_outlineGroup.Length; i++)
            {
                ChangeLayer(m_outlineGroup[i], LayerMask.NameToLayer(m_outlineLayerName));
            }
        }
        else// �ر����Ч��
        {
            for (int i = 0; i < m_outlineGroup.Length; i++)
            {
                ChangeLayer(m_outlineGroup[i], m_defaultLayer);
            }
        }
    }

    private void ChangeLayer(Transform trans, int layer)
    {
        if (trans.childCount > 0)
        {
            for(int i = 0; i < trans.childCount; i++)
            {
                ChangeLayer(trans.GetChild(i), layer);
            }
            trans.gameObject.layer = layer;
        }
        else
        {
            trans.gameObject.layer = layer;
        }
    }
}
