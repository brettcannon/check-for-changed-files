// Technically returns `promise<unit>`, but esbuild doesn't support that for
// CJS output which is what's used for Node.
@module("./Main.res.mjs") external main: unit => unit = "main"

main()
