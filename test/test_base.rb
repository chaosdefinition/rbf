require 'test/unit' # for Test::Unit::TestCase
require 'tempfile' # for Tempfile

class TestBase < Test::Unit::TestCase
  def setup
    @bf_src_sir = 'bf'
    @input_dir  = 'input'
    @output_dir = 'output'
  end

  def do_test(bf_src, args, input, stdout, stderr)
    # create temp files for stdout and stderr
    out = Tempfile.new('yarbf')
    err = Tempfile.new('yarbf')
    out.close
    err.close

    # run yarbf
    system "cat #{input} | yarbf #{args} #{bf_src} 1>#{out.path} 2>#{err.path}"

    # do compare with correct results
    assert_true(FileUtils.identical?(out.path, stdout),
                "Test failed at stdout of #{bf_src} with input from #{input} " +
                "and output of:\n\n#{File.read(out)}")
    assert_true(FileUtils.identical?(err.path, stderr),
                "Test failed at stderr of #{bf_src} with input from #{input} " +
                "and output of:\n\n#{File.read(err)}")

    # delete temp files
    out.unlink
    err.unlink
  end

  private :do_test
end
