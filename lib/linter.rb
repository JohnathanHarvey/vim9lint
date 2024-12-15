# A main file that requires all your library files. It often sets up the namespace and any global configuration.

# lib/linter.rb
require_relative 'parser'
require_relative 'rules/base_rule'
require_relative 'rules/unused_variable_rule'
require_relative 'rules/require_vim9script_rule'

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

  private

  def load_rules
    [
      Rules::UnusedVariableRule.new,
      Rules::RequireVim9scriptRule.new
      # Rules::SyntaxRule.new,
      # Rules::StyleRule.new,
      # Rules::BestPracticesRule.new
    ]
  end
end
