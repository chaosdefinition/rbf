# add Coveralls
require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yarbf'

require 'minitest/autorun'

class TestBase < Minitest::Test
  def setup
    Dir.chdir(File.dirname(__FILE__))
    @bf_src_sir = 'bf'
    @input_dir  = 'input'
    @output_dir = 'output'

    # default options
    @options = {
      :debug => false,
      :wrap_around => false,
      :cell_size => 8,
      :input_mode => :buffered
    }
  end

  def do_test(bf_src, options, input, correct_out, will_raise)
    interpreter = Yarbf::BfInterpreter.new(options)

    if will_raise
      assert_raises { capture_io(input) { interpreter.run(bf_src) } }
    else
      out = capture_io(input) { interpreter.run(bf_src) }[0]
      assert_equal(File.read(correct_out), out,
                   "Test failed at stdout of #{bf_src} with input from #{input}")
    end
  end

  # rewritten capture_io, add redirected input
  def capture_io(in_file = nil)
    require 'tempfile'

    orig_stdin = $stdin.dup
    orig_stdout, out_file = $stdout.dup, Tempfile.new('yarbf-out')
    orig_stderr, err_file = $stderr.dup, Tempfile.new('yarbf-err')
    $stdin.reopen(in_file) unless in_file.nil?
    $stdout.reopen(out_file)
    $stderr.reopen(err_file)

    yield

    $stdin.rewind
    $stdout.rewind
    $stderr.rewind

    [out_file.read, err_file.read]
  ensure
    out_file.unlink
    err_file.unlink
    $stdin.reopen(orig_stdin)
    $stdout.reopen(orig_stdout)
    $stderr.reopen(orig_stderr)
  end

  private :do_test
end
