// This module is responsible for the main game loop and the game logic.
const std = @import("std");
const obs = @import("obstacles.zig");
const rl = @import("raylib");

// Set all of the Game constants
const birdSize: i16 = 50;
const fps: i32 = 120;
const screenWidth: i32 = 1000;
const screenHeight: i32 = 700;
const fallRate: f32 = 1.0;
const scrollRate: f32 = 2.0;

pub fn run_game() bool {
    // Initialization
    //--------------------------------------------------------------------------------------
    rl.initWindow(screenWidth, screenHeight, "Ziggy Bird");
    defer rl.closeWindow();

    var birdPosition = rl.Vector2.init(screenWidth / 2, screenHeight / 2);
    var gameLost = false;

    // Get a pair of obstacles with a gap in the middle
    const first = obs.get_obstacle_pair(screenWidth, screenHeight);
    const second = obs.get_obstacle_pair(screenWidth + obs.obstacle_offset, screenHeight);
    const third = obs.get_obstacle_pair(screenWidth + (obs.obstacle_offset * 2), screenHeight);
    const fourth = obs.get_obstacle_pair(screenWidth + (obs.obstacle_offset * 3), screenHeight);
    const fifth = obs.get_obstacle_pair(screenWidth + (obs.obstacle_offset * 4), screenHeight);
    var obstacles = [_]obs.ObstaclePair{ first, second, third, fourth, fifth };

    var camera = rl.Camera2D{
        .target = rl.Vector2.init(birdPosition.x + 20, birdPosition.y + 20),
        .offset = rl.Vector2.init(screenWidth / 2, screenHeight / 2),
        .rotation = 0,
        .zoom = 1,
    };

    var score: i32 = 0;
    var elapsedTime: f64 = 0.0;

    // Frames win games
    rl.setTargetFPS(fps);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        // Update
        //----------------------------------------------------------------------------------
        if (!gameLost) {
            const key_pressed = rl.isKeyPressed(rl.KeyboardKey.key_k);
            move_objects(&birdPosition, &obstacles, &camera, key_pressed);
        }

        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);

        // Camera Work
        {
            camera.begin();
            defer camera.end();

            // Handle the Bird
            rl.drawCircleV(birdPosition, birdSize, rl.Color.maroon);

            // Draw the obstacles
            for (obstacles) |pair| {
                rl.drawRectangleRec(pair.top, rl.Color.dark_blue);
                rl.drawRectangleRec(pair.bottom, rl.Color.dark_blue);
            }
        }

        // Calculate score and collisions
        for (obstacles) |pair| {
            const topCollision = rl.checkCollisionCircleRec(birdPosition, birdSize, pair.top);
            const bottomCollision = rl.checkCollisionCircleRec(birdPosition, birdSize, pair.bottom);
            if (topCollision or bottomCollision) {
                gameLost = true;
                continue;
            }

            if (pair.top.x == screenWidth / 2) {
                score += 1;
            }
        }

        if (gameLost) {
            rl.drawText("Game Over!", screenWidth / 2 - 100, screenHeight / 2, 20, rl.Color.black);
            rl.drawText("Press 'r' to restart or 'x' to exit!", screenWidth / 2 - 100, screenHeight / 2 + 30, 20, rl.Color.black);

            if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
                return true;
            } else if (rl.isKeyPressed(rl.KeyboardKey.key_x)) {
                return false;
            }
        } else {
            elapsedTime = rl.getTime();
        }

        // Draw the Score
        const scoreText = rl.textFormat("Score: %d", .{score});
        rl.drawText(scoreText, 10, 10, 20, rl.Color.dark_gray);

        // Draw the Time
        const timeText = rl.textFormat("Elapsed Time: %f", .{elapsedTime});
        rl.drawText(timeText, 10, 30, 20, rl.Color.dark_gray);

        // Draw the FPS
        const fpsText = rl.textFormat("Frames/Second: %d", .{rl.getFPS()});
        rl.drawText(fpsText, 10, 50, 20, rl.Color.dark_gray);

        //----------------------------------------------------------------------------------
    }

    return false;
}

// Move all of the Objects
pub fn move_objects(birdPosition: *rl.Vector2, obstacles: *[5]obs.ObstaclePair, camera: *rl.Camera2D, key_pressed: bool) void {
    // Move the Bird
    birdPosition.y += fallRate;

    // Move the Columns
    for (obstacles) |*pair| {
        pair.move_left(scrollRate);
    }

    camera.target = rl.Vector2.init(birdPosition.x + 20, screenHeight / 2);

    if (key_pressed) {
        birdPosition.y -= 50.0;
    }
}
