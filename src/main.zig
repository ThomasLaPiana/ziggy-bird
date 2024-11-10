/// Ziggy Bird
const obs = @import("obstacles.zig");
const rl = @import("raylib");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1000;
    const screenHeight = 700;

    rl.initWindow(screenWidth, screenHeight, "Ziggy Bird");
    defer rl.closeWindow();

    var birdPosition = rl.Vector2.init(screenWidth / 2, screenHeight / 2);

    // Get a pair of obstacles with a gap in the middle
    const init_pair = obs.get_obstacle_pair(screenWidth, screenHeight);
    const obstacles = [_]obs.ObstaclePair{init_pair};

    var camera = rl.Camera2D{
        .target = rl.Vector2.init(birdPosition.x + 20, birdPosition.y + 20),
        .offset = rl.Vector2.init(screenWidth / 2, screenHeight / 2),
        .rotation = 0,
        .zoom = 1,
    };

    // Frames win games
    rl.setTargetFPS(120);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        // Update
        //----------------------------------------------------------------------------------

        // Move the Bird
        birdPosition.y += 1;
        birdPosition.x += 1;

        // Move the Columns
        for (&obstacles) |*pair| {
            var top = pair.top;
            top.position.x -= 1;

            var bottom = pair.bottom;
            bottom.position.x -= 1;

            pair.* = obs.ObstaclePair{ .top = top, .bottom = bottom };
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

            rl.drawCircleV(birdPosition, 50, rl.Color.maroon);

            // Draw the obstacles
            rl.drawRectangleV(obstacles.top.position, obstacles.top.size, rl.Color.dark_blue);
            rl.drawRectangleV(obstacles.bottom.position, obstacles.bottom.size, rl.Color.gray);
        }

        rl.drawText("Flap with 'k'", 10, 10, 20, rl.Color.dark_gray);

        //----------------------------------------------------------------------------------
    }
}
