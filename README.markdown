Terraform is a small goal-oriented DSL for setting up a machine, similar in purpose to Chef and Puppet. Its
design is inspired by Babushka, but it's simpler and tailored specifically for provisioning a machine for a
webapp.

Usage
-----

    require "terraform_dsl"
    include Terraform::Dsl
    dep "my library" do
      met? { (check if your dependency is met) }
      meet { (install your dependency) }
    end

A more detailed README is coming shortly.

Contribute
----------
When editing this gem, to test your changes, you can load your local copy of the gem in your project by using
this in your Gemfile:

gem "terraform", :path => "~/p/terraform"

Credits
-------
Dmac -- thanks for the name!
