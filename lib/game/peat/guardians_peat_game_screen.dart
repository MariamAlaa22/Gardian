import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gardians/game/peat/peat_assets.dart';
import 'package:gardians/game/peat/peat_prefs.dart';
import 'package:gardians/game/peat/peat_voice.dart';

enum _PeatMood { normal, anxious, refusal, challenging }

class _Hand {
  _Hand({
    required this.id,
    required this.start,
    required this.target,
  });

  final String id;
  final Offset start;
  final Offset target;
  double t = 0;
}

/// Full-screen Peat experience: body-boundary teaching, mini-game, streak,
/// day/night, and local “cute” voice repeat.
class GuardiansPeatGameScreen extends StatefulWidget {
  const GuardiansPeatGameScreen({super.key});

  @override
  State<GuardiansPeatGameScreen> createState() => _GuardiansPeatGameScreenState();
}

class _GuardiansPeatGameScreenState extends State<GuardiansPeatGameScreen>
    with TickerProviderStateMixin {
  final PeatPrefs _prefs = PeatPrefs();
  final PeatVoice _voice = PeatVoice();
  final GlobalKey _characterKey = GlobalKey();
  final GlobalKey _playAreaKey = GlobalKey();

  late final AnimationController _breath;

  PeatDayNightMode _dnMode = PeatDayNightMode.auto;
  int _streak = 1;
  _PeatMood _mood = _PeatMood.normal;
  bool _heroArmor = false;
  int _heroHits = 0;
  final List<_Hand> _hands = [];
  final _rand = math.Random();

  Timer? _gameTick;
  Timer? _spawnTimer;
  Timer? _moodReset;
  Timer? _anxiousReset;

  Offset _chestGlobal = Offset.zero;
  Offset _groinGlobal = Offset.zero;
  bool _zonesReady = false;

  static const double _handSeconds = 2.35;
  static const double _proximityFrac = 0.12;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final dn = await _prefs.readDayNightMode();
    final s = await _prefs.streakAfterOpen();
    if (!mounted) return;
    setState(() {
      _dnMode = dn;
      _streak = s;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateZoneGlobals());
  }

  @override
  void dispose() {
    _moodReset?.cancel();
    _anxiousReset?.cancel();
    _stopChallengeLoop();
    _breath.dispose();
    unawaited(_voice.dispose());
    super.dispose();
  }

  void _stopChallengeLoop() {
    _gameTick?.cancel();
    _gameTick = null;
    _spawnTimer?.cancel();
    _spawnTimer = null;
    _hands.clear();
  }

  bool get _nightVisual => peatIsNightVisual(_dnMode);

  void _updateZoneGlobals() {
    final box = _characterKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      _zonesReady = false;
      return;
    }
    final o = box.localToGlobal(Offset.zero);
    final w = box.size.width;
    final h = box.size.height;
    _chestGlobal = o + Offset(w * 0.5, h * 0.16);
    _groinGlobal = o + Offset(w * 0.5, h * 0.44);
    _zonesReady = true;
  }

  Rect _chestRectLocal(Size s) {
    return Rect.fromLTWH(s.width * 0.22, s.height * 0.06, s.width * 0.56, s.height * 0.24);
  }

  Rect _groinRectLocal(Size s) {
    return Rect.fromLTWH(s.width * 0.24, s.height * 0.34, s.width * 0.52, s.height * 0.22);
  }

  Rect _inflateFrac(Rect r, Size s, double frac) {
    final dx = s.width * frac;
    final dy = s.height * frac;
    return r.inflate(dx.clamp(8, 48) + dy / 2);
  }

  void _scheduleMoodNormal() {
    _moodReset?.cancel();
    _moodReset = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      if (_mood == _PeatMood.refusal) {
        setState(() => _mood = _PeatMood.normal);
      }
    });
  }

  void _onSensitiveTouch() {
    if (_mood == _PeatMood.challenging || _nightVisual) return;
    if (_mood == _PeatMood.refusal) return;
    HapticFeedback.mediumImpact();
    setState(() => _mood = _PeatMood.refusal);
    _scheduleMoodNormal();
  }

  void _setAnxiousBriefly() {
    if (_mood == _PeatMood.challenging || _mood == _PeatMood.refusal || _nightVisual) {
      return;
    }
    _anxiousReset?.cancel();
    setState(() => _mood = _PeatMood.anxious);
    _anxiousReset = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      if (_mood == _PeatMood.anxious) {
        setState(() => _mood = _PeatMood.normal);
      }
    });
  }

  void _handlePointerOnCharacter(Offset local, Size charSize) {
    if (_mood == _PeatMood.challenging || _nightVisual) return;
    final bounds = Rect.fromLTWH(0, 0, charSize.width, charSize.height);
    if (!bounds.contains(local)) return;

    final chest = _chestRectLocal(charSize);
    final groin = _groinRectLocal(charSize);
    final nearChest = _inflateFrac(chest, charSize, _proximityFrac).contains(local);
    final nearGroin = _inflateFrac(groin, charSize, _proximityFrac).contains(local);
    final inChest = chest.contains(local);
    final inGroin = groin.contains(local);

    if (inChest || inGroin) {
      _onSensitiveTouch();
    } else if ((nearChest || nearGroin) && _mood != _PeatMood.refusal) {
      _setAnxiousBriefly();
    }
  }

  void _handlePointerDownOnCharacter(Offset local, Size charSize) {
    if (_mood == _PeatMood.challenging || _nightVisual) return;
    final bounds = Rect.fromLTWH(0, 0, charSize.width, charSize.height);
    if (!bounds.contains(local)) return;

    final chest = _chestRectLocal(charSize);
    final groin = _groinRectLocal(charSize);
    if (chest.contains(local) || groin.contains(local)) {
      _onSensitiveTouch();
    }
  }

  String _imageForMood() {
    if (_mood == _PeatMood.challenging) return PeatAssets.challenge;
    if (_mood == _PeatMood.refusal) return PeatAssets.refusal;
    if (_mood == _PeatMood.anxious) return PeatAssets.anxious;
    if (_nightVisual && _mood == _PeatMood.normal) return PeatAssets.sleep;
    return PeatAssets.normal;
  }

  Future<void> _cycleDayNight() async {
    final next = switch (_dnMode) {
      PeatDayNightMode.auto => PeatDayNightMode.alwaysDay,
      PeatDayNightMode.alwaysDay => PeatDayNightMode.alwaysNight,
      PeatDayNightMode.alwaysNight => PeatDayNightMode.auto,
    };
    await _prefs.writeDayNightMode(next);
    if (!mounted) return;
    setState(() => _dnMode = next);
  }

  void _startChallenge() {
    if (_nightVisual) return;
    HapticFeedback.lightImpact();
    setState(() {
      _mood = _PeatMood.challenging;
      _heroHits = 0;
      _heroArmor = false;
      _hands.clear();
    });
    _stopChallengeLoop();
    _gameTick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _mood != _PeatMood.challenging) return;
      var missed = false;
      setState(() {
        for (final h in _hands) {
          h.t += 16 / (_handSeconds * 1000);
          if (h.t >= 1) missed = true;
        }
      });
      if (missed) _onMiniGameMiss();
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1650), (_) {
      if (!mounted || _mood != _PeatMood.challenging) return;
      if (_hands.length >= 3) return;
      _spawnHand();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateZoneGlobals());
  }

  void _spawnHand() {
    if (!_zonesReady) return;
    final area = _playAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (area == null || !area.hasSize) return;

    final w = area.size.width;
    final h = area.size.height;
    final fromTop = _rand.nextBool();
    final start = fromTop
        ? Offset(w * (0.08 + _rand.nextDouble() * 0.84), -40)
        : Offset(_rand.nextBool() ? -48 : w + 48, h * (0.15 + _rand.nextDouble() * 0.55));

    final targetChest = _rand.nextBool();
    final globalT = targetChest ? _chestGlobal : _groinGlobal;
    final target = area.globalToLocal(globalT);

    setState(() {
      _hands.add(_Hand(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        start: start,
        target: target,
      ));
    });
  }

  void _tapHand(_Hand h) {
    if (_mood != _PeatMood.challenging) return;
    HapticFeedback.selectionClick();
    setState(() {
      _hands.remove(h);
      _heroHits += 1;
    });
    if (_heroHits >= 3) {
      _finishMiniGameWin();
    }
  }

  void _finishMiniGameWin() {
    _stopChallengeLoop();
    HapticFeedback.heavyImpact();
    setState(() {
      _heroArmor = true;
      _mood = _PeatMood.normal;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hero Shield earned! You protected Peat’s private areas.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onMiniGameMiss() {
    _stopChallengeLoop();
    HapticFeedback.heavyImpact();
    setState(() {
      _heroHits = 0;
      _mood = _PeatMood.refusal;
    });
    _scheduleMoodNormal();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A hand reached a private zone. Peat says STOP — tap hands away next time!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onMicDown() async {
    final ok = await _voice.ensureMic();
    if (!ok || !mounted) return;
    await _voice.startRecording();
  }

  Future<void> _onMicUp() async {
    await _voice.stopRecordingAndPlayCute();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateZoneGlobals();
    });
    final m = MediaQuery.of(context);
    final scale = peatEvolutionScaleFromStreak(_streak);

    final bg = _nightVisual
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1020), Color(0xFF1B2744), Color(0xFF10182A)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB8E8FF), Color(0xFFE8F6FF), Color(0xFFFFE8F4)],
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _nightVisual ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(decoration: BoxDecoration(gradient: bg)),
            if (_nightVisual) ..._stars(m.size),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Row(
                      children: [
                        _chip(Icons.local_fire_department, 'Streak $_streak days', Colors.orange),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Day / night',
                          onPressed: _cycleDayNight,
                          icon: Icon(_nightVisual ? Icons.dark_mode : Icons.light_mode),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Guardians — Peat',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nightVisual
                        ? 'Night mode: rest time for Peat.'
                        : 'Private areas (swimsuit zones) are off-limits. Help Peat say STOP.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: _nightVisual ? Colors.white70 : Colors.black54,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final charHeight = constraints.maxHeight * 0.62;
                        final charWidth = math.min(constraints.maxWidth * 0.92, charHeight * 0.85);

                        final charSize = Size(charWidth, charHeight);
                        return Stack(
                          key: _playAreaKey,
                          clipBehavior: Clip.none,
                          children: [
                            if (_mood == _PeatMood.challenging) _challengeBanner(),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Listener(
                                  behavior: HitTestBehavior.opaque,
                                  onPointerDown: (e) =>
                                      _handlePointerDownOnCharacter(e.localPosition, charSize),
                                  onPointerMove: (e) =>
                                      _handlePointerOnCharacter(e.localPosition, charSize),
                                  child: SizedBox(
                                    width: charWidth,
                                    height: charHeight,
                                    child: _characterStack(charWidth, charHeight, scale),
                                  ),
                                ),
                              ),
                            ),
                            ..._handWidgets(),
                          ],
                        );
                      },
                    ),
                  ),
                  _bottomBar(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _characterStack(double charWidth, double charHeight, double scale) {
    final breath = 1.0 + (_breath.value * 0.018);

    return Center(
      child: Transform.scale(
        scale: scale * breath,
        alignment: Alignment.bottomCenter,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            KeyedSubtree(
              key: _characterKey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  _imageForMood(),
                  width: charWidth,
                  height: charHeight,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => _placeholder(charWidth, charHeight),
                ),
              ),
            ),
            if (_heroArmor && _mood != _PeatMood.challenging)
              Positioned(
                top: charHeight * 0.02,
                child: Icon(Icons.shield, size: charWidth * 0.22, color: Colors.amber.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [Colors.teal.shade200, Colors.pink.shade100],
        ),
      ),
      child: const Text('Add Peat images\nto assets/game/', textAlign: TextAlign.center),
    );
  }

  Widget _challengeBanner() {
    return Positioned(
      top: 0,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.deepPurple.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.back_hand, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hero challenge: tap ${_heroHits.clamp(0, 3)}/3 hands before they reach Peat’s private zones.',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _handWidgets() {
    return _hands.map((h) {
      final p = Offset.lerp(h.start, h.target, h.t.clamp(0.0, 1.0))!;
      return Positioned(
        left: p.dx - 28,
        top: p.dy - 28,
        child: GestureDetector(
          onTap: () => _tapHand(h),
          child: Material(
            elevation: 6,
            shape: const CircleBorder(),
            color: Colors.white,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _tapHand(h),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.back_hand, size: 36, color: Colors.brown),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _stars(Size s) {
    return List<Widget>.generate(18, (i) {
      final x = (i * 47 + 13) % s.width;
      final y = (i * 71 + 29) % (s.height * 0.55);
      return Positioned(
        left: x,
        top: y,
        child: Icon(Icons.star, size: 6 + (i % 4).toDouble(), color: Colors.white24),
      );
    });
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white.withValues(alpha: _nightVisual ? 0.12 : 0.9),
      labelStyle: TextStyle(color: _nightVisual ? Colors.white : Colors.black87),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _nightVisual ? null : _startChallenge,
              icon: const Icon(Icons.sports_martial_arts),
              label: const Text('Hero challenge'),
            ),
          ),
          const SizedBox(width: 12),
          Listener(
            onPointerDown: (_) => unawaited(_onMicDown()),
            onPointerUp: (_) => unawaited(_onMicUp()),
            onPointerCancel: (_) => unawaited(_voice.cancelRecording()),
            child: Material(
              color: Colors.pink.shade100,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.mic, color: Colors.pinkAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
