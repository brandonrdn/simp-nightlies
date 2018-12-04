require 'uri'
require 'fileutils'
require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'
require 'cgi'
require 'yaml'
require 'tmpdir'

$simp_metadata_debug_level = 'debug2'

# Grab component and set variables
edition = ENV["EDITION"]
version = ENV["VERSION"]
currentdir = Dir.pwd
rubygem_dir = ENV["RUBYGEM_DIR"]
el_version = ENV["EL_VERSION"]
binaries_dir = ENV["BINARIESDIR"]
platform = ENV["PLATFORM"]
iso_cache = "#{rubygem_dir}/Base_ISOs"
distribution = 'CentOS'

# Copy ISOs for builds
FileUtils.makedirs("#{iso_cache}")

Dir.chdir(rubygem_dir) do
  `git checkout iso_build_command`
  `bundle install`

  isos = `bundle exec ruby -I lib/ exe/simp-metadata release -v #{version} -w simp-metadata,https://github.com/brandonrdn/simp-metadata isos #{platform}`.split("\n")

# Copy Base ISOs to build directory
  isos.each do |iso|
    next unless iso.include?(distribution)
    puts "=== Copying #{iso} ==="
    FileUtils.copy "/data/community-download/simp/ISO/base_isos/#{iso}", "#{iso_cache}" if File.exist?("/data/community-download/simp/ISO/base_isos/#{iso}")
  end

  heredoc = <<-HERDOC
bundle exec ruby -I lib/
exe/simp-metadata
build iso
-v #{version}
--distribution #{distribution}
--iso_cache #{iso_cache}
--preserve
-w simp-metadata,https://github.com/brandonrdn/simp-metadata
  HERDOC

  build_command = heredoc.tr("\n", ' ')

  system("#{build_command}")

# Move files to binaries dir

# Create binaries folders
 ['ISO','Tarballs','RPMs'].each { |dir| FileUtils.makedirs("#{binaries_dir}/#{dir}") }

# Move platform specific information
  platforms = `bundle exec ruby -I lib/ exe/simp-metadata release -v #{version} -w simp-metadata,https://github.com/brandonrdn/simp-metadata platforms`.split("\n")

  platforms.each do |dir|
    puts "DIR = #{dir}"
    next unless dir.include?(distribution)
    puts "AFTER NEXT"
    if File.exist?("#{currentdir}/#{dir}")
      Dir.chdir("#{currentdir}/#{dir}") do
        # Copy ISO
        iso_file = Dir.glob(File.join("**", 'SIMP', "*.iso"))
        File.move iso_file, "#{binaries_dir}/ISO"

        # Copy Overlay Tarball
        tar_files = Dir.glob(File.join("**", "SIMP", "*.tar.gz"))
        tar_files.each {|file| File.move file, "#{binaries_dir}/Tarballs"}
      end
      # Purge dir
      puts "REMOVING DIR #{dir}"
      FileUtils.rm_r dir
    end
  end
# Purge ISOS
  FileUtils.rm_r iso_cache
end
# vim: set expandtab ts=2 sw=2:
