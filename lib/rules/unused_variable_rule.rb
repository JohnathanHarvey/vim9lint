# lib/rules/unused_variable_rule.rb
require_relative 'base_rule'

module Rules
  class UnusedVariableRule < BaseRule
    RULE_NAME = "UnusedVariable"

    def check(parser)
      ast = parser.parse
      declared_vars = {}
      used_vars = {}

      ast.each do |node|
        if node[:text] =~ /^let\s+(\w+)/
          var_name = Regexp.last_match(1)
          declared_vars[var_name] = node[:line_number]
        end

        declared_vars.each do |var, decl_line|
          if node[:line_number] != decl_line && node[:text] =~ /\b#{Regexp.escape(var)}\b/
            used_vars[var] = true
          end
        end
      end

      unused = declared_vars.keys - used_vars.keys
      unused.map do |var|
        violation(RULE_NAME, "Variable '#{var}' is declared but not used.", declared_vars[var])
      end
    end
  end
end

