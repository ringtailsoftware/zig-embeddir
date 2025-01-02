const std = @import("std");
const assets = @import("assets");

// kv pair type used to fill ComptimeStringMap
const EmbeddedAsset = struct {
    []const u8,
    []const u8,
};

// declare a StaticStringMap and fill it with our filenames and data
const embeddedFilesMap = std.StaticStringMap([]const u8).initComptime(genMap());

fn genMap() [assets.files.len]EmbeddedAsset {
    var embassets: [assets.files.len]EmbeddedAsset = undefined;
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

