require 'helper' # for TestBase

class TestInputMode < TestBase
  def setup
    super
    @input_dir = File.join(@input_dir, 'input_mode')
    @output_dir = File.join(@output_dir, 'input_mode')
  end

  # test 'input_mode' option
  def test_input_mode
    Dir.foreach(@input_dir) do |filename|
      next if filename.eql?('.') || filename.eql?('..')

      input = File.join(@input_dir, filename)
      next if File.directory?(input)

      # input filename must match this pattern
      refute_nil(/(.*)-(buffered|raw)$/.match(filename))
      filename, mode = $1, $2

      bf_src = File.join(@bf_src_sir, "#{filename}.bf")
      stdout = File.join(@output_dir, "#{filename}-#{mode}-1")
      stderr = File.join(@output_dir, "#{filename}-#{mode}-2")

      @options[:input_mode] = mode.to_sym
      do_test(bf_src, @options, input, stdout, !File.read(stderr).empty?)
    end
  end
end
