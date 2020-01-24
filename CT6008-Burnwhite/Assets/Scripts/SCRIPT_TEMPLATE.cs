//////////////////////////////////////////////////
// Author: Author name
// Date created: Date of the files creation
// Last edit: Date of the last edit
// Description: Description of the files purpose and a general explanation of how it works
// Comments: Any comments relating to the file
//////////////////////////////////////////////////

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SCRIPT_TEMPLATE : MonoBehaviour
{
    //////////////////////////////////////////////////
    //// Variables

    // Example variables
    public int m_publicInt;
    private float m_privateFloat;
    [SerializeField] private bool m_serializedPrivateBool;

    //////////////////////////////////////////////////
    //// Functions

    /// <summary>
    /// A template function with comments
    /// </summary>
    /// <param name="a_input">An integard input</param>
    /// <returns>The input</returns>
    public int MyFunction(int a_input)
    {
        return a_input;
    }
}
