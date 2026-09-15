import * as rm from "https://deno.land/x/remapper@4.2.3/src/mod.ts"
import * as bundleInfo from '../bundleinfo.json' with { type: 'json' }

const pipeline = await rm.createPipeline({ bundleInfo })

const bundle = rm.loadBundle(bundleInfo)
const materials = bundle.materials
const prefabs = bundle.prefabs

// ----------- { SCRIPT } -----------

async function doMap(file: rm.DIFFICULTY_NAME) {
    const map = await rm.readDifficultyV3(pipeline, file)

    map.difficultyInfo.requirements = [
        'Chroma',
        'Noodle Extensions',
        'Vivify',
    ]
    rm.environmentRemoval(map, ['Environment', 'GameCore'])

    map.difficultyInfo.settingsSetter = {
        graphics: {},
        chroma: {
            disableEnvironmentEnhancements: false,
        },
        playerOptions: {
            leftHanded: rm.BOOLEAN.False,
        },
        colors: {},
        environments: {},
    }

    rm.setRenderingSettings(map, {
        qualitySettings: {
            realtimeReflectionProbes: rm.BOOLEAN.True,
            shadows: rm.SHADOWS.HardOnly,
            shadowDistance: 16,
            shadowResolution: rm.SHADOW_RESOLUTION.VeryHigh,
			softParticles: rm.BOOLEAN.True,
        },
        renderSettings: {
            fog: rm.BOOLEAN.True,
            fogEndDistance: 64,
        },
    })

    const orchestra = prefabs.orchestra.instantiate(map, 0)

    materials.health.set(map, {
        _Health: ["baseEnergy"],
        _Color:[0.5, 0.5, 0.5, 0.75],
    }, 0, 7000)

    materials.combo.set(map, {
        _Number: ["baseCombo"],
        _Color:[0.5, 0.5, 0.5, 0.75],
    }, 0, 7000)

    materials.acc.set(map, {
        _Number: ["baseRelativeScore"],
        _Color:[0.5, 0.5, 0.5, 0.75],
    }, 0, 7000)

}

await Promise.all([
    doMap('ExpertPlusStandard'),
    doMap('ExpertStandard'),
    doMap('HardStandard'),
    doMap('NormalStandard'),
    doMap('EasyStandard')
])

// ----------- { OUTPUT } -----------

pipeline.export({
    outputDirectory: '../OutputMaps/The Storm'
})
