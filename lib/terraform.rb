require "terraform/version"
require "fileutils"

module Terraform
  # Writes the terraform_dsl.rb to the given file or directory.
  def self.write_dsl_file(path)
    path = File.join(path, "terraform_dsl.rb") if File.directory?(path)
    FileUtils.cp(File.expand_path(File.join(File.dirname(__FILE__), "terraform/terraform_dsl.rb")), path)
  end
end
