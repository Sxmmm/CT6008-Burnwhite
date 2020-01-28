using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Outline : MonoBehaviour
{
    private static List<Outline> m_outlines;
    public static List<Outline> Outlines
    {
        get { return m_outlines; }
    }

    private void Awake()
    {
        if (m_outlines == null)
            m_outlines = new List<Outline>();
    }

    private void OnEnable()
    {
        m_outlines.Add(this);
    }

    private void OnDisable()
    {
        m_outlines.Remove(this);
    }
}
