const std = @import("std");
const Point = @import("utils.zig").Point;

const input = std.mem.trim(u8, @embedFile("inputs/day10.txt"), "\n");
const test_input = std.mem.trim(u8, @embedFile("test/day10.txt"), "\n");

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

const Button = std.AutoHashMap(usize, void);

fn checkCombination(combination: *[]bool, target: *const []bool, buttons: *[]Button) !bool {
    var state = try gpa.alloc(bool, target.*.len);
    defer gpa.free(state);
    for (combination.*, 0..) |c, i| {
        if (c) {
            const button = buttons.*[i];
            var iter = button.keyIterator();
            while (iter.next()) |j| {
                state[j.*] ^= true;
            }
        }
    }
    for (state, target.*) |s, t| {
        if (s ^ t) return false;
    }
    return true;
}

fn generateAndTryCombination(n: usize, k: usize, start: usize, combination: *[]bool, target: *const []bool, buttons: *[]Button) !bool {
    if (k == 0) {
        return try checkCombination(combination, target, buttons);
    }

    var i = start;
    while (i <= n - k) : (i += 1) {
        combination.*[i] = true;
        if (try generateAndTryCombination(n, k - 1, i + 1, combination, target, buttons)) return true;
        combination.*[i] = false;
    }

    return false;
}

fn part01() !void {
    var lines_iter = std.mem.splitScalar(u8, input, '\n');
    var result: usize = 0;
    while (lines_iter.next()) |line| {
        var token_iter = std.mem.tokenizeScalar(u8, line, ' ');
        var target_str = token_iter.next().?;
        target_str = target_str[1 .. target_str.len - 1];
        const target = try gpa.alloc(bool, target_str.len);
        for (target_str, 0..) |c, i| {
            target[i] = c == '#';
        }
        var buttons = try std.ArrayList(Button).initCapacity(gpa, 10);
        defer buttons.clearAndFree(gpa);
        defer {
            for (buttons.items) |*button| button.deinit();
        }
        while (token_iter.next()) |token| {
            if (token_iter.peek() == null) break;
            var button_iter = std.mem.splitScalar(u8, token[1 .. token.len - 1], ',');
            var button = Button.init(gpa);
            while (button_iter.next()) |value| {
                try button.put(try std.fmt.parseInt(usize, value, 10), {});
            }
            try buttons.append(gpa, button);
        }
        const n = buttons.items.len;
        var combination = try gpa.alloc(bool, n);
        var k: usize = 1;
        while (k <= n) : (k += 1) {
            if (try generateAndTryCombination(n, k, 0, &combination, &target, &buttons.items)) break;
        }
        result += k;
    }

    std.debug.print("part 01: {}\n", .{result});
}

pub fn day10() void {
    std.debug.print("-day10-\n", .{});
    part01() catch unreachable;
    // part02() catch unreachable;
}
