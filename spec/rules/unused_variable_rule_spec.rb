# spec/rules/unused_variable_rule_spec.rb
require 'rules/unused_variable_rule'
require 'parser'

RSpec.describe Rules::UnusedVariableRule do
  let(:source_code) do
    <<~VIM
      let unused_var = 42
      let used_var = 84
      echo used_var
    VIM
  end

  let(:parser) { Parser.new(source_code) }
  let(:rule) { Rules::UnusedVariableRule.new }

  it 'detects unused variables' do
    results = rule.check(parser)
    expect(results).to include(
      hash_including(
        rule: 'UnusedVariable',
        message: "Variable 'unused_var' is declared but not used.",
        line: 1
      )
    )
  end

  it 'does not report used variables' do
    results = rule.check(parser)
    expect(results).not_to include(
      hash_including(
        rule: 'UnusedVariable',
        message: "Variable 'used_var' is declared but not used."
      )
    )
  end
end

