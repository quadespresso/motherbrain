module MotherBrain
  # @author Jamie Winsor <jamie@vialstudios.com>
  # @api private
  class CommandRunner
    attr_reader :scope

    # @return [Proc]
    attr_reader :execute

    # @param [Object] scope
    # @param [Proc] execute
    def initialize(scope, execute, *args)
      @scope = scope
      @execute = execute
      @arguments = args

      instance_eval(&execute)
    end

    def chef_run(&block)
      unless block_given?
        raise PluginSyntaxError, "Block required"
      end

      scope.context.runners = Array.new
      scope.instance_eval(&block)

      scope.context.runners.each { |runner| runner.run }

      nodes = scope.context.runners.collect do |runner|
        runner.nodes
      end.flatten.uniq

      chef_start(nodes)
    ensure
      scope.context.runners = nil
    end

    private

      def chef_start(nodes)
        nodes.each do |node|
          puts "Running Chef on #{node[:name]}"
        end
      end
  end
end