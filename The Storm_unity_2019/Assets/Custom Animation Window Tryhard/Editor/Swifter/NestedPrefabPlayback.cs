using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;

namespace UnityAnimationWindow.Custom_Animation_Window_Tryhard.Editor.Swifter
{
    // Finds nested prefab instances underneath the timeline's animated root that
    // have their own Animator or (legacy) Animation component, and samples each
    // one's default animation clip in lock-step with the master timeline being
    // scrubbed/played back in the Animation Window.
    //
    // Both the master clip and every nested clip are assumed to start at time 0.
    // A nested clip that is shorter than the master timeline simply loops, so
    // every nested prefab is always showing something in sync with the cursor.
    // This is meant to approximate how the whole hierarchy will actually look
    // once it's running in the built game, where every nested Animator plays
    // its own animation independently and simultaneously.
    public class NestedPrefabPlayback
    {
        private class NestedAnimationTracker
        {
            public readonly GameObject target;
            public readonly AnimationClip clip;

            public NestedAnimationTracker(GameObject target, AnimationClip clip)
            {
                this.target = target;
                this.clip = clip;
            }

            public bool HasBeenDeleted()
            {
                return target == null || clip == null;
            }
        }

        private readonly List<NestedAnimationTracker> m_Trackers = new List<NestedAnimationTracker>();
        private GameObject m_root;

        public int trackedCount => m_Trackers.Count;

        public void Setup(GameObject root)
        {
            m_root = root;
            RecalculateTrackers();
        }

        public void RecalculateTrackers()
        {
            m_Trackers.Clear();

            if (m_root == null)
                return;

            // Nested Animators. The root's own Animator is skipped since its clip
            // is already being driven directly by the Animation Window.
            foreach (Animator animator in m_root.GetComponentsInChildren<Animator>(true))
            {
                if (animator.gameObject == m_root)
                    continue;

                AnimationClip clip = ResolveDefaultClip(animator);
                if (clip != null)
                    m_Trackers.Add(new NestedAnimationTracker(animator.gameObject, clip));
            }

            // Nested legacy Animation components.
            foreach (Animation animation in m_root.GetComponentsInChildren<Animation>(true))
            {
                if (animation.gameObject == m_root)
                    continue;

                // Don't double up if this object already got a clip from an Animator above.
                if (m_Trackers.Exists(t => t.target == animation.gameObject))
                    continue;

                AnimationClip clip = ResolveDefaultClip(animation);
                if (clip != null)
                    m_Trackers.Add(new NestedAnimationTracker(animation.gameObject, clip));
            }
        }

        private static AnimationClip ResolveDefaultClip(Animator animator)
        {
            RuntimeAnimatorController controller = animator.runtimeAnimatorController;
            if (controller == null)
                return null;

            AnimatorOverrideController overrideController = controller as AnimatorOverrideController;
            AnimatorController baseController = overrideController != null
                ? overrideController.runtimeAnimatorController as AnimatorController
                : controller as AnimatorController;

            if (baseController == null || baseController.layers.Length == 0)
                return null;

            AnimatorStateMachine stateMachine = baseController.layers[0].stateMachine;
            AnimatorState defaultState = stateMachine != null ? stateMachine.defaultState : null;
            if (defaultState == null)
                return null;

            Motion motion = defaultState.motion;

            if (overrideController != null && motion is AnimationClip baseClip)
                motion = overrideController[baseClip];

            return ResolveClipFromMotion(motion);
        }

        private static AnimationClip ResolveDefaultClip(Animation animation)
        {
            if (animation.clip != null)
                return animation.clip;

            // Fall back to the first clip assigned to the component, in case no
            // explicit default clip was set.
            foreach (AnimationState state in animation)
            {
                if (state != null && state.clip != null)
                    return state.clip;
            }

            return null;
        }

        // Best-effort: for a blend tree, just grab the first playable clip found.
        // This won't reflect the actual blend, but it gives the nested prefab
        // *some* representative motion while previewing.
        private static AnimationClip ResolveClipFromMotion(Motion motion)
        {
            if (motion == null)
                return null;

            if (motion is AnimationClip clip)
                return clip;

            if (motion is BlendTree blendTree)
            {
                foreach (ChildMotion child in blendTree.children)
                {
                    AnimationClip childClip = ResolveClipFromMotion(child.motion);
                    if (childClip != null)
                        return childClip;
                }
            }

            return null;
        }

        private void CheckForDeadTrackers()
        {
            // Temporary measure until playback can be reliably recalculated automatically.

            for (int i = 0; i < m_Trackers.Count; i++)
            {
                NestedAnimationTracker tracker = m_Trackers[i];
                if (tracker.HasBeenDeleted())
                {
                    m_Trackers.RemoveAt(i);
                    i--;
                    Debug.LogWarning("A nested prefab tracked for playback has been deleted. Should you recalculate playback?");
                }
            }
        }

        // Samples every tracked nested clip at the point within its own length
        // that corresponds to masterTime (looping shorter clips), so every
        // nested prefab plays back in sync with the master timeline's cursor.
        public void Sample(float masterTime)
        {
            if (m_Trackers.Count == 0)
                return;

            CheckForDeadTrackers();

            AnimationMode.BeginSampling();

            foreach (NestedAnimationTracker tracker in m_Trackers)
            {
                float length = tracker.clip.length;
                float localTime = length > 0f ? Mathf.Repeat(masterTime, length) : 0f;
                AnimationMode.SampleAnimationClip(tracker.target, tracker.clip, localTime);
            }

            AnimationMode.EndSampling();
        }
    }
}
