require "fileutils"
require "digest/md5"

module Terraform
  module DSL
    def dep(name)
      @dependencies ||= []
      # If a dep gets required or defined twice, only run it once.
      return if @dependencies.find { |dep| dep[:name] == name }
      @dependencies.push(@current_dependency = { :name => name })
      yield
      fail_and_exit "Error: no 'met?' block defined for dep '#{name}'." unless @current_dependency[:met?]
      fail_and_exit "Error: no 'meet' block defined for dep '#{name}'." unless @current_dependency[:meet]
    end
    def met?(&block) @current_dependency[:met?] = block end
    def meet(&block) @current_dependency[:meet] = block end
    def in_path?(command) `which #{command}`.size > 0 end
    def fail_and_exit(message) puts message; exit 1 end

    # Runs a command and raises an exception if its exit status was nonzero.
    # Options:
    # - silent: if false, log the command being run and its stdout. False by default.
    def shell(command, options = {})
      silent = (options[:silent] != false)
      puts command unless silent
      output = `#{command}`
      puts output unless output.empty? || silent
      raise "#{command} had a failure exit status of #{$?.to_i}" unless $?.to_i == 0
      true
    end

    def satisfy_dependencies
      STDOUT.sync = true # Ensure that we flush logging output as we go along.
      @dependencies ||= []
      @dependencies.each do |dep|
        unless dep[:met?].call
          puts "* Dependency #{dep[:name]} is not met. Meeting it."
          dep[:meet].call
          fail_and_exit %Q("met?" for #{dep[:name]} is still false after running "meet".) unless dep[:met?].call
        end
      end
      @dependencies = []
    end

    #
    # These are very common tasks which are needed by almost everyone, and so they're bundled with this DSL.
    #

    def package_installed?(package) !!`dpkg -s #{package} 2> /dev/null | grep Status`.match(/\sinstalled/) end
    def install_package(package)
      # Specify a noninteractive frontend, so dpkg won't prompt you for info. -q is quiet; -y is "answer yes".
      shell "sudo DEBIAN_FRONTEND=noninteractive apt-get install -qy #{package}"
    end

    def ensure_packages(*packages) packages.each { |package| ensure_package(package) } end
    def ensure_package(package)
      dep "package: #{package}" do
        met? { package_installed?(package) }
        meet { install_package(package) }
      end
    end

    # Ensure an Ubuntu PPA is installed. The argument is the ppa location, in the form ppa:[USER]/[NAME]
    def ensure_ppa(ppa)
      ppa_part, location = ppa.split(":", 2)
      fail_and_exit("PPA location must be of the form ppa:[USER]/[NAME]") unless (ppa_part == "ppa") && location
      # The python-software-properties package provides the add-apt-repository convenience tool for editing
      # the list of apt's source repositories.
      ensure_package("python-software-properties")
      dep "ppa: #{location}" do
        met? { !`apt-cache policy 2> /dev/null | grep ppa.launchpad.net/#{location}/`.empty? }
        meet do
          shell "sudo add-apt-repository #{ppa}"#, :silent => true
          shell "sudo apt-get update"#, :silent => true
        end
      end
    end

    def gem_installed?(gem, ruby_version = nil)
      prefix = "env RBENV_VERSION=#{ruby_version} " unless ruby_version.nil?
      `#{prefix}gem list '#{gem}'`.include?(gem)
    end

    def ensure_gem(gem, ruby_version = nil)
      prefix = "env RBENV_VERSION=#{ruby_version} " unless ruby_version.nil?
      dep "gem: #{gem}" do
        met? { gem_installed?(gem, ruby_version) }
        meet { shell "#{prefix}gem install #{gem} --no-ri --no-rdoc" }
      end
    end

    # Ensures the file at dest_path is exactly the same as the one in source_path.
    # Invokes the given block if the file is changed. Use this block to restart a service, for instance.
    def ensure_file(source_path, dest_path, &on_change)
      dep "file: #{dest_path}" do
        met? do
          raise "This file does not exist: #{source_path}" unless File.exists?(source_path)
          File.exists?(dest_path) && (Digest::MD5.file(source_path) == Digest::MD5.file(dest_path))
        end
        meet do
          FileUtils.cp(source_path, dest_path)
          on_change.call if on_change
        end
      end
    end

    # A task which must be run once to be 'met'. For instance, this might be the DB migration script.
    def ensure_run_once(name, &block)
      dep "run task once: #{name}" do
        has_run_once = false
        met? { has_run_once }
        meet do
          yield
          has_run_once = true
        end
      end
    end

    def ensure_rbenv
      ensure_package "git-core"
      dep "rbenv" do
        met? { in_path?("rbenv") }
        meet do
          # These instructions are from https://github.com/fesplugas/rbenv-installer
          shell "curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
          # We need to run rbenv init after install, which adjusts the path. If exec is causing us problems
          # down the road, we can perhaps simulate running rbenv init without execing.
          unless ARGV.include?("--forked-after-rbenv") # To guard against an infinite forking loop.
            exec "bash -c 'source ~/.bashrc; #{$0} --forked-after-rbenv'" # $0 is the current process's name.
          end
        end
      end
    end

    # ruby_version is a rbenv ruby version string like "1.9.2-p290".
    def ensure_rbenv_ruby(ruby_version)
      ensure_rbenv
      ensure_packages "curl", "build-essential", "libxslt1-dev", "libxml2-dev", "libssl-dev"

      dep "rbenv ruby: #{ruby_version}" do
        met? { `bash -lc 'which ruby'`.include?("rbenv") && `rbenv versions`.include?(ruby_version) }
        meet do
          puts "Compiling Ruby will take a few minutes."
          shell "rbenv install #{ruby_version}"
          shell "rbenv rehash"
        end
      end
    end

    def user_exists?(username) !!`id #{username} 2> /dev/null`.match(/^uid=\d+/) end
    def create_user(username) shell "useradd -m #{username}" end

    def ensure_user(username)
      dep "user: #{username}" do
        met? { user_exists?(username) }
        meet { create_user(username) }
      end
    end
  end
end
