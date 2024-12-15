require 'rules/constants_rule'
require 'parser'

RSpec.describe Rules::ConstantsRule do
  let(:rule) { Rules::ConstantsRule.new }

  def violations_for(source_code)
    parser = Parser.new(source_code)
    rule.check(parser)
  end

  it 'flags reassignment of a constant' do
    source_code = <<~VIM
      vim9script
      const MY_CONSTANT = 42
      MY_CONSTANT = 43
    VIM
    result = violations_for(source_code)
    expect(result).to include(
      hash_including(
        rule: 'Constants',
        message: "Constant 'MY_CONSTANT' cannot be reassigned or mutated.",
        line: 3
      )
    )
  end

  it 'flags mutation of a const list or dictionary' do
    source_code = <<~VIM
      vim9script
      const MY_LIST = [1, 2, 3]
      MY_LIST[0] = 42
    VIM
    result = violations_for(source_code)
    expect(result).to include(
      hash_including(
        rule: 'Constants',
        message: "Constant 'MY_LIST' values cannot be modified.",
        line: 3
      )
    )
  end

  it 'flags reassignment of a final variable' do
    source_code = <<~VIM
      vim9script
      final MY_VAR = 42
      MY_VAR = 43
    VIM
    result = violations_for(source_code)
    expect(result).to include(
      hash_including(
        rule: 'Constants',
        message: "Final variable 'MY_VAR' cannot be reassigned.",
        line: 3
      )
    )
  end

  it 'does not flag valid usage of constants' do
    source_code = <<~VIM
      vim9script
      const MY_CONSTANT = 42
      echo MY_CONSTANT
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end

  it 'does not flag valid usage of final variables' do
    source_code = <<~VIM
      vim9script
      final MY_VAR = [1, 2, 3]
      MY_VAR[0] = 42
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end
end

