/// Ziggy Bird
const std = @import("std");
const obs = @import("obstacles.zig");
const rl = @import("raylib");

// Set all of the Game constants
const birdSize: i16 = 50;
const fps: i32 = 60;
const screenWidth: i32 = 1000;
const screenHeight: i32 = 700;
const fallRate: f32 = 1.0;
const scrollRate: f32 = 2.0;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    rl.initWindow(screenWidth, screenHeight, "Ziggy Bird");
    defer rl.closeWindow();

    var birdPosition = rl.Vector2.init(screenWidth / 2, screenHeight / 2);

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

    // Frames win games
    rl.setTargetFPS(fps);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        // Update
        //----------------------------------------------------------------------------------

        // Move the Bird
        birdPosition.y += fallRate;

        // Move the Columns
        for (&obstacles) |*pair| {
            pair.move_left(scrollRate);
        }

        camera.target = rl.Vector2.init(birdPosition.x + 20, screenHeight / 2);

        if (rl.isKeyPressed(rl.KeyboardKey.key_k)) {
            birdPosition.y -= 50.0;
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
        // Check if we passed an obstacle
        for (obstacles) |pair| {
            if (pair.top.x == screenWidth / 2) {
                score += 1;
            }
        }

        const scoreText = rl.textFormat("Score: %d", .{score});
        rl.drawText(scoreText, 10, 10, 20, rl.Color.dark_gray);
        //----------------------------------------------------------------------------------
    }
}
