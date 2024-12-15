require_relative 'base_rule'

module Rules
  class ForLoopRule < BaseRule
    RULE_NAME = "ForLoop"

    def check(parser)
      ast = parser.parse
      violations = []

      loop_depth = 0

      ast.each do |node|
        text = node[:text].strip

        if text =~ /^for\s+(\w+)\s+in\s+/
          loop_var = Regexp.last_match(1)

          if declared_variable?(loop_var, ast, node[:line_number])
            violations << violation(
              RULE_NAME,
              "Loop variable '#{loop_var}' is already declared. Use a unique variable name.",
              node[:line_number]
            )
          end

          loop_depth += 1
          if loop_depth > 10
            violations << violation(
              RULE_NAME,
              "Nesting of loops exceeds the maximum depth of 10.",
              node[:line_number]
            )
          end
        end

        loop_depth -= 1 if text == "endfor"

        if text =~ /remove\(([^,]+),/
          list_name = Regexp.last_match(1).strip
          if iterating_over?(list_name, ast, node[:line_number])
            violations << violation(
              RULE_NAME,
              "Modifying the list '#{list_name}' being iterated over can cause skipped items.",
              node[:line_number]
            )
          end
        end
      end

      violations
    end

    private

    def declared_variable?(var, ast, current_line)
      ast.any? { |node| node[:line_number] < current_line && node[:text].strip =~ /^var\s+#{Regexp.escape(var)}\b/ }
    end

    def iterating_over?(list_name, ast, current_line)
      ast.any? { |node| node[:line_number] < current_line && node[:text].strip =~ /^for\s+\w+\s+in\s+#{Regexp.escape(list_name)}/ }
    end
  end
end

