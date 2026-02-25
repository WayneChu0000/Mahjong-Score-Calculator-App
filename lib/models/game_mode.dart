enum GameMode {
  hongKong,
  taiwan,
}

extension GameModeExtension on GameMode {
  String get name {
    switch (this) {
      case GameMode.hongKong:
        return 'Hong Kong';
      case GameMode.taiwan:
        return 'Taiwan';
    }
  }

  String get label {
    // Ideally this would use localization, but for the model we can use simple strings or keys
    switch (this) {
      case GameMode.hongKong:
        return 'Hong Kong Style (13 Tiles)';
      case GameMode.taiwan:
        return 'Taiwan Style (16 Tiles)';
    }
  }
}
