namespace VivifyTemplate.Exporter.Scripts.Editor.QuestSupport
{
    public static class QuestPreferences
    {
        public static readonly string QuestProjectPlayerPrefsKey = "questPath";
        public static readonly string UnityEditorPlayerPrefsKey = "unityEditor";
#if UNITY_EDITOR_WIN
        public static readonly string UnityHubPath = "C:/Program Files/Unity Hub/Unity Hub.exe";
#elif UNITY_EDITOR_OSX
        public static readonly string UnityHubPath = "/Applications/Unity Hub.app/Contents/MacOS/Unity Hub";
#endif
        public static string ProjectPath
        {
            get => UnityEngine.PlayerPrefs.GetString(QuestProjectPlayerPrefsKey, "");
            set => UnityEngine.PlayerPrefs.SetString(QuestProjectPlayerPrefsKey, value);
        }

        public static string UnityEditor
        {
            //get => UnityEngine.PlayerPrefs.GetString(UnityEditorPlayerPrefsKey, "");
			get => @"c:\Program Files\Unity\Editor\2021.3.16f1\Editor\Unity.exe";
            set => UnityEngine.PlayerPrefs.SetString(UnityEditorPlayerPrefsKey, value);
        }
    }
}