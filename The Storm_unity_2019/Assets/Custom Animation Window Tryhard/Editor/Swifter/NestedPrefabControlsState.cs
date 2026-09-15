using UnityEngine;

[System.Serializable]
public class NestedPrefabControlsState : PlayerPrefsSerializer
{
    [SerializeField] public bool m_isNestedPrefabPlaybackEnabled = false;

    protected override string PlayerPrefsKey => "NestedPrefabControlsState_";

    public override void Load()
    {
        m_isNestedPrefabPlaybackEnabled = LoadBool("isNestedPrefabPlaybackEnabled");
    }

    public override void Save()
    {
        SaveBool("isNestedPrefabPlaybackEnabled", m_isNestedPrefabPlaybackEnabled);
    }
}
