using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectHorizontalPan : MonoBehaviour
{
    public float range = 1f;
    private Vector3 startingPos;

    private void Start()
    {
        startingPos = transform.position;
    }

    void Update()
    {
        transform.position = startingPos + (Vector3.right * range * Mathf.Sin(Time.time));
    }
}
