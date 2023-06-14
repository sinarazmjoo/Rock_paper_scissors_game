import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fidibo_test/sprite_model.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<SpriteModel> sprites = [];
  bool isFinished = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    createSprites();
    gameLoop();
  }

  void gameLoop() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final removedSprites = [];
      setState(() {
        for (var sprite in sprites) {
          sprite.move(5);
          checkBoundaryCollision(sprite, MediaQuery.of(context).size);
        }
        for (var sprite in sprites) {
          removeSprites(sprite, removedSprites);
        }
        for (var stripe in removedSprites) {
          sprites.removeWhere((element) => element.id == stripe.id);
        }
        final firstElementType = sprites.first.type;
        if (sprites
                .where((element) => element.type == firstElementType)
                .length ==
            sprites.length) {
          isFinished = true;
        }
        if (isFinished) {
          timer.cancel();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Finsihed'),
              );
            },
          );
        }
      });
    });
  }

  removeSprites(SpriteModel currentSprite, List removedSprites) {
    for (var sprite in sprites) {
      if (sprite != currentSprite) {
        if (checkCollision(currentSprite, sprite)) {
          if (currentSprite.type == sprite.type) {
            double horizontalDirection = currentSprite.direction.dx;
            double verticalDirection = currentSprite.direction.dy;
            currentSprite.direction =
                Offset(-horizontalDirection, -verticalDirection);
          } else {
            if (currentSprite.type == SpriteType.paper &&
                sprite.type == SpriteType.rock) {
              removedSprites.add(sprite);
            } else if (currentSprite.type == SpriteType.rock &&
                sprite.type == SpriteType.scissors) {
              removedSprites.add(sprite);
            } else if (currentSprite.type == SpriteType.scissors &&
                sprite.type == SpriteType.paper) {
              removedSprites.add(sprite);
            } else {
              removedSprites.add(currentSprite);
            }
          }
        }
      }
    }
  }

  void createSprites() {
    createSpritesOf(
      SpriteType.paper,
      Colors.yellow,
      const Icon(
        Icons.paste,
      ),
    );
    createSpritesOf(
      SpriteType.scissors,
      Colors.red,
      const Icon(
        Icons.content_cut_sharp,
      ),
    );
    createSpritesOf(
      SpriteType.rock,
      Colors.grey,
      const Icon(
        Icons.circle_rounded,
      ),
    );
  }

  createSpritesOf(SpriteType type, Color color, Icon icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double horizontalDirection = Random().nextBool() ? 1 : -1;
    double verticalDirection = Random().nextBool() ? 1 : -1;
    for (var i = 0; i < 5; i++) {
      final random = Random();
      final randomPosition = Offset(random.nextDouble() * screenWidth,
          random.nextDouble() * screenHeight);
      sprites.add(
        SpriteModel(
          id: Random().nextInt(1000000),
          type: type,
          color: color,
          position: randomPosition,
          direction: Offset(horizontalDirection, verticalDirection),
          icon: icon,
        ),
      );
    }
  }

  bool checkCollision(SpriteModel spriteOne, SpriteModel spriteTwo) {
    return spriteOne.position.dx <
            spriteTwo.position.dx + spriteTwo.size.width &&
        spriteOne.position.dx + spriteOne.size.width > spriteTwo.position.dx &&
        spriteOne.position.dy < spriteTwo.position.dy + spriteTwo.size.height &&
        spriteOne.position.dy + spriteOne.size.height > spriteTwo.position.dy;
  }

  checkBoundaryCollision(SpriteModel sprite, Size screenSize) {
    if (sprite.position.dx < 0) {
      sprite.direction = Offset(1, sprite.direction.dy);
    } else if (sprite.position.dx > screenSize.width - sprite.size.width) {
      sprite.direction = Offset(-1, sprite.direction.dy);
    } else if (sprite.position.dy < 0) {
      sprite.direction = Offset(sprite.direction.dx, 1);
    } else if (sprite.position.dy > screenSize.height - sprite.size.height) {
      sprite.direction = Offset(sprite.direction.dx, -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: sprites
            .map(
              (e) => Positioned(
                left: e.position.dx,
                top: e.position.dy,
                child: Sprite(spriteModel: e),
              ),
            )
            .toList(),
      ),
    );
  }
}

class Sprite extends StatefulWidget {
  const Sprite({
    required this.spriteModel,
    super.key,
  });

  final SpriteModel spriteModel;

  @override
  State<Sprite> createState() => _SpriteState();
}

class _SpriteState extends State<Sprite> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.spriteModel.size.width,
      height: widget.spriteModel.size.height,
      child: Center(
        child: Icon(
          (widget.spriteModel.icon.icon),
          color: widget.spriteModel.color,
          size: widget.spriteModel.size.height,
        ),
      ),
    );
  }
}
