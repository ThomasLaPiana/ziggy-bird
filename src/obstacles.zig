/// This file contains the logic for generating and updating Obstacles.
const rl = @import("raylib");

// The struct for a single Obstacle, resembling a column
pub const Obstacle = struct {
    position: rl.Vector2,
    size: rl.Vector2,

    // Move the obstacle to the left by a certain amount
    pub fn move_left(self: *Obstacle, amount: f32) void {
        self.position.x -= amount;
    }
};

// The struct for containing a pair of Obstacles
pub const ObstaclePair = struct {
    top: Obstacle,
    bottom: Obstacle,

    pub fn move_left(self: *ObstaclePair, amount: f32) void {
        self.top.move_left(amount);
        self.bottom.move_left(amount);
    }
};

// Get a pair of obstacles with a gap in the middle
pub fn get_obstacle_pair(screenWidth: f32, screenHeight: f32) ObstaclePair {
    const gap: f32 = @floatFromInt(rl.getRandomValue(200, 100));
    // Create the obstacle at the top of the screen
    const obstaclePosition = rl.Vector2.init(screenWidth, 0);
    const obstacleSize = rl.Vector2.init(20, screenHeight / 2);
    const obstacle = Obstacle{ .position = obstaclePosition, .size = obstacleSize };

    // Set the obstacle on the bottom of the screen
    const obstaclePosition2 = rl.Vector2.init(screenWidth, screenHeight - gap);
    const obstacleSize2 = rl.Vector2.init(20, screenHeight / 2);
    const obstacle2 = Obstacle{ .position = obstaclePosition2, .size = obstacleSize2 };

    return ObstaclePair{ .top = obstacle, .bottom = obstacle2 };
}
