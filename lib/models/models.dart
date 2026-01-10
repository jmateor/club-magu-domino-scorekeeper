

enum Team { us, them }

class Round {
  final String id;
  final int points;
  final Team winner;
  final int timestamp;

  Round({
    required this.id,
    required this.points,
    required this.winner,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'points': points,
        'winner': winner.toString(),
        'timestamp': timestamp,
      };

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      id: json['id'],
      points: json['points'],
      winner: json['winner'] == 'Team.us' ? Team.us : Team.them,
      timestamp: json['timestamp'],
    );
  }
}

class SavedGame {
  final String id;
  final String date;
  final int scoreUs;
  final int scoreThem;
  final Team winner;
  final String durationFormatted;
  final String nameUs;
  final String nameThem;

  SavedGame({
    required this.id,
    required this.date,
    required this.scoreUs,
    required this.scoreThem,
    required this.winner,
    required this.durationFormatted,
    this.nameUs = 'Nosotros',
    this.nameThem = 'Ellos',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'scoreUs': scoreUs,
        'scoreThem': scoreThem,
        'winner': winner.toString(),
        'durationFormatted': durationFormatted,
        'nameUs': nameUs,
        'nameThem': nameThem,
      };

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    return SavedGame(
      id: json['id'],
      date: json['date'],
      scoreUs: json['scoreUs'],
      scoreThem: json['scoreThem'],
      winner: json['winner'] == 'Team.us' ? Team.us : Team.them,
      durationFormatted: json['durationFormatted'],
      nameUs: json['nameUs'] ?? 'Nosotros',
      nameThem: json['nameThem'] ?? 'Ellos',
    );
  }
}
