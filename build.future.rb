require 'uri'
require 'fileutils'
require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'
require 'cgi'
require 'yaml'
require 'tmpdir'
require 'simp/metadata'

$simp_metadata_debug_level = 'debug2'

# Grab component and set variables
edition = ENV["EDITION"]
version = ENV["VERSION"]
currentdir = Dir.pwd
el_version = ENV["EL_VERSION"]
binaries_dir = ENV["BINARIESDIR"]
platform = ENV["PLATFORM"]
iso_cache = "#{currentdir}/Base_ISOs"
distribution = 'CentOS'

# Copy ISOs for builds
FileUtils.makedirs("#{iso_cache}")

isos = `simp-metadata release isos #{platform} -v #{version}`

# Copy Base ISOs to build directory
isos.each do |iso|
  FileUtils.copy "/data/community-download/simp/ISO/base_isos/#{iso}", "#{iso_cache}"
end

heredoc = <<-HERDOC
simp-metadata
build iso
-v #{version}
--distribution #{distribution}
--iso_cache #{iso_cache}
--preserve
HERDOC

build_command = heredoc.tr("\n", ' ')

Simp::Metadata.run(build_command)

# Move files to binaries dir

# Create binaries folders
FileUtils.makedirs("#{binaries_dir}/{ISO,Tarballs,RPMs}")

# Move platform specific information
platforms = `simp-metadata release platforms -v #{version}`

platforms.each do |dir|
  Dir.chdir("#{currentdir}/#{dir}") do
    # Copy ISO
    iso_file = Dir.glob(File.join("**", 'SIMP', "*.iso"))
    File.move iso_file, "#{binaries_dir}/ISO"

    # Copy Tarballs
    tar_files = Dir.glob(File.join("**", "SIMP", "*.tar.gz"))
    tar_files.each {|file| File.move file, "#{binaries_dir}/Tarballs"}
  end

  # Purge dir
  FileUtils.rm_r dir
end

FileUtils.rm_r iso_cache

# vim: set expandtab ts=2 sw=2:
