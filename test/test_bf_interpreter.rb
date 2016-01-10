require 'helper' # for TestBase

class TestBfInterpreter < TestBase
  def setup
    super

    # default options for this test
    @options = {
      :debug => true,
      :wrap_around => true,
      :cell_size => 7,
      :input_mode => :raw
    }
  end

  # test BfInterpreter#initialize
  def test_initialize
    initialize_with_invalid_type
    initialize_missing_options
    initialize_with_other_options
  end

  def initialize_with_invalid_type
    options = 'debug: true, wrap_around: true, cell_size: 7, input_mode: raw'
    assert_raises do
      Yarbf::BfInterpreter.new(options)
    end
  end

  def initialize_missing_options
    @options.each_key do |key|
      options = @options.reject { |k| k == key }
      assert_raises do
        Yarbf::BfInterpreter.new(options)
      end
    end
  end

  def initialize_with_other_options
    options = {
        :debug => true,
        :wrap_around => true,
        :cell_size => 7,
        :input_mode => :raw,

        # other options
        :just_a_test => 'yes'
    }
    expected = {
      :debug => true,
      :wrap_around => true,
      :cell_size => 7,
      :input_mode => :raw
    }
    actual = Yarbf::BfInterpreter.new(options).instance_variable_get(:@options)
    assert_equal(expected, actual)
  end

  private :initialize_with_invalid_type, :initialize_missing_options,
          :initialize_with_other_options

  # test BfInterpreter#*?
  def test_option_setters
    interpreter = Yarbf::BfInterpreter.new(@options)

    assert_raises do
      interpreter.debug = :debug
    end
    assert_raises do
      interpreter.wrap_around = 'no'
    end
    assert_raises do
      interpreter.cell_size = 8.0
    end
    assert_raises do
      interpreter.input_mode = :some_other_mode
    end
  end

  # test BfInterpreter#construct_program_units and BfInterpreter#match_brackets
  def test_construct_program_units
    interpreter = Yarbf::BfInterpreter.new(@options)

    out_dir_1 = File.join(@output_dir, 'construct_program_units')
    out_dir_2 = File.join(@output_dir, 'match_brackets')

    Dir.foreach(@bf_src_sir) do |src|
      next if src.eql?('.') || src.eql?('..')

      filename = /(.*)\.bf$/.match(src)[1]
      File.open(File.join(@bf_src_sir, src)) do |file|
        units = interpreter.send(:construct_program_units, file)
        expected = File.join(out_dir_1, "#{filename}-1")
        assert_equal(File.read(expected), capture_stdout { puts units })

        interpreter.send(:match_brackets, units)
        expected = File.join(out_dir_2, "#{filename}-1")
        assert_equal(File.read(expected), capture_stdout { puts units })
      end
    end
  end

  def capture_stdout
    prev, $stdout = $stdout, StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = prev
  end

  private :capture_stdout
end
