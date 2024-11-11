/// This file contains the logic for generating and updating Obstacles.
const rl = @import("raylib");

pub const obstacle_offset = 300;

// The struct for containing a pair of Obstacles
pub const ObstaclePair = struct {
    top: rl.Rectangle,
    bottom: rl.Rectangle,

    pub fn move_left(self: *ObstaclePair, amount: f32) void {
        self.top.x -= amount;
        self.bottom.x -= amount;
    }
};

// Get a pair of obstacles with a gap in the middle
pub fn get_obstacle_pair(screenWidth: f32, screenHeight: f32) ObstaclePair {
    // Calculate the gap and heights
    const gap_size: i32 = 100;
    const random: f32 = @floatFromInt(rl.getRandomValue(-100, 100));
    const gap_mid_point: f32 = screenHeight / 2 + random;
    const gap_low_point: f32 = gap_mid_point + gap_size;
    const gap_high_point: f32 = gap_mid_point - gap_size;

    const bottom = rl.Rectangle{ .x = screenWidth, .y = gap_low_point, .width = 20, .height = screenHeight };
    const top = rl.Rectangle{ .x = screenWidth, .y = 0, .width = 20, .height = gap_high_point };

    return ObstaclePair{ .top = top, .bottom = bottom };
}
