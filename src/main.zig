/// Ziggy Bird
const gameloop = @import("gameloop.zig");

pub fn main() anyerror!void {
    while (true) {
        const retry = gameloop.run_game();
        if (!retry) {
            break;
        }
    }
}
