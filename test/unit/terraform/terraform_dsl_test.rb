require File.expand_path(File.join(File.dirname(__FILE__), "../../test_helper.rb"))
require "terraform/terraform_dsl"

class DslTest < Scope::TestCase
  include TerraformDsl

  class ProcessExit < StandardError; end

  # Methods to mock for met? and meet blocks
  def do_met() end
  def do_meet() end

  setup do
    stub(self).fail_and_exit(anything) { raise ProcessExit }
  end

  context "dep declarations" do
    should "fail if there is no met? or meet given" do
      assert_raises(ProcessExit) do
        dep("no met?") { meet {} }
      end
      assert_raises(ProcessExit) do
        dep("no meet") { met? {} }
      end
    end

    should "not run meet if met? is satisfied" do
      mock(self).do_met { true }
      mock(self).do_meet.never
      dep "foo" do
        met? { do_met }
        meet { do_meet }
      end
      satisfy_dependencies
    end

    should "run meet if met? is not satisfied" do
      met_run = false
      mock(self).do_met.twice { result = met_run; met_run = true; result }
      mock(self).do_meet
      dep "foo" do
        met? { do_met }
        meet { do_meet }
      end
      message = capture_output { satisfy_dependencies }
      assert_match /Dependency foo is not met/, message
    end

    should "only meet a dep once" do
      met_run = false
      mock(self).do_met.twice { result = met_run; met_run = true; result }
      mock(self).do_meet
      2.times do
        dep "foo" do
          met? { do_met }
          meet { do_meet }
        end
      end
      capture_output { satisfy_dependencies }
    end

    should "fail if met? still fails after running meet" do
      mock(self).do_met.twice { false }
      mock(self).do_meet
      dep "foo" do
        met? { do_met }
        meet { do_meet }
      end
      assert_raises(ProcessExit) { capture_output { satisfy_dependencies } }
    end
  end

  context "ensure_ppa" do
    should "fail if the PPA name is not the expected form" do
      assert_raises(ProcessExit) { ensure_ppa("blah") }
      assert_raises(ProcessExit) { ensure_ppa("http://some.ppa.url") }
    end

    # TODO(caleb): Add more unit tests. Having trouble coming up with unit tests that don't feel
    # fragile/artificial. For helpers like these, integration tests of some kind that run on a vagrant box or
    # something may prove more useful.
  end

  context "ensure_run_once" do
    should "run a task exactly once" do
      mock(self).do_meet.never
      meet_run = false
      ensure_run_once("foo") { meet_run = true }
      dep "run task once: foo" do
        met? { do_met }
        meet { do_meet }
      end
      capture_output { satisfy_dependencies }
      assert meet_run
    end
  end
end
