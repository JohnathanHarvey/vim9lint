require_relative 'base_rule'

module Rules
  class FunctionTypeCheckRule < BaseRule
    RULE_NAME = "FunctionTypeCheck"

    def check(parser)
      ast = parser.parse
      violations = []

      ast.each do |node|
        if node[:text] =~ /^def\s+(\w+)\((.*)\)(\s*:\s*(\w+))?/
          func_name = Regexp.last_match(1)
          args = Regexp.last_match(2)
          return_type = Regexp.last_match(4)

          if return_type.nil?
            violations << violation(
              RULE_NAME,
              "Function '#{func_name}' is missing a return type.",
              node[:line_number]
            )
          end

          args.split(',').each do |arg|
            arg = arg.strip
            next if arg.empty? || arg == '_'

            unless arg =~ /\w+\s*:\s*\w+/ || arg =~ /\.\.\.\s*\w+:\s*list<\w+>/
              violations << violation(
                RULE_NAME,
                "Argument '#{arg}' in function '#{func_name}' is missing a type annotation.",
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

