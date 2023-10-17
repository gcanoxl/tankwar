import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tankwar/actors/player_tank.dart';

class TankGame extends FlameGame with KeyboardEvents {
  @override
  bool get debugMode => true;

  final PlayerTank playerTank = PlayerTank();
  bool joystickMode;
  TankGame({this.joystickMode = false});

  late final JoystickComponent joystick;

  void addJoystick({double radius = 80, double knobRadius = 30}) {
    final knobPaint = BasicPalette.white.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.white.withAlpha(100).paint();
    joystick = JoystickComponent(
      knobRadius: radius - knobRadius,
      knob: CircleComponent(radius: knobRadius, paint: knobPaint),
      background: CircleComponent(radius: radius, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      priority: 19999,
    );
    add(joystick);
    playerTank.joystick = joystick;
    addFireButton();
  }

  void addFireButton() {
    final paint = BasicPalette.white.withAlpha(150).paint();
    final pressedPaint = BasicPalette.white.withAlpha(80).paint();
    add(HudButtonComponent(
      button: CircleComponent(radius: 60, paint: paint),
      buttonDown: CircleComponent(radius: 60, paint: pressedPaint),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: () {
        playerTank.fire();
      },
    ));
  }

  @override
  @mustCallSuper
  FutureOr<void> onLoad() async {
    await images.loadAll([
      'tank_green.png',
      'bullet_green_1.png',
      'temp_map.webp',
    ]);

    if (joystickMode) {
      // FIX: joystick doesn't work
      // FIX: fullscreen mode
      addJoystick();
    }

    playerTank.position = size / 2;
    world.add(playerTank);
    final map = Sprite(images.fromCache('temp_map.webp'));
    world.add(
      SpriteComponent(
        sprite: map,
        priority: -9991,
        size: map.image.size,
      ),
    );
    camera.follow(playerTank);
    camera.setBounds(Rectangle.fromPoints(size / 2, map.image.size - size / 2));
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
