require 'helper' # for TestBase

class TestDefault < TestBase
  # test default mode
  def test_default
    Dir.foreach @input_dir do |filename|
      next if filename.eql? '.' or filename.eql? '..'

      input = File.join(@input_dir, filename)
      next if File.directory? input

      bf_src = File.join(@bf_src_sir, "#{filename}.bf")
      stdout = File.join(@output_dir, "#{filename}-1")
      stderr = File.join(@output_dir, "#{filename}-2")

      do_test(bf_src, '', input, stdout, stderr)
    end
  end
end
