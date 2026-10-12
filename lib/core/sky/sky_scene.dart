/// The ten moods of the live background. Chosen from the weather by
/// `resolveSkyScene`; each owns a palette and a particle system
/// (`SkyScenePalette`). Pure Dart so the domain layer can pick a scene.
enum SkyScene {
  clearDay,
  twilight,
  clearNight,
  cloudyDay,
  cloudyNight,
  rain,
  storm,
  snow,
  fog,
  dust,
}
