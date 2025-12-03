const std = @import("std");

const input = std.mem.trim(u8, @embedFile("inputs/day03.txt"), "\n");

fn findLargest(line: []const u8, remainingSize: usize) usize {
    var max: usize = 0;
    var target: usize = 0;
    for (line[0 .. line.len - remainingSize + 1], 0..) |c, i| {
        const num = c - '0';
        if (num > max) {
            target = i;
            max = num;
        }
    }

    return target;
}

fn find(line: []const u8, size: usize) usize {
    var last: usize = 0;
    var result: usize = 0;
    for (0..size) |i| {
        const nextLargest = findLargest(line[last..], size - i);
        result = result * 10 + (line[last + nextLargest] - '0');
        last += nextLargest + 1;
    }

    return result;
}

fn doThing() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');

    var p1: usize = 0;
    var p2: usize = 0;
    while (lines.next()) |line| {
        p1 += find(line, 2);
        p2 += find(line, 12);
    }

    std.debug.print("part 01: {}\n", .{p1});
    std.debug.print("part 02: {}\n", .{p2});
}

pub fn day03() void {
    std.debug.print("-day03-\n", .{});
    doThing() catch unreachable;
}
