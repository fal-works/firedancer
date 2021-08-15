import fs from "fs";
import esbuild from "esbuild";

void fs.promises
  .readFile("demo/pre-publish/license-comment.js", { encoding: "utf-8" })
  .then((banner) =>
    esbuild.buildSync({
      entryPoints: ["out/main.js"],
      banner: { js: banner },
      minify: true,
      outfile: "web/main.min.js",
    })
  );
