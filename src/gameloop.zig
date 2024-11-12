// This module is responsible for the main game loop and the game logic.
const std = @import("std");
const obs = @import("obstacles.zig");
const rl = @import("raylib");

// Set all of the Game constants
const bird_size: i16 = 50;
const fps: i32 = 120;
const screen_width: i32 = 1000;
const screen_height: i32 = 700;
const center_x: f32 = screen_width / 2;
const center_y: f32 = screen_height / 2;
const fall_rate: f32 = 1.0;
const scroll_rate: f32 = 2.0;

pub fn run_game() bool {
    const allocator = std.heap.page_allocator;

    // Start the Game Window
    rl.initWindow(screen_width, screen_height, "Ziggy Bird");
    defer rl.closeWindow();
    rl.setTargetFPS(fps);

    // Create the Bird
    var birdPosition = rl.Vector2.init(screen_width / 2, screen_height / 2);
    var gameLost = false;

    // Create the Obstacles
    var obstacles = obs.Obstacles.init(screen_width, screen_height, allocator);
    obstacles.addObstaclePair();

    // Init Stats
    var score: i32 = 0;
    var elapsed_time: f64 = 0.0;

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        if (!gameLost) {
            const key_pressed = rl.isKeyPressed(rl.KeyboardKey.key_k);
            move_objects(&birdPosition, &obstacles, key_pressed);
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);

        // Check if we need to add a new obstacle pair
        if (obstacles.pairs.getLast().top.x < screen_width - obs.obstacle_offset) {
            obstacles.addObstaclePair();
        }

        // Check if we need to remove the first obstacle pair
        if (obstacles.pairs.items[0].top.x < -20) {
            obstacles.removeFirstObstaclePair();
        }

        // Draw the bird
        rl.drawCircleV(birdPosition, bird_size, rl.Color.maroon);

        // Draw the obstacles
        for (obstacles.pairs.items) |pair| {
            rl.drawRectangleRec(pair.top, rl.Color.dark_blue);
            rl.drawRectangleRec(pair.bottom, rl.Color.dark_blue);
        }

        // Check for upper & lower window collision
        const upper_collision = rl.checkCollisionPointCircle(rl.Vector2{ .x = center_x, .y = 0 }, birdPosition, bird_size);
        const lower_collision = rl.checkCollisionPointCircle(rl.Vector2{ .x = center_x, .y = screen_height }, birdPosition, bird_size);
        if (upper_collision or lower_collision) {
            gameLost = true;
        }

        // Calculate score and collisions
        for (obstacles.pairs.items) |pair| {
            const top_collision = rl.checkCollisionCircleRec(birdPosition, bird_size, pair.top);
            const bottom_collision = rl.checkCollisionCircleRec(birdPosition, bird_size, pair.bottom);
            if (top_collision or bottom_collision) {
                gameLost = true;
                continue;
            }

            if (pair.top.x == screen_width / 2) {
                score += 1;
            }
        }

        if (gameLost) {
            rl.drawText("Game Over!", screen_width / 2 - 100, screen_height / 2, 20, rl.Color.black);
            rl.drawText("Press 'r' to restart or 'x' to exit!", screen_width / 2 - 100, screen_height / 2 + 30, 20, rl.Color.black);

            if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
                return true;
            } else if (rl.isKeyPressed(rl.KeyboardKey.key_x)) {
                return false;
            }
        } else {
            elapsed_time = rl.getTime();
        }

        // Draw the Score
        const scoreText = rl.textFormat("Score: %d", .{score});
        rl.drawText(scoreText, 10, 10, 20, rl.Color.dark_gray);

        // Draw the Time
        const timeText = rl.textFormat("Elapsed Time: %f", .{elapsed_time});
        rl.drawText(timeText, 10, 30, 20, rl.Color.dark_gray);

        // Draw the FPS
        const fpsText = rl.textFormat("Frames/Second: %d", .{rl.getFPS()});
        rl.drawText(fpsText, 10, 50, 20, rl.Color.dark_gray);

        // Show the number of obstacles
        const obsCountText = rl.textFormat("Obstacles in Memory: %d", .{obstacles.pairs.items.len});
        rl.drawText(obsCountText, 10, 70, 20, rl.Color.dark_gray);
    }

    return false;
}

// Move all of the Objects
pub fn move_objects(bird_position: *rl.Vector2, obstacles: *obs.Obstacles, key_pressed: bool) void {
    // Move the Bird
    bird_position.y += fall_rate;

    // Move the Columns
    for (obstacles.pairs.items) |*pair| {
        pair.moveLeft(scroll_rate);
    }

    if (key_pressed) {
        bird_position.y -= 50.0;
    }
}
