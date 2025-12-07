const std = @import("std");
const Point = @import("utils.zig").Point;
const neighbour_directions = @import("utils.zig").neighbour_directions;

const input = std.mem.trim(u8, @embedFile("inputs/day04.txt"), "\n");

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn part01() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var map = std.AutoHashMap(Point, void).init(gpa);
    defer map.deinit();

    var y: isize = 0;
    while (lines.next()) |line| : (y += 1) {
        for (line, 0..) |c, x| {
            if (c == '@') {
                try map.put(Point{ .x = @intCast(x), .y = y }, {});
            }
        }
    }

    var result: usize = 0;
    var node_iter = map.keyIterator();
    while (node_iter.next()) |node| {
        var neighbour_count: usize = 0;
        for (neighbour_directions) |neighbour| {
            if (map.contains(node.add(neighbour))) neighbour_count += 1;
        }

        if (neighbour_count < 4) result += 1;
    }

    std.debug.print("part 01: {}\n", .{result});
}
fn part02() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var map = std.AutoHashMap(Point, void).init(gpa);
    defer map.deinit();

    var y: isize = 0;
    while (lines.next()) |line| : (y += 1) {
        for (line, 0..) |c, x| {
            if (c == '@') {
                try map.put(Point{ .x = @intCast(x), .y = y }, {});
            }
        }
    }

    var result: usize = 0;
    var nodes_to_remove = std.AutoHashMap(Point, void).init(gpa);
    defer nodes_to_remove.deinit();

    while (true) {
        defer nodes_to_remove.clearRetainingCapacity();

        var nodes = map.keyIterator();
        while (nodes.next()) |node| {
            var neighbour_count: usize = 0;
            for (neighbour_directions) |neighbour| {
                if (map.contains(node.add(neighbour))) neighbour_count += 1;
            }

            if (neighbour_count < 4) try nodes_to_remove.put(node.*, {});
        }
        if (nodes_to_remove.count() == 0) break;

        var remove_iter = nodes_to_remove.keyIterator();
        while (remove_iter.next()) |nodeToRemove| {
            _ = map.remove(nodeToRemove.*);
            result += 1;
        }
    }

    std.debug.print("part 02: {}\n", .{result});
}

pub fn day04() void {
    std.debug.print("-day04-\n", .{});
    part01() catch unreachable;
    part02() catch unreachable;
}
