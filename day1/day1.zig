const std = @import("std");

pub fn main() !void {

    // General purpose allocator for reading lines later
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var start: u32 = 50;
    var result: u32 = 0;

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    // zig 0.15 requires a buffer when using reader() for buffered I/O
    var read_buffer: [1024]u8 = undefined;
    var fr = file.reader(&read_buffer);
    var reader = &fr.interface;

    // Use a writer.allocating and pass our gpa into it, this allows us to dynamically store data as we read the file.
    var line = std.Io.Writer.Allocating.init(alloc);
    defer line.deinit();

    // Looping each line, and processing for the puzzle.
    while (true) {
        _ = reader.streamDelimiter(&line.writer, '\n') catch |err| {
            if (err == error.EndOfStream) break else return err;
        };

        _ = reader.toss(1);
        // Extract Left or Right
        const left_or_right = line.written()[0];
        std.debug.print("{s}\n", .{line.written()});

        // Convert the number to a proper int from string.
        const rotations = try std.fmt.parseInt(i32, line.written()[1..], 10);
        //std.debug.print("{any}\n", .{rotations});

        // I'm sure there is a better and more clever way of doing this, but this worked in my head.
        var i: u32 = 0;
        if (left_or_right == 'L') {
            i = 0;
            while (i < rotations) {
                if (start == 0) {
                    if (i != 0) {
                        std.debug.print("Start is 0, i is {d}\n", .{i});
                        result += 1;
                    }
                    i += 1;
                    start = 99;
                } else {
                    i += 1;
                    start -= 1;
                }
            }
            std.debug.print("Start after a L rotation is {d}\n", .{start});
            if (start == 0) {
                result += 1;
            }
        } else if (left_or_right == 'R') {
            i = 0;
            while (i < rotations) {
                if (start == 99) {
                    i += 1;

                    if (i != 0 and i != rotations) {
                        std.debug.print("Start is 0, i is {d}\n", .{i});
                        result += 1;
                    }
                    start = 0;
                } else {
                    i += 1;
                    start += 1;
                }
            }
            std.debug.print("Start after a R rotation is {d}\n", .{start});
            if (start == 0) {
                result += 1;
            }
        }

        line.clearRetainingCapacity();
    }
    std.debug.print("Result is: {d}\n", .{result});
}
