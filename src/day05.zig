const std = @import("std");

const input = std.mem.trim(u8, @embedFile("inputs/day05.txt"), "\n");

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn part01() !void {
    const splitPoint = std.mem.indexOf(u8, input, "\n\n") orelse unreachable;
    var lines = std.mem.splitScalar(u8, input[0..splitPoint], '\n');

    var ranges = std.ArrayList([2]usize).init(gpa);
    defer ranges.deinit();

    while (lines.next()) |line| {
        const divider = std.mem.indexOfScalar(u8, line, '-') orelse unreachable;
        const left = try std.fmt.parseInt(usize, line[0..divider], 10);
        const right = try std.fmt.parseInt(usize, line[divider + 1 ..], 10);
        try ranges.append([2]usize{ left, right });
    }

    var result: usize = 0;
    lines = std.mem.splitScalar(u8, input[splitPoint + 2 ..], '\n');
    while (lines.next()) |line| {
        const num = try std.fmt.parseInt(usize, line, 10);
        for (ranges.items) |range| {
            if (num > range[0] and num <= range[1]) {
                result += 1;
                break;
            }
        }
    }

    std.debug.print("part 01: {}\n", .{result});
}
fn part02() !void {
    const splitPoint = std.mem.indexOf(u8, input, "\n\n") orelse unreachable;
    var lines = std.mem.splitScalar(u8, input[0..splitPoint], '\n');

    var ranges = std.AutoHashMap([2]usize, void).init(gpa);
    defer ranges.deinit();

    while (lines.next()) |line| {
        const divider = std.mem.indexOfScalar(u8, line, '-') orelse unreachable;
        const left = try std.fmt.parseInt(usize, line[0..divider], 10);
        const right = try std.fmt.parseInt(usize, line[divider + 1 ..], 10);
        try ranges.put([2]usize{ left, right }, {});
    }

    main: while (true) {
        var firstIter = ranges.keyIterator();
        while (firstIter.next()) |first| {
            var secondIter = ranges.keyIterator();
            while (secondIter.next()) |second| {
                if (first == second or first[1] < second[0] or first[0] > second[1]) {
                    continue;
                }

                _ = ranges.remove(first.*);
                _ = ranges.remove(second.*);
                try ranges.put([2]usize{
                    @min(first[0], second[0]),
                    @max(first[1], second[1]),
                }, {});
                continue :main;
            }
        }

        break :main;
    }

    var result: usize = 0;
    var rangeIter = ranges.keyIterator();
    while (rangeIter.next()) |range| {
        result += range[1] - range[0] + 1;
    }

    std.debug.print("part 02: {}\n", .{result});
}

pub fn day05() void {
    std.debug.print("-day05-\n", .{});
    part01() catch unreachable;
    part02() catch unreachable;
}
