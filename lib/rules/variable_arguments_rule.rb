require_relative 'base_rule'

module Rules
  class VariableArgumentsRule < BaseRule
    RULE_NAME = "VariableArguments"

    def check(parser)
      ast = parser.parse
      violations = []

      ast.each do |node|
        if node[:text] =~ /^def\s+(\w+)\((.*)\)/
          func_name = Regexp.last_match(1)
          args = Regexp.last_match(2)

          args.split(',').each do |arg|
            arg = arg.strip
            next unless arg.start_with?('...')

            unless arg =~ /\A\.\.\.\w+:\s*list<\w+>\z/
              violations << violation(
                RULE_NAME,
                "Variable argument '#{arg}' in function '#{func_name}' is not properly typed. Expected format: '...name: list<type>'.",
                node[:line_number]
              )
            end
          end
        end
      end

      violations
    end
  end
end

