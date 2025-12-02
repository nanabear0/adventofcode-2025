const std = @import("std");

const input = std.mem.trim(u8, @embedFile("inputs/day02.txt"), "\n");
var buf: [40]u8 = undefined;

fn isValidP1(num: usize) bool {
    const str = std.fmt.bufPrint(&buf, "{}", .{num}) catch unreachable;

    if (str.len % 2 != 0) return true;
    return !std.mem.eql(u8, str[0 .. str.len / 2], str[str.len / 2 ..]);
}

fn isValidP2(num: usize) bool {
    const str = std.fmt.bufPrint(&buf, "{}", .{num}) catch unreachable;

    outer: for (1..str.len / 2 + 1) |len| {
        if (str.len % len != 0) continue;

        var i: usize = 0;
        while (i < str.len - len) : (i += len) {
            if (!std.mem.eql(u8, str[i .. i + len], str[i + len .. i + len + len])) continue :outer;
        }

        return false;
    }

    return true;
}

fn doThing() !void {
    var ranges = std.mem.splitScalar(u8, input, ',');

    var p1: usize = 0;
    var p2: usize = 0;
    while (ranges.next()) |range| {
        const index = std.mem.indexOfScalar(u8, range, '-') orelse unreachable;
        const left = try std.fmt.parseInt(usize, std.mem.trimLeft(u8, range[0..index], "0"), 10);
        const right = try std.fmt.parseInt(usize, std.mem.trimLeft(u8, range[index + 1 ..], "0"), 10);

        for (left..right + 1) |value| {
            if (!isValidP1(value)) p1 += value;
            if (!isValidP2(value)) p2 += value;
        }
    }

    std.debug.print("part 01: {}\n", .{p1});
    std.debug.print("part 02: {}\n", .{p2});
}

pub fn day02() void {
    std.debug.print("-day02-\n", .{});
    doThing() catch unreachable;
}
