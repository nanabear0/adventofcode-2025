const std = @import("std");

const input = std.mem.trim(u8, @embedFile("inputs/day05.txt"), "\n");

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn doThing() !void {
    const split_point = std.mem.indexOf(u8, input, "\n\n") orelse unreachable;
    var lines = std.mem.splitScalar(u8, input[0..split_point], '\n');

    var ranges = std.AutoHashMap([2]usize, void).init(gpa);
    try ranges.ensureTotalCapacity(200);
    defer ranges.deinit();

    var finished = std.AutoHashMap([2]usize, void).init(gpa);
    try finished.ensureTotalCapacity(ranges.count());
    defer finished.deinit();

    while (lines.next()) |line| {
        const divider = std.mem.indexOfScalar(u8, line, '-') orelse unreachable;
        const left = try std.fmt.parseInt(usize, line[0..divider], 10);
        const right = try std.fmt.parseInt(usize, line[divider + 1 ..], 10);
        try ranges.put([2]usize{ left, right }, {});
    }

    main: while (true) {
        var first_iter = ranges.keyIterator();
        while (first_iter.next()) |first| {
            var second_iter = ranges.keyIterator();
            while (second_iter.next()) |second| {
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
            _ = ranges.remove(first.*);
            try finished.put(first.*, {});
        }

        break :main;
    }

    var p2: usize = 0;
    var finished_iter = finished.keyIterator();
    while (finished_iter.next()) |range| {
        p2 += range[1] - range[0] + 1;
    }

    var p1: usize = 0;
    lines = std.mem.splitScalar(u8, input[split_point + 2 ..], '\n');
    while (lines.next()) |line| {
        const num = try std.fmt.parseInt(usize, line, 10);

        finished_iter = finished.keyIterator();
        while (finished_iter.next()) |range| {
            if (num > range[0] and num <= range[1]) {
                p1 += 1;
                break;
            }
        }
    }

    std.debug.print("part 01: {}\n", .{p1});
    std.debug.print("part 02: {}\n", .{p2});
}

pub fn day05() void {
    std.debug.print("-day05-\n", .{});
    doThing() catch unreachable;
}
