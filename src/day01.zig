const std = @import("std");

const input = std.mem.trim(u8, @embedFile("inputs/day01.txt"), "\n");

fn part1() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');

    var result: isize = 0;
    var point: isize = 50;
    while (lines.next()) |line| {
        const num = try std.fmt.parseInt(isize, line[1..], 10);
        point = @mod(if (line[0] == 'R') point + num else point - num, 100);
        if (point == 0) result += 1;
    }

    std.debug.print("part 01: {}\n", .{result});
}

fn part2() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');

    var result: isize = 0;
    var point: isize = 50;
    while (lines.next()) |line| {
        const num = try std.fmt.parseInt(isize, line[1..], 10);
        if (num == 0) continue;

        const newPoint: isize = if (line[0] == 'R') point + num else point - num;
        defer point = @mod(newPoint, 100);

        if (newPoint <= 0 and point != 0) result += 1;
        result += @intCast(@divTrunc(@abs(newPoint), 100));
    }

    std.debug.print("part 02: {}\n", .{result});
}

pub fn day01() void {
    std.debug.print("-day01-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
