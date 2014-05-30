class MockIO < IO
  def initialize
  end

  methods.each do |meth|
    define_method(:meth) {}
  end

  def === other
    super other
  end
end

module MockNet
  class HTTP

    class Response
      class ResponseHash
        def []key
          { 'ok' => true, 'hostname' => 'pool' }
        end

      end

      def body
        ResponseHash.new
      end

    end

    class Post
      def initialize uri
        @uri = uri
      end

      def set_form_data hash

      end
    end

    class Delete
      def initialize uri
        @uri = uri
      end
    end

    def initialize host, port
      @host = host
      @port = port
    end

    def request req
      Response.new
    end
  end

end

class FakeCommand
  attr_accessor :command
  attr_accessor :args
  def initialize(command, args='')
    @command = command
    @args = args
  end
end

class FakeHost
  attr_accessor :commands

  def initialize(options = {})
    @pe = options[:pe]
    @options = options[:options]
    @commands = []
  end

  def port_open?(port)
    true
  end

  def is_pe?
    @pe
  end

  def [](name)
    @options[name]
  end

  def any_exec_result
    RSpec::Mocks::Mock.new('exec-result').as_null_object
  end

  def exec(command, options = {})
    commands << command
    any_exec_result
  end

  def execute(command, options = {})
    b = FakeCommand.new command
    commands << b
    any_exec_result
  end

  def tmpdir(name)
    b = FakeCommand.new "mktemp -dt #{name}.XXXXXX"
    commands << b
    "#{name}.XXXXXX"
  end

  def puppet(subcommand)
    case subcommand
    when 'master'
      { 'user' => 'puppet'
      }
    end
  end

  def command_strings
    commands.map { |c| [c.command, c.args].join(' ') }
  end
end
