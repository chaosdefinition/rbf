require 'io/console'

class BfInterpreter
  def initialize(hash)
    @option = hash
  end

  def debug?
    @option[:debug]
  end

  def debug=(debug)
    @option[:debug] = debug
  end

  def wrap_around?
    @option[:wrap_around]
  end

  def wrap_around=(wrap_around)
    @option[:wrap_around] = wrap_around
  end

  def cell_size?
    @option[:cell_size]
  end

  def cell_size=(cell_size)
    @option[:cell_size] = cell_size
  end

  def run(src)
    units = []

    # construct units
    File.open(src) do |file|
      units = construct_program_units(file)
    end

    # match brackets
    match_brackets(units)

    # do interpret
    tape = Array.new
    position = 0
    unit = units[0]
    while unit != nil
      tape[position] = BfCell.new(cell_size?) if tape[position] == nil

      STDERR.printf('%s', unit.instruction) if debug?

      case unit.instruction
        when '+' then tape[position].increase(1, wrap_around?)
        when '-' then tape[position].decrease(1, wrap_around?)
        when '<' then
          position -= 1
          fail 'Cell position out of bound!' if position < 0
        when '>' then position += 1
        when ',' then
          tape[position].value = STDIN.getch.ord
        when '.' then STDOUT.putc tape[position].value
        when '[' then
          if tape[position].value == 0
            unit = unit.match
            next
          end
        when ']' then
          if tape[position].value != 0
            unit = unit.match
            next
          end
        else fail "Illegal instruction '#{unit.instruction}'!"
      end

      unit = unit.next
    end
  end

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

  private :construct_program_units, :match_brackets

  class BfCell
    attr_accessor :cell_size, :value

    def initialize(cell_size = 8, value = 0)
      @cell_size = cell_size
      @value = value
    end

    def increase(increment = 1, wrap_around = true)
      if !wrap_around &&
          (@value + increment < 0 || @value + increment >= (1 << @cell_size))
        fail 'Overflow or underflow happened while forbidden!'
      else
        @value = (@value + increment) % (1 << @cell_size)
      end
    end

    def decrease(decrement = 1, wrap_around = true)
      self.increase(-decrement, wrap_around)
    end
  end

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
