const esbuild = require("esbuild")
const path = require("path")
const fs = require("fs")

const jqueryGlobalPlugin = {
  name: "jquery-global",
  setup(build) {
    // jquery を外部モジュールとして扱い、window.jQuery を参照するようにする
    build.onResolve({ filter: /^jquery$/ }, () => {
      return { path: "jquery", namespace: "jquery-global" }
    })
    build.onLoad({ filter: /.*/, namespace: "jquery-global" }, () => {
      return {
        contents: "module.exports = window.jQuery",
        loader: "js",
      }
    })

    // jquery-ujs の UMD 末尾を修正
    build.onLoad({ filter: /jquery-ujs/ }, async (args) => {
      let contents = fs.readFileSync(args.path, "utf8")
      contents = contents.replace(/\}\)\(\s*jQuery\s*\)/, "})(window.jQuery)")
      return { contents, loader: "js" }
    })

    // bootstrap の UMD パターンも修正
    build.onLoad({ filter: /node_modules\/bootstrap\/js\// }, async (args) => {
      let contents = fs.readFileSync(args.path, "utf8")
      contents = contents.replace(/\}\)\(\s*jQuery\s*\)/g, "})(window.jQuery)")
      return { contents, loader: "js" }
    })
  },
}

esbuild.build({
  entryPoints: ["app/javascript/application.js"],
  bundle: true,
  sourcemap: true,
  outdir: path.join("app", "assets", "builds"),
  plugins: [jqueryGlobalPlugin],
}).catch(() => process.exit(1))
