def file_paths
  ENV.key?( "FILE_PATHS" ) ? ENV[ "FILE_PATHS" ].split( /\s+/ ) : MoonRabbit::Makefiles.file_paths
end

desc "Clean"
task :clean do |task, args|
  file_paths.each{|file_path|
    sh "make clean -f #{file_path}"
  }
end

desc "Build"
task :build do |task, args|
  file_paths.each{|file_path|
    sh "make #{MoonRabbit::Options} -f #{file_path}"
  }
end

desc "Remove Makefiles"
task :remove do |task, args|
  file_paths.each{|file_path|
    sh "rm -f #{file_path}"
  }
end

desc "Output Makefiles"
task :output do |task, args|
  MoonRabbit::Makefiles.each{|makefile|
    makefile.output
  }
end

desc "Show Variables"
task :show do |task, args|
  puts "[file_paths] #{file_paths.join( ' ' )}"
  puts "[options] #{MoonRabbit::Options}"
end
