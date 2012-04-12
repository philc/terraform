Terraform
---------

Terraform is a small goal-oriented Ruby DSL for setting up a machine, similar in purpose to Chef and Puppet,
but without the complexity. It's tailored for the kinds of tasks needed for deploying web apps and is designed
to be refreshingly easy to understand and debug. You can read through the entire Terraform library in two
minutes and know precisely what it will and won't do for you. Its design is inspired by Babushka.

Usage
-----
This is the basic structure of a system provisioning script written using Terraform:

    require "terraform_dsl"
    include Terraform::Dsl

    dep "pygments" do
      met? { in_path? "pygmentize" }         # Check if your dependency is met.
      meet { shell "pip install pygments" }  # Install your dependency.
    end

    ...

    satisfy_dependencies()

The Terraform DSL provides these functions which are commonly used when provisioning systems to run web services:

<table>
  <tr>
    <td>shell(command)</td>
    <td>Executes a shell command.</td>
  </tr>
  <tr>
    <td>in_path?(command)</td>
    <td>True if the command is in the current path.</td>
  </tr>
  <tr>
    <td>package_installed?(package_name)</td>
    <td>True if an apt-get package is installed.</td>
  </tr>
  <tr>
    <td>ensure_packages(*package_names)</td>
    <td>Ensures the given packages are installed via apt-get.</td>
  </tr>
  <tr>
    <td>ensure_ppa(ppa_url)</td>
    <td>Ensures the given PPA (used on Ubuntu) is installed. "ppa_url" is of the form "ppa:user/name".</td>
  </tr>
  <tr>
    <td>gem_installed?(name)</td>
    <td>True if the given Ruby gem is installed.</td>
  </tr>
  <tr>
    <td>ensure_gem(name)</td>
    <td>Ensures the given Ruby gem is installed.</td>
  </tr>
  <tr>
    <td>ensure_rbenv()</td>
    <td>Ensures rbenv is installed.</td>
  </tr>
  <tr>
    <td>ensure_rbenv_ruby(ruby_version)</td>
    <td>Ensures the given version of Ruby is installed. `ruby_version` is an rbenv Ruby version string like
        "1.9.2.-p290".</td>
  </tr>
  <tr>
    <td>ensure_run_once(dependency_name, block)</td>
    <td>Runs the given block once. Use for tasks that you're too lazy to write a proper `met?` block for, like running database migrations.</td>
  </tr>
  <tr>
    <td>ensure_file(source_path, dest_path, on_change)</td>
    <td>Ensures the file at dest_path is the exact same as the file at source_path. Use this for copying
        configuration files (e.g. nginx.conf) to their proper locations.</td>
  </tr>
  <tr>
    <td>fail_and_exit(message)</td>
    <td>Use when your meet() block encounters an error and cannot satisfy a dependency.</td>
  </tr>
</table>

For further details, see [the source](https://github.com/philc/terraform/blob/master/lib/terraform/dsl.rb).
It's a short, well-documented file and there's no magic.

Installation
------------
1. Install the Terraform gem on your local machine (the machine you're deploying from): `gem install
terraform`

2. Write your system provisioning script using the Terraform DSL.

3. Copy your system provisioning script and the Terraform library (which is a single file) to your remote
machine and run it. Do this as part of your deploy script.

You can use the Terraform gem to write the Terraform library out to a single file as part of your deploy
script, prior to copying it over to your remote machine:

    require "terraform"
    Terraform.write_dsl_file("/tmp/staging/my_app/terraform_dsl.rb")

Terraform is designed to be run on a barebones machine with little preinstalled software. The only requirement
is that some version (any version) of Ruby is installed on the machine you're provisioning.

Examples
--------
See the [Terraform library itself](https://github.com/philc/terraform/blob/master/lib/terraform/dsl.rb), which
makes use of the DSL quite a bit.

[Barkeep](https://github.com/ooyala/barkeep) is a code review system which uses Terraform for provisioning the
machines it gets deployed to. You can see its system provisioning script written using Terraform
[here](https://github.com/ooyala/barkeep/blob/master/script/system_setup.rb), and its Fezzik deploy script
[here](https://github.com/ooyala/barkeep/blob/master/config/tasks/deploy.rake).

Contribute
----------
When developing this gem you can quickly preview and test your changes by loading your local copy of the gem
in your project's Gemfile:

    gem "terraform", :path => "~/path/to/terraform_checkout"

Credits
-------
* Daniel MacDougall ([dmacdougall](https://github.com/dmacdougall)) -- thanks for the name.
* Caleb Spare ([cespare](https://github.com/cespare))
