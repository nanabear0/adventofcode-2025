const std = @import("std");
const Point = @import("utils.zig").Point;

const input = std.mem.trim(u8, @embedFile("inputs/day09.txt"), "\n");
const test_input = std.mem.trim(u8, @embedFile("test/day09.txt"), "\n");

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn isBetweenTwoNumbers(n: isize, b1: isize, b2: isize) bool {
    return (n >= b1 and n <= b2) or (n >= b2 and n <= b1);
}

var point_cache = std.AutoHashMap(Point, bool).init(gpa);
fn isPointInsidePolygon(point: Point, line_segments: *[][2]Point) !bool {
    const b = point_cache.get(point);
    if (b != null) return b.?;
    var rightCast: usize = 0;
    var leftCast: usize = 0;
    for (line_segments.*) |line_segment| {
        const is_line_segment_vertical = line_segment[0].x == line_segment[1].x;
        if (is_line_segment_vertical) {
            if (!isBetweenTwoNumbers(point.y, line_segment[0].y, line_segment[1].y)) continue;
            if (point.x == line_segment[0].x) {
                try point_cache.put(point, true);
                return true;
            }
            if (point.x < line_segment[0].x) rightCast += 1;
            if (point.x > line_segment[0].x) leftCast += 1;
        } else {
            if (!isBetweenTwoNumbers(point.x, line_segment[0].x, line_segment[1].x)) continue;
            if (point.y == line_segment[0].y) {
                try point_cache.put(point, true);
                return true;
            }
        }
    }

    const result: bool = ((rightCast % 2) == 1) or ((leftCast % 2) == 1);
    try point_cache.put(point, result);
    return result;
}

fn isRectangleInsidePolygon(rectangle: [2]Point, line_segments: *[][2]Point) !bool {
    const left = @min(rectangle[0].x, rectangle[1].x);
    const right = @max(rectangle[0].x, rectangle[1].x);
    const top = @min(rectangle[0].y, rectangle[1].y);
    const bottom = @max(rectangle[0].y, rectangle[1].y);
    for (@intCast(left)..@intCast(right + 1)) |x| {
        if (!try isPointInsidePolygon(Point{ .x = @intCast(x), .y = top }, line_segments)) return false;
        if (!try isPointInsidePolygon(Point{ .x = @intCast(x), .y = bottom }, line_segments)) return false;
    }
    for (@intCast(top)..@intCast(bottom + 1)) |y| {
        if (!try isPointInsidePolygon(Point{ .x = left, .y = @intCast(y) }, line_segments)) return false;
        if (!try isPointInsidePolygon(Point{ .x = right, .y = @intCast(y) }, line_segments)) return false;
    }

    return true;
}

fn compareSize(_: void, a: [2]Point, b: [2]Point) std.math.Order {
    const left: isize = @intCast((@abs(a[0].x - a[1].x) + 1) * (@abs(a[0].y - a[1].y) + 1));
    const right: isize = @intCast((@abs(b[0].x - b[1].x) + 1) * (@abs(b[0].y - b[1].y) + 1));
    return std.math.order(left, right).invert();
}

fn part02() !void {
    var lines_iter = std.mem.splitScalar(u8, input, '\n');
    var points = try std.ArrayList(Point).initCapacity(gpa, 10);
    var line_segments = try std.ArrayList([2]Point).initCapacity(gpa, 10);
    while (lines_iter.next()) |line| {
        const delim: usize = std.mem.indexOfScalar(u8, line, ',') orelse unreachable;
        try points.append(gpa, Point{
            .x = try std.fmt.parseInt(isize, line[0..delim], 10),
            .y = try std.fmt.parseInt(isize, line[delim + 1 ..], 10),
        });
    }

    var rectangles = std.PriorityQueue([2]Point, void, compareSize).init(gpa, {});
    for (points.items[0 .. points.items.len - 1], 0..) |p1, i| {
        for (points.items[i + 1 ..]) |p2| {
            try rectangles.add([2]Point{ p1, p2 });
        }
    }
    try line_segments.append(gpa, [2]Point{ points.items[0], points.items[points.items.len - 1] });
    var window_iter = std.mem.window(Point, points.items, 2, 1);
    while (window_iter.next()) |window| {
        try line_segments.append(gpa, [2]Point{ window[0], window[1] });
    }

    while (rectangles.count() > 0) {
        const rectangle = rectangles.remove();
        if (try isRectangleInsidePolygon(rectangle, &line_segments.items)) {
            const size: isize = @intCast((@abs(rectangle[0].x - rectangle[1].x) + 1) * (@abs(rectangle[0].y - rectangle[1].y) + 1));
            std.debug.print("part 02: {}\n", .{size});
            break;
        }
    }
}

fn part01() !void {
    var lines_iter = std.mem.splitScalar(u8, input, '\n');
    var points = try std.ArrayList(Point).initCapacity(gpa, 10);

    while (lines_iter.next()) |line| {
        const delim: usize = std.mem.indexOfScalar(u8, line, ',') orelse unreachable;
        try points.append(gpa, Point{
            .x = try std.fmt.parseInt(isize, line[0..delim], 10),
            .y = try std.fmt.parseInt(isize, line[delim + 1 ..], 10),
        });
    }

    var maxSize: isize = 0;
    for (points.items[0 .. points.items.len - 1], 0..) |p1, i| {
        for (points.items[i + 1 ..]) |p2| {
            maxSize = @intCast(@max(maxSize, (@abs(p1.x - p2.x) + 1) * (@abs(p1.y - p2.y) + 1)));
        }
    }

    std.debug.print("part 01: {}\n", .{maxSize});
}

pub fn day09() void {
    std.debug.print("-day09-\n", .{});
    part01() catch unreachable;
    part02() catch unreachable;
}
