# lib/rules/require_vim9script_rule.rb
require_relative 'base_rule'

module Rules
  class RequireVim9scriptRule < BaseRule
    RULE_NAME = "RequireVim9script"

    def check(parser)
      ast = parser.parse

      # Check if 'vim9script' is the first non-empty, non-comment line
      first_line = ast.find { |node| !node[:text].strip.start_with?('"') && !node[:text].strip.empty? }
      
      if first_line.nil? || first_line[:text] != 'vim9script'
        [
          violation(
            RULE_NAME,
            "Missing 'vim9script' directive at the beginning of the file.",
            first_line ? first_line[:line_number] : 1
          )
        ]
      else
        []
      end
    end
  end
end

