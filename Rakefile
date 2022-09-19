require_relative "./cmake_utils/Rakefile_common.rb"

require 'rake/clean'
CLEAN.clear_exclude.exclude { |fn| fn.pathmap("%f").downcase == "core" }

file_base = File.expand_path(File.dirname(__FILE__)).to_s

desc "default task --> build"
task :default => :build

task :build_common, [:bits] do |t, args|
  args.with_defaults( :bits => "" )

  puts "UTILS build (osx/linux/mingw/windows)".green

  FileUtils.rm_rf   'lib'
  FileUtils.rm_rf   'lib3rd'
  FileUtils.rm_rf   'build'
  FileUtils.mkdir_p 'build'
  FileUtils.cd      'build'

  FileUtils.mkdir_p "../lib/lib"
  FileUtils.mkdir_p "../lib/bin"
  FileUtils.mkdir_p "../lib/dll"
  FileUtils.mkdir_p "../lib/include"

  puts "run CMAKE for COMMUNICATION".yellow
  if args.bits == "" then
    sh "cmake -G Ninja " + cmd_cmake_build() + ' ..'
  else
    FileUtils.mkdir_p "../lib/bin/"+args.bits
    sh "cmake -G Ninja -DBITS:VAR=#{args.bits} " + cmd_cmake_build() + ' ..'
  end
  puts "compile with CMAKE for COMMUNICATIONS".yellow
  if COMPILE_DEBUG then
    sh 'cmake --build . --config Debug --target install '+PARALLEL
  else
    sh 'cmake --build . --config Release --target install '+PARALLEL
  end
  FileUtils.cp_r './lib/dll', '../lib/' if Dir.exist?('./lib/dll')

  if not ( args.bits == "" ) then
    Dir['./lib/bin/*'].each do |f|
      FileUtils.cp f, '../lib/bin/'+args.bits+'/'+File.basename(f)
    end
  end
  Dir['./lib/lib/*'].each do |f|
    if /\_static*.*\.lib$/.match(f) then
      FileUtils.cp f, '../lib/lib/'+File.basename(f)
    else
      FileUtils.cp f, '../lib/dll/'+File.basename(f)
    end
  end

  FileUtils.cp_r './lib/include', '../lib/' if Dir.exist?('./lib/include')

  FileUtils.cd '..'
end

task :build_osx   => :build_common do end
task :build_linux => :build_common do end
task :build_mingw => :build_common do end
task :build_win do
  # check architecture
  case `where cl.exe`.chop
  when /x64\\cl\.exe/
    VS_ARCH = 'x64'
  when /amd64\\cl\.exe/
    VS_ARCH = 'x64'
  when /bin\\cl\.exe/
    VS_ARCH = 'x86'
  else
    raise RuntimeError, "Cannot determine architecture for Visual Studio".red
  end
  Rake::Task[:build_common].invoke(VS_ARCH)
end

task :clean do
  FileUtils.rm_rf 'lib'
  FileUtils.rm_rf 'lib3rd'
end

task :clean_osx   => :clean do end
task :clean_linux => :clean do end
task :clean_mingw => :clean do end
task :clean_win   => :clean do end
