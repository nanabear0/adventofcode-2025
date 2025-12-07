const std = @import("std");
const Point = @import("utils.zig").Point;

const down = Point{ .x = 0, .y = 1 };
const right = Point{ .x = 1, .y = 0 };
const left = Point{ .x = -1, .y = 0 };

const input = std.mem.trim(u8, @embedFile("inputs/day07.txt"), "\n");

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn doThing() !void {
    var lines_iter = std.mem.splitScalar(u8, input, '\n');

    var map = std.AutoHashMap(Point, u8).init(gpa);
    defer map.deinit();

    var biimus = std.AutoHashMap(Point, usize).init(gpa);
    defer biimus.deinit();
    var y: isize = 0;
    while (lines_iter.next()) |line| : (y += 1) {
        for (line, 0..) |c, x| {
            try map.put(Point{ .x = @intCast(x), .y = y }, c);
            if (c == 'S') {
                try biimus.put(Point{ .x = @intCast(x), .y = y }, 1);
            }
        }
    }

    var splits: usize = 0;
    var timelines: usize = 0;
    var biimus_next = std.AutoHashMap(Point, usize).init(gpa);
    defer biimus_next.deinit();
    while (biimus.count() > 0) {
        defer biimus_next.clearRetainingCapacity();

        var biimu_iter = biimus.iterator();
        while (biimu_iter.next()) |beam| {
            const next = beam.key_ptr.add(down);
            const next_value = map.get(next);
            if (next_value == null) {
                timelines += beam.value_ptr.*;
                continue;
            } else if (next_value.? == '.') {
                const entry = try biimus_next.getOrPutValue(next, 0);
                entry.value_ptr.* += beam.value_ptr.*;
            } else if (next_value.? == '^') {
                var entry = try biimus_next.getOrPutValue(next.add(left), 0);
                entry.value_ptr.* += beam.value_ptr.*;
                entry = try biimus_next.getOrPutValue(next.add(right), 0);
                entry.value_ptr.* += beam.value_ptr.*;
                splits += 1;
            }
        }

        std.mem.swap(std.AutoHashMap(Point, usize), &biimus, &biimus_next);
    }

    std.debug.print("part 01: {}\n", .{splits});
    std.debug.print("part 02: {}\n", .{timelines});
}

pub fn day07() void {
    std.debug.print("-day07-\n", .{});
    doThing() catch unreachable;
}
