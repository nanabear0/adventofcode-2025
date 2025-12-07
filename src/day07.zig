const std = @import("std");
const Point = @import("utils.zig").Point;

const Down = Point{ .x = 0, .y = 1 };
const Right = Point{ .x = 1, .y = 0 };
const Left = Point{ .x = -1, .y = 0 };

const input = std.mem.trim(u8, @embedFile("inputs/day07.txt"), "\n");

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn doThing() !void {
    var linesIter = std.mem.splitScalar(u8, input, '\n');

    var map = std.AutoHashMap(Point, u8).init(gpa);
    defer map.deinit();

    var beams = std.AutoHashMap(Point, usize).init(gpa);
    defer beams.deinit();
    var y: isize = 0;
    while (linesIter.next()) |line| : (y += 1) {
        for (line, 0..) |c, x| {
            try map.put(Point{ .x = @intCast(x), .y = y }, c);
            if (c == 'S') {
                try beams.put(Point{ .x = @intCast(x), .y = y }, 1);
            }
        }
    }

    var splits: usize = 0;
    var timelines: usize = 0;
    var nextbiimu = std.AutoHashMap(Point, usize).init(gpa);
    defer nextbiimu.deinit();
    while (beams.count() > 0) {
        defer nextbiimu.clearRetainingCapacity();

        var biimuIter = beams.iterator();
        while (biimuIter.next()) |beam| {
            const next = beam.key_ptr.add(Down);
            const nextValue = map.get(next);
            if (nextValue == null) {
                timelines += beam.value_ptr.*;
                continue;
            } else if (nextValue.? == '.') {
                const ov = try nextbiimu.getOrPutValue(next, 0);
                ov.value_ptr.* += beam.value_ptr.*;
            } else if (nextValue.? == '^') {
                var ov = try nextbiimu.getOrPutValue(next.add(Left), 0);
                ov.value_ptr.* += beam.value_ptr.*;
                ov = try nextbiimu.getOrPutValue(next.add(Right), 0);
                ov.value_ptr.* += beam.value_ptr.*;
                splits += 1;
            }
        }

        std.mem.swap(std.AutoHashMap(Point, usize), &beams, &nextbiimu);
    }

    std.debug.print("part 01: {}\n", .{splits});
    std.debug.print("part 02: {}\n", .{timelines});
}

pub fn day07() void {
    std.debug.print("-day07-\n", .{});
    doThing() catch unreachable;
}
