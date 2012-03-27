require "bundler/setup"
require "minitest/autorun"
require "scope"
require "rr"
require "stringio"

$:.unshift(File.join(File.dirname(__FILE__), "../lib"))

module Scope
  class TestCase
    include RR::Adapters::MiniTest
  end
end

module Kernel
  def capture_output
    result = StringIO.new
    $stdout = result
    yield
    result.string
  ensure
    $stdout = STDOUT
  end
end
