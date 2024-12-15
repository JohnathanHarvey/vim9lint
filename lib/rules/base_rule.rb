# lib/rules/base_rule.rb
module Rules
  class BaseRule
    # Common functionality for rules can go here.
    # For example, a common violation format method.
    def violation(rule_name, message, line)
      { rule: rule_name, message: message, line: line }
    end
  end
end
