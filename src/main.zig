const std = @import("std");
const assets = @import("assets");

// kv pair type used to fill ComptimeStringMap
const EmbeddedAsset = struct {
    []const u8 = undefined,
    []const u8 = undefined,
};

// declare a ComptimeStringMap and fill it with our filenames and data
const embeddedFilesMap = std.ComptimeStringMap([]const u8, genMap());

fn genMap() [assets.files.len]EmbeddedAsset {
    var embassets: [assets.files.len]EmbeddedAsset = .{} ** assets.files.len;
    comptime var i = 0;
    inline for (assets.files) |file| {
        embassets[i][0] = file;
        embassets[i][1] = @embedFile("assets/" ++ file);
        i += 1;
    }
    return embassets;
}

pub fn main() !void {
    for (assets.files) |filename| {
        const data = embeddedFilesMap.get(filename).?;
        std.debug.print("'{s}':{s}\n", .{filename, data});
    }

}

