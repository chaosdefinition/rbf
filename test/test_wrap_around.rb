require_relative 'test_base' # for TestBase

class TestWrapAround < TestBase
  def setup
    super
    @input_dir = File.join(@input_dir, 'wrap_around')
    @output_dir = File.join(@output_dir, 'wrap_around')
  end

  # test 'wrap_around' switch
  def test_wrap_around
    Dir.foreach @input_dir do |filename|
      next if filename.eql? '.' or filename.eql? '..'

      input = File.join(@input_dir, filename)
      next if File.directory? input

      bf_src = File.join(@bf_src_sir, "#{filename}.bf")
      stdout = File.join(@output_dir, "#{filename}-1")
      stderr = File.join(@output_dir, "#{filename}-2")

      do_test(bf_src, '-w', input, stdout, stderr)
    end
  end
end
