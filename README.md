# MoonRabbit

Briefly build & process monitoring scripts.

## Installation

Add this line to your application's Gemfile:

    gem 'moon_rabbit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moon_rabbit

## Usage

[Makefiles.rb]
    require "moon_rabbit"
    include MoonRabbit
    
    Makefiles.add Makefile.new( "Makefile" ){
        compile_options = {
            :tool            => "gcc",
            :target            => "main",
            :srcs            => [
                "src/main.c",
                "src/sub.c"
            ],
            :obj_dir        => "obj",
            :inc_dirs        => [ "inc" ],
            :options        => [ "-Wall" ]
        }
        compile( compile_options )
    }

[Rakefile]
    require "./Makefiles"
    
    def make( option )
        Makefiles.file_paths.each{|file_path|
            sh "make #{option} -f #{file_path}"
        }
    end
    
    task :default => [ :output ]
    
    desc "Debug Build"
    task :debug do
        compile_options = "-g"
        make "COMPILE_OPTIONS='#{compile_options}'"
    end
    
    desc "Release Build"
    task :release do
        compile_options = "-O2"
        make "COMPILE_OPTIONS='#{compile_options}'"
    end
    
    desc "Clean Build"
    task :clean do
        make "clean"
    end
    
    desc "Remove Makefiles"
    task :rm do
        Makefiles.file_paths.each{|file_path|
            sh "rm -f #{file_path}"
        }
    end
    
    desc "Output Makefiles"
    task :output do
        Makefiles.each{|makefile|
            makefile.output
        }
    end

[bash]
rake output clean debug
./main

## Contributing

1. Fork it ( http://github.com/<my-github-username>/moon_rabbit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
