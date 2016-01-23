require 'yaml'
require_relative '../lib/openapi/version'

namespace :version do
  def load_conf
    $current_version = OpenAPI::VERSION
    $versionfile = "lib/openapi/version.rb"
  end

  def write_conf(version)
    f = File.new($versionfile, 'rb')
    r = f.read
    f.close
    r = r.gsub("VERSION = '#{$current_version}'", "VERSION = '#{version}'")
    File.open($versionfile, 'wb') do |f|
      f.write r
    end
  end

  def ask(version, mode='Release')
    STDOUT.puts "Bump to version: v#{version}, Are you sure? (y/n)"
    input = STDIN.gets.strip
    if input == 'y'
      write_conf(version)
      STDOUT.puts "#{$versionfile} updated"
      STDOUT.puts "git commit Changelog #{$versionfile} -m '#{mode}: #{version}' && git tag #{version}"
    else
      STDOUT.puts "Nothing done, Ciao"
    end
  end

  desc "Show current version"
  task :current do
    load_conf()
    STDOUT.puts "current version: v#{$current_version}"
  end

  namespace :bump do
    desc "Create release candidate version"
    task :rc, [:version] do |t, args|
      args.with_defaults(version: nil)
      load_conf()
      sp = $current_version.split("-RC+")
      if sp.size == 1
        version = sp[0] + "-RC+1"
      else
        sp[1] = sp[1].to_i + 1
        version = sp.join("-RC+")
      end
      ask(version,  "Release Candidate")
    end

    task :dev, [:version] do |t, args|
      args.with_defaults(version: nil)
      load_conf()
      sp = $current_version.split("-DEV+")
      if sp.size == 1
        version = sp[0] + "-DEV+1"
      else
        sp[1] = sp[1].to_i + 1
        version = sp.join("-DEV+")
      end
      ask(version,  'Development')
    end

    desc "Create release version"
    task :release, [:version] do |t, args|
      args.with_defaults(version: nil)
      load_conf()
      sp = $current_version.split("-RC+")
      ask(sp[0],  'Release')
    end

    desc "Bump patch"
    task :patch, [:version] do |t, args|
      args.with_defaults(version: nil)
      load_conf()
      sp = $current_version.split(".")
      sp[2] = sp[2].to_i + 1
      ask(sp.join("."),  'Release')
    end

    desc "Bump minor"
    task :minor, [:version]  do |t, args|
      args.with_defaults(version: nil)
      load_conf()
      sp = $current_version.split(".")
      sp[2] = 0
      sp[1] = sp[1].to_i + 1
      ask(sp.join("."), "Release")
    end
  end
end
