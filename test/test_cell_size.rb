require 'helper' # for TestBase

class TestCellSize < TestBase
  def setup
    super
    @input_dir = File.join(@input_dir, 'cell_size')
    @output_dir = File.join(@output_dir, 'cell_size')
  end

  # test 'cell_size' option
  def test_cell_size
    Dir.foreach @input_dir do |filename|
      next if filename.eql? '.' or filename.eql? '..'

      input = File.join(@input_dir, filename)
      next if File.directory? input

      # input filename must match this pattern
      refute_nil(/(.*)-([1-9]\d*)$/.match(filename))
      filename, size = $1, $2

      bf_src = File.join(@bf_src_sir, "#{filename}.bf")
      stdout = File.join(@output_dir, "#{filename}-#{size}-1")
      stderr = File.join(@output_dir, "#{filename}-#{size}-2")

      do_test(bf_src, "-s #{size}", input, stdout, stderr)
    end
  end
end
