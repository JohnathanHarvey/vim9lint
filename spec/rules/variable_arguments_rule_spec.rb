require 'rules/variable_arguments_rule'
require 'parser'

RSpec.describe Rules::VariableArgumentsRule do
  let(:rule) { Rules::VariableArgumentsRule.new }

  def violations_for(source_code)
    parser = Parser.new(source_code)
    rule.check(parser)
  end

  it 'flags improperly typed variable arguments' do
    source_code = <<~VIM
      def MyFunc(...args): void
        echo args
      enddef
    VIM
    result = violations_for(source_code)

    expect(result).to include(
      hash_including(
        rule: 'VariableArguments',
        message: "Variable argument '...args' in function 'MyFunc' is not properly typed. Expected format: '...name: list<type>'.",
        line: 1
      )
    )
  end

  it 'does not flag correctly typed variable arguments' do
    source_code = <<~VIM
      def MyFunc(...args: list<number>): void
        for arg in args
          echo arg
        endfor
      enddef
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end

  it 'ignores functions without variable arguments' do
    source_code = <<~VIM
      def MyFunc(arg: string): void
        echo arg
      enddef
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end

  it 'flags multiple improperly typed variable arguments' do
    source_code = <<~VIM
      def MyFunc(...args, ...numbers): void
        echo args
        echo numbers
      enddef
    VIM
    result = violations_for(source_code)

    expect(result).to include(
      hash_including(
        rule: 'VariableArguments',
        message: "Variable argument '...args' in function 'MyFunc' is not properly typed. Expected format: '...name: list<type>'.",
        line: 1
      )
    )
    expect(result).to include(
      hash_including(
        rule: 'VariableArguments',
        message: "Variable argument '...numbers' in function 'MyFunc' is not properly typed. Expected format: '...name: list<type>'.",
        line: 1
      )
    )
  end
end
