require "terraform/version"
require "fileutils"

module Terraform
  # Writes the terraform_dsl.rb to the given file or directory.
  def self.write_dsl_file(path)
    path = File.join(path, "terraform_dsl.rb") if File.directory?(path)
    FileUtils.cp(File.expand_path(File.join(File.dirname(__FILE__), "terraform/dsl.rb")), path)
  end

  @@plugin_files = Set.new [File.expand_path(File.join(File.dirname(__FILE__), "terraform/dsl.rb"))]
  def self.register_plugin(path) @@plugin_files.add(path) end

  def self.write_terraform_files(path)
    FileUtils.mkdir_p(path)
    @@plugin_files.each do |plugin|
      FileUtils.cp(File.expand_path(plugin), File.join(path, File.basename(plugin)))
    end
  end
end
