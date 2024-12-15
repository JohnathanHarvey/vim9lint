require_relative 'base_rule'

module Rules
  class CommentsRule < BaseRule
    RULE_NAME = "Comments"

    def check(parser)
      ast = parser.parse
      return [] if ast.nil? || ast.empty?

      violations = []

      ast.each do |node|
        text = node[:text]&.strip || ""
        line_number = node[:line_number]

        # Check for legacy comments (double quote)
        if text.start_with?('"') && !within_legacy_section?(ast, line_number)
          violations << violation(
            RULE_NAME,
            "Legacy comments using `\"` are not allowed in Vim9script. Use `#` instead.",
            line_number
          )
        end

        # Check for missing space before # in comments
        if text.include?('#') && text !~ /\s#|^\s*#/
          matches = text.scan(/[^ ]#/) || []
          matches.each do |match|
            violations << violation(
              RULE_NAME,
              "Comments must have a space before the `#`: `#{match}`.",
              line_number
            )
          end
        end

        # Check for invalid #{ comment usage
        if text.match?(/#\{\s*[^#]/)
          violations << violation(
            RULE_NAME,
            %q(Starting a comment with `#{` is not allowed. Use `#{{` or `#{{{` if starting a fold.),
            line_number
          )
        end
      end

      violations
    end

    private

    # Check if the current line is within a legacy comment section
    def within_legacy_section?(ast, line_number)
      vim9script_found = false
      ast.sort_by! { |node| node[:line_number] }
      ast.each do |node|
        break if node[:line_number] >= line_number
        vim9script_found = true if node[:text]&.strip == 'vim9script'
      end
      !vim9script_found
    end
  end
end

