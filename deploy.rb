require 'uri'
require 'fileutils'
require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'
require 'cgi'
require 'yaml'
require 'tmpdir'
require 'simp/metadata'

# Set Variables
currentdir = Dir.pwd
binaries_dir = "#{currentdir}/binaries"
nightly_dir = "/data/community-download/simp/ISO/nightlies"

# Move ISOs
isos = Dir.glob(File.join(binaries_dir, 'ISOs', "*.iso"))
isos.each { |iso| FileUtils.move iso, nightly_dir }

# Move Tarballs
tarballs = Dir.glob(File.join(binaries_dir, 'Tarballs', '*.tar.gz'))
tarballs.each do |tarball|
  next if tarball.include_any?(['packages', 'built_rpms'])
  FileUtils.move tarball, "#{nightly_dir}/tar_bundles"
end

# Extract built RPMs into unstable yum repo if they don't exist
rpm_tarballs = Dir.glob(File.join(binaries_dir, "*-built_rpms.tar.gz"))

rpm_tarballs.each do |tarball|
  el_version = tarball.split('.el')[1].chr
  unstable_rpm_dir = "/data/community-download/simp/yum/unstable/el/#{el_version}/x86_64"
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      system("tar -xvzf #{binaries_dir}/#{tarball} ./")
      rpms = Dir.glob(File.join(dir, '*.rpm'))
      rpms.each do |rpm|
        File.move rpm, unstable_rpm_dir unless File.exist?("#{unstable_rpm_dir}/#{rpm}")
      end
    end
  end
  # Remove tarball from binaries dir
  FileUtils.remove "#{binaries_dir}/#{tarball}"
end

# Move 3rd party package RPMs to stable yum repo unless they exist
package_tarballs = Dir.glob(File.join(binaries_dir, "*-packages.tar.gz"))

package_tarballs.each do |tarball|
  el_version = tarball.split('.el')[1].chr
  unstable_rpm_dir = "/data/community-download/simp/yum/stable/el/#{el_version}/x86_64"
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      system("tar -xvzf #{binaries_dir}/#{tarball} ./")
      rpms = Dir.glob(File.join(dir, '*.rpm'))
      rpms.each do |rpm|
        File.move rpm, unstable_rpm_dir unless File.exist?("#{unstable_rpm_dir}/#{rpm}")
      end
    end
  end
  # Remove tarball from binaries dir
  FileUtils.remove "#{binaries_dir}/#{tarball}"
end
