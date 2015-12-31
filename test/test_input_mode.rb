require 'helper' # for TestBase

class TestInputMode < TestBase
  def setup
    super
    @input_dir = File.join(@input_dir, 'input_mode')
    @output_dir = File.join(@output_dir, 'input_mode')
  end

  # test 'wrap_around' switch
  def test_wrap_around
    Dir.foreach @input_dir do |filename|
      next if filename.eql? '.' or filename.eql? '..'

      input = File.join(@input_dir, filename)
      next if File.directory? input

      # input filename must match this pattern
      refute_nil(/(.*)-(buffered|raw)$/.match(filename))
      filename, mode = $1, $2

      bf_src = File.join(@bf_src_sir, "#{filename}.bf")
      stdout = File.join(@output_dir, "#{filename}-#{mode}-1")
      stderr = File.join(@output_dir, "#{filename}-#{mode}-2")

      do_test(bf_src, "-i #{mode}", input, stdout, stderr)
    end
  end
end
