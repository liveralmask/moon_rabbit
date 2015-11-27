require "moon_rabbit"
include MoonRabbit

Makefile.new{
  path           "Makefile"
  compiler       "gcc"
  main_target    "main"
  src            "main.c"
  compile_option "-g -Wall -O2"

  # Makefile を生成
  output
}
