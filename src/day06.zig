const std = @import("std");

const input = std.mem.trim(u8, @embedFile("inputs/day06.txt"), "\n");

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn part01() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');

    var operations = std.ArrayList(std.ArrayList(usize)).init(gpa);
    defer operations.deinit();
    defer {
        for (operations.items) |item| {
            item.deinit();
        }
    }
    var result: usize = 0;
    while (lines.next()) |line| {
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        var i: usize = 0;
        while (tokens.next()) |token| : (i += 1) {
            if (lines.peek() == null) {
                var acc: usize = if (token[0] == '*') 1 else 0;
                for (operations.items[i].items) |num| {
                    acc = if (token[0] == '*') acc * num else acc + num;
                }
                result += acc;
            } else {
                if (operations.items.len <= i) try operations.append(std.ArrayList(usize).init(gpa));
                try operations.items[i].append(try std.fmt.parseInt(usize, token, 10));
            }
        }
    }

    std.debug.print("part 01: {}\n", .{result});
}

fn part02() !void {
    var linesIter = std.mem.splitScalar(u8, input, '\n');

    var lines = std.ArrayList([]const u8).init(gpa);
    defer lines.deinit();
    while (linesIter.next()) |line| {
        try lines.append(line);
    }

    var operatorIndexes = std.ArrayList(usize).init(gpa);
    defer operatorIndexes.deinit();
    for (lines.getLast(), 0..) |c, i| {
        if (c == '*' or c == '+') {
            try operatorIndexes.append(i);
        }
    }
    try operatorIndexes.append(lines.getLast().len + 1);

    var result: usize = 0;
    var windowIter = std.mem.window(usize, operatorIndexes.items, 2, 1);
    while (windowIter.next()) |window| {
        const start = window[0];
        const end = window[1] - 1;
        const operator = lines.getLast()[start];
        var acc: usize = if (operator == '*') 1 else 0;
        for (start..end) |i| {
            var num: usize = 0;
            for (lines.items[0 .. lines.items.len - 1]) |line| {
                if (line[i] == ' ') continue;

                num = num * 10 + (line[i] - '0');
            }

            acc = if (operator == '*') acc * num else acc + num;
        }
        result += acc;
    }

    std.debug.print("part 02: {}\n", .{result});
}

pub fn day06() void {
    std.debug.print("-day06-\n", .{});
    part01() catch unreachable;
    part02() catch unreachable;
}
