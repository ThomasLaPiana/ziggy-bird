// Ziggy Bird

const rl = @import("raylib");

const Obstacle = struct {
    position: rl.Vector2,
    size: rl.Vector2,
};

// Get a pair of obstacles with a gap in the middle
pub fn get_obstacle_pair(screenWidth: f32, screenHeight: f32) struct { Obstacle, Obstacle } {
    const gap = 200;
    // Create the obstacle at the top of the screen
    const obstaclePosition = rl.Vector2.init(screenWidth, 0);
    const obstacleSize = rl.Vector2.init(20, screenHeight / 2);
    const obstacle = Obstacle{ .position = obstaclePosition, .size = obstacleSize };

    // Set the obstacle on the bottom of the screen
    const obstaclePosition2 = rl.Vector2.init(screenWidth, screenHeight - gap);
    const obstacleSize2 = rl.Vector2.init(20, screenHeight / 2);
    const obstacle2 = Obstacle{ .position = obstaclePosition2, .size = obstacleSize2 };

    return .{ obstacle, obstacle2 };
}

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1000;
    const screenHeight = 700;

    rl.initWindow(screenWidth, screenHeight, "Ziggy Bird");
    defer rl.closeWindow();

    var birdPosition = rl.Vector2.init(screenWidth / 2, screenHeight / 2);

    // Get a pair of obstacles with a gap in the middle
    var obstacles = get_obstacle_pair(screenWidth, screenHeight);

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
        obstacles[0].position.x -= 1;
        obstacles[1].position.x -= 1;

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
            rl.drawRectangleV(obstacles[0].position, obstacles[0].size, rl.Color.dark_blue);
            rl.drawRectangleV(obstacles[1].position, obstacles[1].size, rl.Color.gray);
        }

        rl.drawText("Flap with 'k'", 10, 10, 20, rl.Color.dark_gray);

        //----------------------------------------------------------------------------------
    }
}
