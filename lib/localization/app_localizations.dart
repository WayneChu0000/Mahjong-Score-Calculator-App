class AppLocalizations {
  // App Title
  static const String appTitle = 'Mahjong Score Calculator';
  
  // Home Screen
  static const String homeTitle = 'Mahjong Calculator';
  static const String welcomeBack = 'Welcome Back!';
  static const String newGroup = 'New Group';
  static const String history = 'History';
  static const String historyComingSoon = 'History feature coming soon...';
  static const String testFirebase = 'Test Firebase';
  static const String firebaseSuccess = 'Firebase connected: ';
  static const String firebaseFailed = 'Firebase failed: ';
  static const String savedGroups = 'Saved Player Groups';
  static const String viewAll = 'View All';
  static const String noSavedGroups = 'No saved player groups';
  static const String createGroup = 'Create Player Group';
  static const String players = 'players';
  static const String createdAt = 'Created: ';
  static const String edit = 'Edit';
  static const String start = 'Start';
  static const String allGroups = 'All Player Groups';
  static const String editGroupComingSoon = 'Edit group feature coming soon...';
  static const String scoreUpdated = 'Score updated for group: ';
  
  // Player Setup Screen
  static const String playerSetupTitle = 'Player Setup';
  static const String groupName = 'Group Name';
  static const String groupNameHint = 'Enter group name';
  static const String groupNameError = 'Please enter a group name';
  static const String playerName = 'Player Name';
  static const String playerNameHint = 'Enter player name';
  static const String addPlayer = 'Add Player';
  static const String minimumPlayers = 'At least 2 players required';
  static const String duplicatePlayer = 'Player already exists';
  static const String saveGroup = 'Save Group';
  static const String saveAndPlay = 'Save & Play';
  static const String cancel = 'Cancel';
  static const String remove = 'Remove';
  static const String playerList = 'Player List';
  static const String groupSaved = 'Group saved successfully!';
  static const String groupSaveFailed = 'Failed to save group';
  
  // Score Recording Screen
  static const String scoreRecording = 'Score Recording';
  static const String round = 'Round';
  static const String of = 'of';
  static const String dealer = 'Dealer: ';
  static const String calculateScore = 'Calculate Score';
  static const String endGame = 'End Game';
  static const String gameResults = 'Game Results';
  static const String finalScores = 'Final Scores';
  static const String winner = 'Winner';
  static const String close = 'Close';
  static const String nextRound = 'Next Round';
  
  // Score Calculation Screen  
  static const String scoreCalculation = 'Score Calculation';
  static const String enterScores = 'Enter Scores';
  static const String submit = 'Submit';
  static const String reset = 'Reset';
  static const String totalMustBeZero = 'Total must be zero';
  static const String confirmSubmit = 'Confirm non-zero total?';
  static const String totalIs = 'Total is ';
  static const String continueAnyway = 'Continue Anyway';
  
  // Common
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  
  // Messages
  static const String loadFailed = 'Failed to load player groups: ';
  static const String saveFailed = 'Failed to save: ';
  static const String deleteFailed = 'Failed to delete: ';
  static const String noInternet = 'No internet connection';
  static const String tryAgain = 'Please try again';
  
  // Format strings
  static String playerCount(int count) => '$count $players';
  static String roundOf(int current, int total) => 'Round $current of $total';
}
