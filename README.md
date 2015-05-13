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
        compiler "gcc"
        main_target "main"
        srcs [
            "src/main.c",
            "src/sub.c"
        ]
        obj_dir "obj"
        compile_option "-Iinc -g -Wall -O2"
    }
    
    Makefiles.add Makefile.new( "Makefile.process" ){
        compiler "gcc"
        main_target "process"
        srcs [
            "process.c"
        ]
        obj_dir "obj"
        compile_option "-g -Wall -O2"
    }

[Rakefile]  

    require "moon_rabbit"
    include MoonRabbit
    
    def make( option )
        Makefiles.file_paths.each{|file_path|
            sh "make #{option} -f #{file_path}"
        }
    end
    
    task :default => [ :all ]
    
    desc "All Build"
    task :all do |t, args|
        require "./Makefiles"
        
        make Options.to_s
    end
    
    desc "Clean Build"
    task :clean do |t, args|
        require "./Makefiles"
        
        make "clean"
    end
    
    desc "Remove Makefiles"
    task :rm do |t, args|
        require "./Makefiles"
        
        Makefiles.file_paths.each{|file_path|
            sh "rm -f #{file_path}"
        }
    end
    
    desc "Output Makefiles"
    task :output do |t, args|
        require "./Makefiles"
        
        Makefiles.each{|makefile|
            makefile.output
        }
    end

[bash]  

    rake output all
    ./main
    
    ruby watch.rb &

## Contributing

1. Fork it ( http://github.com/<my-github-username>/moon_rabbit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
