MoonRabbit::Makefiles.add MoonRabbit::Makefile.new{
  path              "Makefile"
  compiler          "gcc"
  main_target       "main"
  srcs [
    "src/main.c",
    "src/sub.c"
  ]
  obj_dir           "obj"
  compile_option    "-Iinc -g -Wall -O2"
}
