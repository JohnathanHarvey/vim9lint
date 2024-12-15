# A main file that requires all your library files. It often sets up the namespace and any global configuration.

# lib/linter.rb
require_relative 'parser'
require_relative 'rules/base_rule'
require_relative 'rules/comments_rule'
require_relative 'rules/constants_rule'
require_relative 'rules/for_loop_rule'
require_relative 'rules/function_type_check_rule'
require_relative 'rules/require_vim9script_rule'
require_relative 'rules/unused_variable_rule'
require_relative 'rules/variable_arguments_rule'

class Linter
  def initialize(source_code)
    # may need to actually take file_path and File.read(file_path) into parser
    @source_code = source_code
    @parser = Parser.new(source_code)
    @rules = load_rules
  end

  def self.run(file_path)
    source_code = File.read(file_path)
    linter = new(source_code)
    linter.lint
  end

  def lint
    @rules.flat_map { |rule| rule.check(@parser) }.compact
  end

  def load_rules
    [
      Rules::CommentsRule.new,
      Rules::ConstantsRule.new,
      Rules::ForLoopRule.new,
      Rules::FunctionTypeCheckRule.new,
      Rules::RequireVim9scriptRule.new,
      Rules::UnusedVariableRule.new,
      Rules::VariableArgumentsRule.new
    ]
  end
end
