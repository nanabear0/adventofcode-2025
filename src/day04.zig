const std = @import("std");
const Point = @import("utils.zig").Point;
const Neighbours = @import("utils.zig").Neighbours;

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
    var nodeIter = map.keyIterator();
    while (nodeIter.next()) |node| {
        var neighbourCount: usize = 0;
        for (Neighbours) |neighbour| {
            if (map.contains(node.add(neighbour))) neighbourCount += 1;
        }

        if (neighbourCount < 4) result += 1;
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
    var nodesToRemove = std.AutoHashMap(Point, void).init(gpa);
    defer nodesToRemove.deinit();

    while (true) {
        defer nodesToRemove.clearRetainingCapacity();

        var nodes = map.keyIterator();
        while (nodes.next()) |node| {
            var neighbourCount: usize = 0;
            for (Neighbours) |neighbour| {
                if (map.contains(node.add(neighbour))) neighbourCount += 1;
            }

            if (neighbourCount < 4) try nodesToRemove.put(node.*, {});
        }
        if (nodesToRemove.count() == 0) break;

        var removeIter = nodesToRemove.keyIterator();
        while (removeIter.next()) |nodeToRemove| {
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
