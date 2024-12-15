require_relative 'base_rule'

module Rules
  class ConstantsRule < BaseRule
    RULE_NAME = "Constants"

    def check(parser)
      ast = parser.parse
      violations = []

      ast.each do |node|
        text = node[:text].strip

        # Check for invalid constant mutation
        if text =~ /^const\s+(\w+)\s*=\s*(.+)/
          const_name = Regexp.last_match(1)
          next_lines = ast.select { |n| n[:line_number] > node[:line_number] }
          next_lines.each do |next_node|
            if next_node[:text] =~ /\b#{Regexp.escape(const_name)}\b\s*[\+\-]=|=/
              violations << violation(
                RULE_NAME,
                "Constant '#{const_name}' cannot be reassigned or mutated.",
                next_node[:line_number]
              )
            end
          end
        end

        # Check for invalid mutation of const values
        if text =~ /^const\s+(\w+)\s*=\s*(\{.*\}|\[.*\])/
          const_name = Regexp.last_match(1)
          next_lines = ast.select { |n| n[:line_number] > node[:line_number] }
          next_lines.each do |next_node|
            if next_node[:text] =~ /\b#{Regexp.escape(const_name)}\b\[(.+?)\]\s*=/
              violations << violation(
                RULE_NAME,
                "Constant '#{const_name}' values cannot be modified.",
                next_node[:line_number]
              )
            end
          end
        end

        # Check for final variables being reassigned
        if text =~ /^final\s+(\w+)\s*=\s*(.+)/
          final_name = Regexp.last_match(1)
          next_lines = ast.select { |n| n[:line_number] > node[:line_number] }
          next_lines.each do |next_node|
            if next_node[:text] =~ /\b#{Regexp.escape(final_name)}\b\s*=/
              violations << violation(
                RULE_NAME,
                "Final variable '#{final_name}' cannot be reassigned.",
                next_node[:line_number]
              )
            end
          end
        end
      end

      violations
    end
  end
end

