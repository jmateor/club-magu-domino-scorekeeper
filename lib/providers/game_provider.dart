import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'dart:math';
import '../utils/commentary_data.dart';

const int winningScore = 200;

class GameProvider with ChangeNotifier {
  bool _isActive = true;
  List<Round> _rounds = [];
  int _scoreUs = 0;
  int _scoreThem = 0;
  Team? _streakTeam;
  int _streakCount = 0;
  Team? _winner;
  // Team Names
  String _nameUs = 'Nosotros';
  String _nameThem = 'Ellos';
  DateTime? _startTime;

  List<SavedGame> _savedGames = [];
  
  String? _notificationMessage;
  String? _notificationType; // 'fire' | 'sad'
  
  String _commentaryMessage = '"¡Concéntrate! Esta mano define la partida."';

  GameProvider() {
    _loadState();
  }

  bool get isActive => _isActive;
  List<Round> get rounds => _rounds;
  int get scoreUs => _scoreUs;
  int get scoreThem => _scoreThem;
  Team? get winner => _winner;
  String get nameUs => _nameUs;
  String get nameThem => _nameThem;
  List<SavedGame> get savedGames => _savedGames;
  String? get notificationMessage => _notificationMessage;
  String? get notificationType => _notificationType;

  // Commentary Override (for temporary specific messages)
  String? _temporaryCommentary;


  String get commentary => _temporaryCommentary ?? _commentaryMessage;

  void _updateCommentary() {
    // Restablezca la lógica temporal si es necesario, pero aquí simplemente recalculamos el mensaje estándar
    if (_temporaryCommentary != null) {
        // Podemos querer mantener el comentario temporal por un momento, pero por ahora priorizamos el estándar a menos que se sobreescriba recientemente
        // De hecho, dejemos que la UI lo limpie o simplemente lo sobreescriba si el estado cambia significativamente
    }

    if (_scoreUs == 0 && _scoreThem == 0) {
      _commentaryMessage = '"¡Concéntrate! Esta mano define la partida."';
      return;
    }

    // Caso especial: Primer ronda con alta puntuación
    if (_rounds.length == 1) {
       final lastPoints = _rounds.first.points;
       if (lastPoints > 60) {
         _commentaryMessage = CommentaryData.startHigh[Random().nextInt(CommentaryData.startHigh.length)];
         return;
       }
    }

    final diff = _scoreUs - _scoreThem;
    final random = Random();

    // Victorioso
    if (diff > 0) {
      if (diff < 10) {
        _commentaryMessage = CommentaryData.winningSmall[random.nextInt(CommentaryData.winningSmall.length)];
      } else if (winningScore - _scoreUs < 10) {
        _commentaryMessage = "¡Ya casi! Unos puntos más y a casa. 🏠";
      } else if (diff >= 10 && diff < 20) {
        _commentaryMessage = CommentaryData.winning10[random.nextInt(CommentaryData.winning10.length)];
      } else if (diff >= 20 && diff < 30) {
        _commentaryMessage = CommentaryData.winning20[random.nextInt(CommentaryData.winning20.length)];
      } else if (diff >= 40 && diff < 50) {
        _commentaryMessage = CommentaryData.winning40[random.nextInt(CommentaryData.winning40.length)];
      } else if (diff >= 50) {
        _commentaryMessage = CommentaryData.winning50[random.nextInt(CommentaryData.winning50.length)];
      } else {
        _commentaryMessage = CommentaryData.winningGeneral[random.nextInt(CommentaryData.winningGeneral.length)];
      }
    } 
    // Perdedor
    else if (diff < 0) {
      final absDiff = diff.abs();
      //  Chance de "Payer" taunt
      if (random.nextInt(10) == 0) { // 10% chance
         _commentaryMessage = CommentaryData.payerTaunt[random.nextInt(CommentaryData.payerTaunt.length)];
      } else if (absDiff < 10) {
        _commentaryMessage = CommentaryData.losingSmall[random.nextInt(CommentaryData.losingSmall.length)];
      } else if (winningScore - _scoreThem < 20) {
        _commentaryMessage = "¡ALERTA! 🚨 Algo anda mal. ¡Le esta haciendo señas!";
      } else if (absDiff < 20) {
        _commentaryMessage = CommentaryData.losingSmall[random.nextInt(CommentaryData.losingSmall.length)];
      } else if (winningScore - _scoreThem < 50) {
        _commentaryMessage = "¡ALERTA! 🚨 Algo anda mal. ¡Bueno hay bobo!";
      } else if (absDiff > 50) {
        _commentaryMessage = CommentaryData.losingBig[random.nextInt(CommentaryData.losingBig.length)];
      } else {
        _commentaryMessage = CommentaryData.losingGeneral[random.nextInt(CommentaryData.losingGeneral.length)];
      }
    }
    // Empate
    else {
      _commentaryMessage = CommentaryData.tie[random.nextInt(CommentaryData.tie.length)];
    }
  }

  void setNames(String us, String them) {
    _nameUs = us;
    _nameThem = them;
    _saveState();
    notifyListeners();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Game State
    final gameStateJson = prefs.getString('magu_current_game');
    if (gameStateJson != null) {
      try {
        final data = json.decode(gameStateJson);
        _isActive = data['isActive'];
        _rounds = (data['rounds'] as List).map((e) => Round.fromJson(e)).toList();
        _scoreUs = data['scoreUs'];
        _scoreThem = data['scoreThem'];
        _streakTeam = data['streak']['team'] == 'Team.us' ? Team.us : (data['streak']['team'] == 'Team.them' ? Team.them : null);
        _streakCount = data['streak']['count'];
        _winner = data['winner'] == 'Team.us' ? Team.us : (data['winner'] == 'Team.them' ? Team.them : null);
        _nameUs = data['nameUs'] ?? 'Nosotros';
        _nameUs = data['nameUs'] ?? 'Nosotros';
        _nameThem = data['nameThem'] ?? 'Ellos';
        _startTime = data['startTime'] != null ? DateTime.fromMillisecondsSinceEpoch(data['startTime']) : null;
      } catch (e) {
        // Fallback or clear if corrupt
        debugPrint("Error loading state: $e");
      }
    }

    // Load History
    final historyJson = prefs.getString('magu_history');
    if (historyJson != null) {
      try {
        _savedGames = (json.decode(historyJson) as List).map((e) => SavedGame.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error loading history: $e");
      }
    }
    _updateCommentary();
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final gameState = {
      'isActive': _isActive,
      'rounds': _rounds.map((e) => e.toJson()).toList(),
      'scoreUs': _scoreUs,
      'scoreThem': _scoreThem,
      'streak': {
        'team': _streakTeam.toString(),
        'count': _streakCount,
      },
      'winner': _winner.toString(),
      'nameUs': _nameUs,
      'nameThem': _nameThem,
      'startTime': _startTime?.millisecondsSinceEpoch,
    };
    
    await prefs.setString('magu_current_game', json.encode(gameState));
    await prefs.setString('magu_history', json.encode(_savedGames.map((e) => e.toJson()).toList()));
  }

  void addRound(int points, Team roundWinner) {
    if (points <= 0) return;

    final newScoreUs = roundWinner == Team.us ? _scoreUs + points : _scoreUs;
    final newScoreThem = roundWinner == Team.them ? _scoreThem + points : _scoreThem;
    
    final newRound = Round(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      points: points,
      winner: roundWinner,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    if (_streakTeam == roundWinner) {
      _streakCount++;
    } else {
      _streakTeam = roundWinner;
      _streakCount = 1;
    }


    // Lógica de comentario específica: Remontada (ganar después de 2 o más derrotas)
    // Comprobamos si el NUEVO ganador es diferente del propietario de la racha ANTIGUA (antes supuestamente lo actualizamos, pero en realidad solo lo actualizamos)
    // Wait, let's look at logic.
    // If THIS round winner is US, and previous rounds (streak) were THEM and count was >= 2...
    // But we already updated streak.
    // So if streakCount is 1 (meaning just switched) and BEFORE this it was the other team with >= 2.
    // We can't easily know previous streak count unless we track it or infer it.
    // Simplification: logic is "If I won this round, and the OTHER team had a streak of > 2 before this".
    // Since we just reset streak to 1 for us, we lost that info. 
    // Let's modify streak logic slightly or check history.
    
    // Better approach: Check history before adding round? No, we are adding.
    // Let's check the SECOND to last round if it exists.
    bool specificCommentaryTriggered = false;
    if (_rounds.length >= 2) { // 2 because we just added one, so 1 before this
       // Actually we need to check if the PREVIOUS sequence was negative.
       // Let's just use a flag passed from the logic before updating streak? 
       // Start Simple: If we just broke a streak of the opponent.
       // We can iterate backwards.
       int opponentStreak = 0;
       for (int i = _rounds.length - 2; i >= 0; i--) {
         if (_rounds[i].winner != roundWinner) {
           opponentStreak++;
         } else {
           break;
         }
       }
       
       if (opponentStreak >= 2) {
          _temporaryCommentary = "¡Comenzó el ingenio a moler caña! 🚜🎋";
          specificCommentaryTriggered = true;
       }
    }
    
    if (!specificCommentaryTriggered) {
        _temporaryCommentary = null; // Clear any old temp
    }

    // Check Winner
    Team? gameWinner;
    if (newScoreUs >= winningScore) {
      gameWinner = Team.us;
    } else if (newScoreThem >= winningScore) {
      gameWinner = Team.them;
    }

    // Notifications
    _notificationMessage = null;
    _notificationType = null;
    
    if (gameWinner == null) {
      if (_streakCount == 2) {
        _notificationMessage = roundWinner == Team.us ? '🔥 ¡$_nameUs están dominando!' : '😢 $_nameThem están calentando...';
        _notificationType = roundWinner == Team.us ? 'fire' : 'sad';
      } else if (_streakCount >= 3) {
        _notificationMessage = roundWinner == Team.us ? '🚀 ¡IMPARABLES! $_streakCount seguidas.' : '⚠️ ¡Cuidado! $_nameThem tienen racha.';
        _notificationType = roundWinner == Team.us ? 'fire' : 'sad';
      }
    }

    _scoreUs = newScoreUs;
    _scoreThem = newScoreThem;
    _rounds.add(newRound);
    _winner = gameWinner;

    _saveState();
    _updateCommentary();
    notifyListeners();
  }

  void clearNotification() {
    _notificationMessage = null;
    _notificationType = null;
    notifyListeners();
  }



  void deleteLastRound() {
    if (_rounds.isEmpty) return;

    final roundToRemove = _rounds.removeLast();

    // Revert Score
    if (roundToRemove.winner == Team.us) {
      _scoreUs -= roundToRemove.points;
    } else {
      _scoreThem -= roundToRemove.points;
    }

    // Revert Winner if needed
    if (_winner != null && ((roundToRemove.winner == Team.us && _scoreUs < winningScore) || (roundToRemove.winner == Team.them && _scoreThem < winningScore))) {
      _winner = null;
    }

    // Revert Streak (Complex to do perfectly without full hstory replay, but we can do a quick recalc)
    _recalculateStreak();
    
    _temporaryCommentary = null; // Clear temp commentary on undo
    _notificationMessage = null;

    _saveState();
    _updateCommentary();
    notifyListeners();
  }

  void _recalculateStreak() {
    if (_rounds.isEmpty) {
      _streakTeam = null;
      _streakCount = 0;
      return;
    }

    int count = 0;
    Team? currentTeam;

    for (int i = _rounds.length - 1; i >= 0; i--) {
      if (currentTeam == null) {
        currentTeam = _rounds[i].winner;
        count++;
      } else if (_rounds[i].winner == currentTeam) {
        count++;
      } else {
        break;
      }
    }
    
    _streakTeam = currentTeam;
    _streakCount = count;
  }

  void resetGame() {
    // If finished properly, save to history
    if (_winner != null) {
       final newRecord = SavedGame(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateFormat('d MMM, HH:mm', 'es_ES').format(DateTime.now()),
        scoreUs: _scoreUs,
        scoreThem: _scoreThem,
        winner: _winner!,
        durationFormatted: _calculateDuration(),
        nameUs: _nameUs,
        nameThem: _nameThem,
      );
      _savedGames.insert(0, newRecord);
    }

    _isActive = true;
    _rounds = [];
    _scoreUs = 0;
    _scoreThem = 0;
    _streakTeam = null;
    _streakCount = 0;
    _winner = null;
    _temporaryCommentary = null;
    _notificationMessage = null;
    _startTime = DateTime.now();

    _saveState();
    _updateCommentary();
    notifyListeners();
  }
  String _calculateDuration() {
    if (_startTime == null) return "Unknown";
    final duration = DateTime.now().difference(_startTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')} min";
  }
}
