const std = @import("std");
const Point = @import("utils.zig").Point;

const Point3 = struct {
    x: isize,
    y: isize,
    z: isize,
};

const Distance = struct {
    p1: Point3,
    p2: Point3,
    distance: isize,

    pub fn getDistance(p1: Point3, p2: Point3) Distance {
        const x = p1.x - p2.x;
        const y = p1.y - p2.y;
        const z = p1.z - p2.z;
        return Distance{ .p1 = p1, .p2 = p2, .distance = x * x + y * y + z * z };
    }
};

const input = std.mem.trim(u8, @embedFile("inputs/day08.txt"), "\n");
const test_input = std.mem.trim(u8, @embedFile("test/day08.txt"), "\n");

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn distanceCompareFn(_: void, a: Distance, b: Distance) std.math.Order {
    return std.math.order(a.distance, b.distance);
}
fn usizeCompareFn(_: void, a: usize, b: usize) std.math.Order {
    return std.math.order(a, b).invert();
}

fn part01() !void {
    var lines_iter = std.mem.splitScalar(u8, input, '\n');
    var points = std.AutoArrayHashMap(Point3, ?usize).init(gpa);
    defer points.deinit();

    while (lines_iter.next()) |line| {
        var dimensions_iter = std.mem.splitScalar(u8, line, ',');
        var point: [3]isize = [3]isize{ 0, 0, 0 };
        var i: usize = 0;
        while (dimensions_iter.next()) |dim| : (i += 1) {
            point[i] = try std.fmt.parseInt(isize, dim, 10);
        }
        try points.put(Point3{ .x = point[0], .y = point[1], .z = point[2] }, null);
    }

    var connections = std.PriorityQueue(Distance, void, distanceCompareFn).init(gpa, {});
    defer connections.deinit();

    for (points.keys()[0 .. points.count() - 1], 0..) |p1, i| {
        for (points.keys()[i + 1 ..]) |p2| {
            try connections.add(Distance.getDistance(p1, p2));
        }
    }
    var circuits = try std.ArrayList(?std.AutoHashMap(Point3, void)).initCapacity(gpa, points.count());
    for (0..1000) |_| {
        const connection = connections.remove();
        var new_circuit = std.AutoHashMap(Point3, void).init(gpa);
        const new_index = circuits.items.len;
        const circuit_index1 = points.get(connection.p1).?;
        if (circuit_index1 == null) {
            try new_circuit.put(connection.p1, {});
        } else {
            var old_circuit_iter = circuits.items[circuit_index1.?].?.keyIterator();
            while (old_circuit_iter.next()) |point| {
                try new_circuit.put(point.*, {});
            }
            circuits.items[circuit_index1.?].?.deinit();
            circuits.items[circuit_index1.?] = null;
        }
        const circuit_index2 = points.get(connection.p2).?;
        if (circuit_index2 == null) {
            try new_circuit.put(connection.p2, {});
        } else {
            if (circuit_index1 != circuit_index2) {
                var old_circuit_iter = circuits.items[circuit_index2.?].?.keyIterator();
                while (old_circuit_iter.next()) |point| {
                    try new_circuit.put(point.*, {});
                }
                circuits.items[circuit_index2.?].?.deinit();
                circuits.items[circuit_index2.?] = null;
            }
        }
        try circuits.append(gpa, new_circuit);
        var new_circuit_iter = new_circuit.keyIterator();
        while (new_circuit_iter.next()) |point| {
            try points.put(point.*, new_index);
        }
    }

    var circuit_sizes = std.PriorityQueue(usize, void, usizeCompareFn).init(gpa, {});
    defer circuit_sizes.deinit();
    for (circuits.items) |circuit| {
        if (circuit != null) {
            try circuit_sizes.add(circuit.?.count());
        }
    }
    std.debug.print("part 01: {}\n", .{circuit_sizes.remove() * circuit_sizes.remove() * circuit_sizes.remove()});
}
fn part02() !void {
    var lines_iter = std.mem.splitScalar(u8, input, '\n');
    var points = std.AutoArrayHashMap(Point3, ?usize).init(gpa);
    defer points.deinit();

    while (lines_iter.next()) |line| {
        var dimensions_iter = std.mem.splitScalar(u8, line, ',');
        var point: [3]isize = [3]isize{ 0, 0, 0 };
        var i: usize = 0;
        while (dimensions_iter.next()) |dim| : (i += 1) {
            point[i] = try std.fmt.parseInt(isize, dim, 10);
        }
        try points.put(Point3{ .x = point[0], .y = point[1], .z = point[2] }, null);
    }

    var connections = std.PriorityQueue(Distance, void, distanceCompareFn).init(gpa, {});
    defer connections.deinit();

    for (points.keys()[0 .. points.count() - 1], 0..) |p1, i| {
        for (points.keys()[i + 1 ..]) |p2| {
            try connections.add(Distance.getDistance(p1, p2));
        }
    }

    var circuits = try std.ArrayList(?std.AutoHashMap(Point3, void)).initCapacity(gpa, points.count());
    while (true) {
        const connection = connections.remove();
        var new_circuit = std.AutoHashMap(Point3, void).init(gpa);
        const new_index = circuits.items.len;
        const circuit_index1 = points.get(connection.p1).?;
        if (circuit_index1 == null) {
            try new_circuit.put(connection.p1, {});
        } else {
            var old_circuit_iter = circuits.items[circuit_index1.?].?.keyIterator();
            while (old_circuit_iter.next()) |point| {
                try new_circuit.put(point.*, {});
            }
            circuits.items[circuit_index1.?].?.deinit();
            circuits.items[circuit_index1.?] = null;
        }
        const circuit_index2 = points.get(connection.p2).?;
        if (circuit_index2 == null) {
            try new_circuit.put(connection.p2, {});
        } else {
            if (circuit_index1 != circuit_index2) {
                var old_circuit_iter = circuits.items[circuit_index2.?].?.keyIterator();
                while (old_circuit_iter.next()) |point| {
                    try new_circuit.put(point.*, {});
                }
                circuits.items[circuit_index2.?].?.deinit();
                circuits.items[circuit_index2.?] = null;
            }
        }
        if (new_circuit.count() == points.count()) {
            std.debug.print("part 02: {}\n", .{connection.p1.x * connection.p2.x});
            break;
        }
        try circuits.append(gpa, new_circuit);
        var new_circuit_iter = new_circuit.keyIterator();
        while (new_circuit_iter.next()) |point| {
            try points.put(point.*, new_index);
        }
    }
}

pub fn day08() void {
    std.debug.print("-day08-\n", .{});
    part01() catch unreachable;
    part02() catch unreachable;
}
