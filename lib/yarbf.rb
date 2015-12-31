require 'io/console' # for IO.getch

require 'yarbf/version' # for Yarbf::VERSION

module Yarbf
  # available options for the program
  OPTIONS = [:debug, :wrap_around, :cell_size, :input_mode] # :nodoc:

  # available options for input mode
  INPUT_MODE_OPTIONS = [:buffered, :raw] # :nodoc:

  ##
  # == BfInterpreter
  #
  # BfInterpreter is the main class of module #Yarbf.
  #
  # === Options
  #
  # Options to interpreter can be specified via passing a #Hash object to
  # the constructor or just calling attribute writers. Supported options are:
  #
  # - debug:: Debug mode switch. Setting this options to true will print out
  #           each Brainfuck instruction when interpreting. Default is false.
  # - wrap_around:: Wrap around switch. Setting this options to true will
  #                 ignore cell value overflow or underflow. Default is false.
  # - cell_size:: Size of each cell in bit. Default is 8.
  # - input_mode:: Input mode. Available options are +:buffered+ and +:raw+.
  #                In buffered mode, the characters you type will be echoed on
  #                screen and will be buffered until you type an enter. In raw
  #                mode, there's no echoing nor buffering. Default is
  #                +:buffered+.
  #
  # === Examples
  #
  # Following is a brief example.
  #
  #   require 'yarbf'
  #
  #   options = {
  #     :debug => true,
  #     :wrap_around => true,
  #     :cell_size => 16,
  #     :input_mode => :buffered
  #   }
  #   interpreter = YARBF::BfInterpreter.new(options)
  #   interpreter.run('/path/to/Brainfuck/source')
  #
  class BfInterpreter
    ##
    # Initialize the instance.
    #
    # +options+:: A Hash containing options to the interpreter.
    #
    def initialize(options)
      unless options.is_a? Hash and OPTIONS.all? { |s| options.has_key? s }
        fail 'Invalid options given!'
      end
      @options = options.dup
    end

    ##
    # Returns whether the interpreter is in debug mode.
    #
    def debug?
      @options[:debug]
    end

    ##
    # Sets the interpreter to debug mode
    #
    # +debug+:: A boolean value.
    #
    def debug=(debug)
      unless [true, false].include? debug
        fail "'debug' switch should be a boolean but is a #{debug.class}!"
      end
      @options[:debug] = debug
    end

    ##
    # Returns whether the interpreter accepts wrap around.
    #
    def wrap_around?
      @options[:wrap_around]
    end

    ##
    # Sets whether the interpreter should accept wrap around.
    #
    # +wrap_around+:: A boolean value.
    #
    def wrap_around=(wrap_around)
      unless [true, false].include? wrap_around
        fail "'wrap_around' should be a boolean but is a #{wrap_around.class}!"
      end
      @options[:wrap_around] = wrap_around
    end

    ##
    # Returns the size of each tape cell.
    #
    def cell_size?
      @options[:cell_size]
    end

    ##
    # Sets the size of each tape cell.
    #
    # +cell_size+:: An integer.
    #
    def cell_size=(cell_size)
      unless cell_size.is_a? Integer
        fail "'cell_size' should be an integer but is a #{cell_size.class}!"
      end
      @options[:cell_size] = cell_size
    end

    ##
    # Returns the current input mode.
    #
    def input_mode?
      @options[:input_mode]
    end

    ##
    # Sets the input mode.
    #
    # +input_mode+:: A symbol of +:buffered+ or +:raw+.
    #
    def input_mode=(input_mode)
      unless INPUT_MODE_OPTIONS.include? input_mode
        fail 'Invalid value of input mode!'
      end
      @options[:input_mode] = input_mode
    end

    ##
    # Interpret a Brainfuck source file.
    #
    # +src+:: Path of the source.
    #
    def run(src)
      units = []

      # construct units
      begin
        File.open(src) { |file| units = construct_program_units(file) }
      rescue SystemCallError => e
        STDERR.puts $0 + ': ' + e.to_s
        return
      end

      # match brackets
      match_brackets(units)

      # do interpret
      tape = Array.new
      position = 0
      unit = units[0]
      until unit.nil?
        tape[position] = BfCell.new(cell_size?) if tape[position].nil?
        STDERR.printf('%s', unit.instruction) if debug?
        unit, position = deal_unit(unit, tape, position)
      end
    end

    ##
    # Constructs and returns the program units of class #BfProgramUnit.
    #
    # +file+:: The #File object of source file.
    #
    def construct_program_units(file)
      units = Array.new
      position = 0

      file.each_byte do |c|
        case c.chr
          when '+', '-', '<', '>', '[', ']', '.', ',' then
            unit = BfProgramUnit.new(c.chr)
            units[position - 1].next = unit if position > 0
            units[position] = unit
            position += 1
          else
            # other characters are considered as comments, do nothing
        end
      end

      units
    end

    ##
    # Matches each bracket '[' and ']' in the source.
    #
    # +units+:: An #Array of program units.
    #
    def match_brackets(units)
      units.each_index do |i|
        if units[i].instruction == '['
          level = 0
          units[i + 1 .. units.length - 1].each_index do |j|
            j += i + 1
            if units[j].instruction == '['
              level += 1
            elsif units[j].instruction == ']'
              if level > 0
                level -= 1
              else
                units[i].match = units[j]
                units[j].match = units[i]
                break
              end
            end
          end
          fail 'Unmatched brackets!' if level > 0
        end
      end
    end

    ##
    # Reads next character from stdin.
    #
    def get_char
      ch = nil
      begin
        ch = STDIN.getc if input_mode? == :buffered
        ch = STDIN.getch if input_mode? == :raw
      rescue SystemCallError => e
        fail e.to_s
      end
      ch
    end

    def deal_unit(unit, tape, position)
      case unit.instruction
        when '+' then
          tape[position].increase(1, wrap_around?)
          unit = unit.next
        when '-' then
          tape[position].decrease(1, wrap_around?)
          unit = unit.next
        when '<' then
          position -= 1
          fail 'Cell position out of bound!' if position < 0
          unit = unit.next
        when '>' then
          position += 1
          unit = unit.next
        when ',' then
          ch = get_char
          return nil, nil if ch.nil?
          tape[position].value = ch.ord
          unit = unit.next
        when '.' then
          STDOUT.putc tape[position].value
          unit = unit.next
        when '[' then
          if tape[position].value == 0
            unit = unit.match
          else
            unit = unit.next
          end
        when ']' then
          if tape[position].value != 0
            unit = unit.match
          else
            unit = unit.next
          end
        else
          fail "Invalid instruction '#{unit.instruction}'!"
      end
      return unit, position
    end

    private :construct_program_units, :match_brackets, :get_char, :deal_unit

    ##
    # Cell of the Brainfuck tape.
    #
    class BfCell
      attr_accessor :cell_size, :value

      def initialize(cell_size = 8, value = 0)
        @cell_size = cell_size
        @value = value
      end

      ##
      # Increase the value of a cell.
      #
      # +increment+:: Value to increase by. Default is 1.
      # +wrap_around+:: Whether to wrap around. Default is false.
      #
      def increase(increment = 1, wrap_around = false)
        if !wrap_around &&
            (@value + increment < 0 || @value + increment >= (1 << @cell_size))
          fail 'Overflow or underflow happened while forbidden!'
        else
          @value = (@value + increment) % (1 << @cell_size)
        end
      end

      ##
      # Decrease the value of a cell.
      #
      # +decrement+:: Value to decrease by. Default is 1.
      # +wrap_around+:: Whether to wrap around. Default is false.
      #
      def decrease(decrement = 1, wrap_around = false)
        self.increase(-decrement, wrap_around)
      end
    end

    ##
    # Program unit of Brainfuck.
    #
    class BfProgramUnit
      attr_reader :instruction

      attr_accessor :match
      attr_accessor :next

      def initialize(instruction)
        @instruction = instruction
        @match = nil
        @next = nil
      end
    end
  end
end
