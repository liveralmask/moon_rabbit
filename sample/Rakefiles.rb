require "./Makefiles"

task :default do
	sh "rake -T -f #{__FILE__}"
end

desc "Debug Build"
task :debug do
	Makefiles.each{|makefile|
		sh "make COMPILE_OPTIONS='-g' -f #{makefile.file_path}"
	}
end

desc "Release Build"
task :release do
	Makefiles.each{|makefile|
		sh "make COMPILE_OPTIONS='-O2' -f #{makefile.file_path}"
	}
end

desc "Clean"
task :clean do
	Makefiles.each{|makefile|
		sh "make clean -f #{makefile.file_path}"
	}
end

desc "Output Makefiles"
task :output do
	Makefiles.each{|makefile|
		makefile.output
	}
end
