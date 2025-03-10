# Used by "mix format"
[
  plugins: [Spark.Formatter, Phoenix.LiveView.HTMLFormatter],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
  heex_line_length: 200,
  import_deps: [:ash_postgres, :ash, :assert_eventually]
]
