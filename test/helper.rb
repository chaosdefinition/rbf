$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yarbf'

require 'minitest/autorun'
require 'tempfile'

# add Coverall
require 'coveralls'
Coveralls.wear!

class TestBase < Minitest::Test
  def setup
    Dir.chdir(File.dirname(__FILE__))
    @bf_src_sir = 'bf'
    @input_dir  = 'input'
    @output_dir = 'output'
  end

  def do_test(bf_src, args, input, correct_out, correct_err)
    # create temp files for stdout and stderr
    out = Tempfile.new('yarbf')
    err = Tempfile.new('yarbf')
    out.close
    err.close

    # run yarbf
    system "cat #{input} | yarbf #{args} #{bf_src} 1>#{out.path} 2>#{err.path}"

    # do compare with correct results
    assert_equal File.read(correct_out), File.read(out),
                 "Test failed at stdout of #{bf_src} with input from #{input}"
    assert_equal File.read(correct_err), File.read(err),
                 "Test failed at stderr of #{bf_src} with input from #{input}"

    out.unlink
    err.unlink
  end

  private :do_test
end
