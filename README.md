# embeddir

An example of using the zig build system to aid in embeddeding multiple files in an executable.

Toby Jaffey, https://mastodon.me.uk/@tobyjaffey

Zig has `@embedFile` (https://ziglang.org/documentation/master/#embedFile) which embeds the contents of a file in the executable at compile time. In some situations, it's useful to embed all files from a directory without hardcoding their names into the source code.

# How does it work?

In `build.zig`, we add a custom function `addAssetsOption()`. This opens the `assets` directory, lists files and passes the list to the main program in a module called `assets` in a field called `files`.

    ...
        options.addOption([]const []const u8, "files", files.items);
        exe.step.dependOn(&options.step);

        const assets = b.createModule(.{
            .source_file = options.getSource(),
            .dependencies = &.{},
        });
        exe.addModule("assets", assets);
    ...

In `src/main`, we build a `ComptimeStringMap` using `assets.files` as the keys and the result of `@embedFile()` on each key as the value.

At runtime, the data can then be accessed by filename using:

    const data = embeddedFilesMap.get(filename).?;

The list of files can be found in `assets.files`



