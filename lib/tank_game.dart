import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:tankwar/actors/player_tank.dart';
import 'package:tankwar/routes/home_route.dart';
import 'package:tankwar/routes/multiplayer_route.dart';
import 'package:tankwar/routes/settings_route.dart';
import 'package:tankwar/routes/singleplayer_route.dart';
import 'package:tankwar/routes/splash_route.dart';
import 'package:tankwar/routes/tutorial_route.dart';

class TankGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  @override
  bool get debugMode => true;

  final PlayerTank playerTank = PlayerTank();
  bool joystickMode;
  TankGame({this.joystickMode = false});

  late final JoystickComponent joystick;

  void addDebugInfo() {
    add(FpsTextComponent(position: Vector2(40, 40)));
  }

  Sprite? map;

  void gameInit() {
    addDebugInfo();
    if (joystickMode) {
      addJoystick();
    }

    playerTank.position = size / 2;
    world.add(playerTank);
    map = Sprite(images.fromCache('temp_map.webp'));
    world.add(
      SpriteComponent(
        sprite: map,
        priority: -9991,
        size: map!.image.size,
      ),
    );
    world.add(ScreenHitbox());
    camera.follow(playerTank);
    resetCameraBounds(size);
  }

  void resetCameraBounds(Vector2 size) {
    camera.setBounds(
      Rectangle.fromLTWH(
        size.x / 2,
        size.y / 2,
        map!.image.size.x - size.x,
        map!.image.size.y - size.y,
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    if (map != null) {
      resetCameraBounds(size);
    }
    super.onGameResize(size);
  }

  void addJoystick({double radius = 80, double knobRadius = 30}) {
    final knobPaint = BasicPalette.white.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.white.withAlpha(100).paint();
    joystick = JoystickComponent(
      knobRadius: radius - knobRadius,
      knob: CircleComponent(radius: knobRadius, paint: knobPaint),
      background: CircleComponent(radius: radius, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    camera.viewport.add(joystick);
    playerTank.joystick = joystick;
    addFireButton();
  }

  void addFireButton() {
    final paint = BasicPalette.white.withAlpha(150).paint();
    final pressedPaint = BasicPalette.white.withAlpha(80).paint();
    camera.viewport.add(HudButtonComponent(
      button: CircleComponent(radius: 60, paint: paint),
      buttonDown: CircleComponent(radius: 60, paint: pressedPaint),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: () {
        playerTank.fire();
      },
    ));
  }

  late final RouterComponent router;

  @override
  FutureOr<void> onLoad() async {
    add(router = RouterComponent(
      initialRoute: 'splash',
      routes: <String, Route>{
        'splash': Route(SplashRoute.new),
        'home': Route(HomeRoute.new),
        'singleplayer': Route(SingleplaeryRoute.new),
        'multiplayer': Route(MultiplayerRoute.new),
        'settings': Route(SettingsRoute.new),
        'tutorial': Route(TutorialRoute.new),
      },
    ));
  }

  JoystickDirection calcDirection(
    bool left,
    bool up,
    bool right,
    bool down,
  ) {
    if (left && !up && !right && !down) {
      return JoystickDirection.left;
    } else if (left && up && !right && !down) {
      return JoystickDirection.upLeft;
    } else if (!left && up && !right && !down) {
      return JoystickDirection.up;
    } else if (!left && up && right && !down) {
      return JoystickDirection.upRight;
    } else if (!left && !up && right && !down) {
      return JoystickDirection.right;
    } else if (!left && !up && right && down) {
      return JoystickDirection.downRight;
    } else if (!left && !up && !right && down) {
      return JoystickDirection.down;
    } else if (left && !up && !right && down) {
      return JoystickDirection.downLeft;
    } else {
      return JoystickDirection.idle;
    }
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (joystickMode) {
      return super.onKeyEvent(event, keysPressed);
    }
    final dir = calcDirection(
      keysPressed.contains(LogicalKeyboardKey.keyA),
      keysPressed.contains(LogicalKeyboardKey.keyW),
      keysPressed.contains(LogicalKeyboardKey.keyD),
      keysPressed.contains(LogicalKeyboardKey.keyS),
    );
    playerTank.rotateToDirection(dir);
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      playerTank.fire();
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
