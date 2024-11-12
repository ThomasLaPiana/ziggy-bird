/// This file contains the logic for generating and updating Obstacles.
const rl = @import("raylib");
const std = @import("std");

pub const obstacle_offset = 300;
pub const obstacle_width = 20;

pub const Obstacles = struct {
    pairs: std.ArrayList(ObstaclePair),
    screenHeight: f32,
    screenWidth: f32,

    pub fn init(screenWidth: f32, screenHeight: f32, allocator: std.mem.Allocator) Obstacles {
        const pairs = std.ArrayList(ObstaclePair).init(allocator);
        return Obstacles{ .pairs = pairs, .screenHeight = screenHeight, .screenWidth = screenWidth };
    }

    // Get a pair of obstacles with a gap in the middle
    pub fn add_obstacle_pair(self: *Obstacles) void {
        // Calculate the gap and heights
        const gap_size: i32 = 100;
        const random: f32 = @floatFromInt(rl.getRandomValue(-100, 100));
        const gap_mid_point: f32 = self.screenHeight / 2 + random;
        const gap_low_point: f32 = gap_mid_point + gap_size;
        const gap_high_point: f32 = gap_mid_point - gap_size;

        // Create the obstacle pair
        const bottom = rl.Rectangle{ .x = self.screenWidth, .y = gap_low_point, .width = obstacle_width, .height = self.screenHeight };
        const top = rl.Rectangle{ .x = self.screenWidth, .y = 0, .width = obstacle_width, .height = gap_high_point };
        const pair = ObstaclePair{ .top = top, .bottom = bottom };
        self.pairs.append(pair) catch unreachable;
    }

    pub fn remove_first_obstacle_pair(self: *Obstacles) void {
        _ = self.pairs.orderedRemove(0);
    }
};

// The struct for containing a pair of Obstacles
pub const ObstaclePair = struct {
    top: rl.Rectangle,
    bottom: rl.Rectangle,

    pub fn move_left(self: *ObstaclePair, amount: f32) void {
        self.top.x -= amount;
        self.bottom.x -= amount;
    }
};
