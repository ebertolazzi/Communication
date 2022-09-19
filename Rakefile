%w(colorize rake fileutils).each do |gem|
  begin
    require gem
  rescue LoadError
    warn "Install the #{gem} gem:\n $ (sudo) gem install #{gem}".magenta
    exit 1
  end
end

require 'rake/clean'

CLEAN.clear_exclude.exclude { |fn| fn.pathmap("%f").downcase == "core" }

case RUBY_PLATFORM
when /darwin/
  OS = :mac
when /linux/
  OS = :linux
when /cygwin|mswin|mingw|bccwin|wince|emx/
  OS = :win
when /msys/
  OS = :win
end

require_relative "./Rakefile_common.rb"

file_base = File.expand_path(File.dirname(__FILE__)).to_s

cmd_cmake_build = ""
if COMPILE_EXECUTABLE then
  cmd_cmake_build += ' -DEB_ENABLE_TESTS:VAR=ON '
else
  cmd_cmake_build += ' -DEB_ENABLE_TESTS:VAR=OFF '
end
if COMPILE_DYNAMIC then
  cmd_cmake_build += ' -DEB_BUILD_SHARED:VAR=ON '
else
  cmd_cmake_build += ' -DEB_BUILD_SHARED:VAR=OFF '
end
if COMPILE_DEBUG then
  cmd_cmake_build += ' -DCMAKE_BUILD_TYPE:VAR=Debug --loglevel=STATUS '
else
  cmd_cmake_build += ' -DCMAKE_BUILD_TYPE:VAR=Release --loglevel=STATUS '
end

desc "default task --> build"
task :default => :build

desc "build COMMUNICATION"
task :build do
  case OS
  when :mac
    puts "COMMUNICATION build (osx)".green
    Rake::Task[:build_osx].invoke
  when :linux
    puts "COMMUNICATION build (linux)".green
    Rake::Task[:build_linux].invoke
  when :win
    puts "COMMUNICATION build (windows)".green
    Rake::Task[:build_win].invoke
  end
end

desc "clean COMMUNICATION"
task :clean do
  case OS
  when :mac
    puts "COMMUNICATION clean (osx)".green
    Rake::Task[:clean_osx].invoke
  when :linux
    puts "COMMUNICATION clean (linux)".green
    Rake::Task[:clean_linux].invoke
  when :win
    puts "COMMUNICATION clean (windows)".green
    Rake::Task[:clean_win].invoke
  end
end

#task :mkl, [:year, :bits] do |t, args|
#  args.with_defaults(:year => "2017", :bits => "x64" )
#  sh "'C:/Program Files (x86)/IntelSWTools/compilers_and_libraries/windows/bin/compilervars.bat' -arch #{args.bits} vs#{args.year}shell"
#end

TESTS = [
  "testBiarc",
  "testDistance",
  "testG2",
  "testG2plot",
  "testG2stat",
  "testG2stat2arc",
  "testG2statCLC",
  "testIntersect",
  "testPolyline",
  "testTriangle2D"
]

"run tests on linux/osx"
task :run do
  TESTS.each do |cmd|
    sh "./bin/#{cmd}"
  end
end

desc "run tests (Release) on windows"
task :run_win do
  TESTS.each do |cmd|
    sh "bin\\Release\\#{cmd}.exe"
  end
end

desc "run tests (Debug) on windows"
task :run_win_debug do
  TESTS.each do |cmd|
    sh "bin\\Debug\\#{cmd}.exe"
  end
end

desc "compile for Visual Studio"
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

  FileUtils.rm_rf 'lib'
  FileUtils.rm_rf 'lib3rd'

  FileUtils.rm_rf   "build"
  FileUtils.mkdir_p "build"
  FileUtils.cd      "build"

  cmake_cmd =   sh "cmake -G Ninja -DBITS:VAR=#{VS_ARCH} "
  if COMPILE_EXECUTABLE then
    cmake_cmd += ' -DBUILD_EXECUTABLE:VAR=true '
  else
    cmake_cmd += ' -DBUILD_EXECUTABLE:VAR=false '
  end
  if COMPILE_DYNAMIC then
    cmake_cmd += ' -DBUILD_SHARED:VAR=true '
  else
    cmake_cmd += ' -DBUILD_SHARED:VAR=false '
  end

  FileUtils.mkdir_p "../lib/lib"
  FileUtils.mkdir_p "../lib/bin"
  FileUtils.mkdir_p "../lib/bin/"+VS_ARCH
  FileUtils.mkdir_p "../lib/dll"
  FileUtils.mkdir_p "../lib/include"

  if COMPILE_DEBUG then
    sh cmake_cmd + ' -DCMAKE_BUILD_TYPE:VAR=Debug --loglevel=STATUS ..'
    sh 'cmake --build . --config Debug --target install '+PARALLEL
    FileUtils.cp_r './lib/dll', '../lib/' if Dir.exist?('./lib/dll')
  else
    sh cmake_cmd + ' -DCMAKE_BUILD_TYPE:VAR=Release --loglevel=STATUS ..'
    sh 'cmake  --build . --config Release --target install '+PARALLEL
    FileUtils.cp_r './lib/dll', '../lib/' if Dir.exist?('./lib/dll')
  end

  Dir['./lib/bin/*'].each do |f|
    FileUtils.cp f, '../lib/bin/'+args.bits+'/'+File.basename(f)
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

desc 'compile for OSX'
task :build_osx do
  FileUtils.rm_rf 'lib'
  FileUtils.rm_rf 'lib3rd'

  dir = "build"

  FileUtils.rm_rf   dir
  FileUtils.mkdir_p dir
  FileUtils.cd      dir

  cmake_cmd = 'cmake '

  if COMPILE_EXECUTABLE then
    cmake_cmd += ' -DBUILD_EXECUTABLE:VAR=true '
  else
    cmake_cmd += ' -DBUILD_EXECUTABLE:VAR=false '
  end
  if COMPILE_DYNAMIC then
    cmake_cmd += ' -DBUILD_SHARED:VAR=true '
  else
    cmake_cmd += ' -DBUILD_SHARED:VAR=false '
  end

  if COMPILE_DEBUG then
    sh cmake_cmd + ' -DCMAKE_BUILD_TYPE:VAR=Debug --loglevel=STATUS ..'
    sh 'cmake --build . --config Debug --target install '+PARALLEL
  else
    sh cmake_cmd + ' -DCMAKE_BUILD_TYPE:VAR=Release --loglevel=STATUS ..'
    sh 'cmake --build . --config Release --target install '+PARALLEL
  end
  FileUtils.cd '..'
end

desc 'compile for LINUX'
task :build_linux => [ :build_osx ] do
end

desc "clean for OSX"
task :clean_osx do
  FileUtils.rm_rf 'lib'
  FileUtils.rm_rf 'lib3rd'
end

desc "clean for LINUX"
task :clean_linux do
  FileUtils.rm_rf 'lib'
  FileUtils.rm_rf 'lib3rd'
end

desc "clean for WINDOWS"
task :clean_win do
  FileUtils.rm_rf 'lib'
  FileUtils.rm_rf 'lib3rd'
end
