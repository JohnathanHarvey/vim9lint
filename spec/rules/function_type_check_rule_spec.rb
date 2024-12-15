require 'rules/function_type_check_rule'
require 'parser'

RSpec.describe Rules::FunctionTypeCheckRule do
  let(:rule) { Rules::FunctionTypeCheckRule.new }

  def violations_for(source_code)
    parser = Parser.new(source_code)
    rule.check(parser)
  end

  it 'flags missing return types' do
    source_code = <<~VIM
      def MyFunc(arg: string)
        echo arg
      enddef
    VIM
    result = violations_for(source_code)
    expect(result).to include(
      hash_including(
        rule: 'FunctionTypeCheck',
        message: "Function 'MyFunc' is missing a return type.",
        line: 1
      )
    )
  end

  it 'flags missing argument types' do
    source_code = <<~VIM
      def MyFunc(arg, another: string): void
        echo arg
      enddef
    VIM
    result = violations_for(source_code)
    expect(result).to include(
      hash_including(
        rule: 'FunctionTypeCheck',
        message: "Argument 'arg' in function 'MyFunc' is missing a type annotation.",
        line: 1
      )
    )
  end

  it 'does not flag correctly typed functions' do
    source_code = <<~VIM
      def MyFunc(arg: string): void
        echo arg
      enddef
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end

  it 'handles variable arguments' do
    source_code = <<~VIM
      def MyFunc(...args: list<string>): void
        for arg in args
          echo arg
        endfor
      enddef
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end

  it 'ignores ignored arguments' do
    source_code = <<~VIM
      def MyFunc(_, value: string): void
        echo value
      enddef
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end
end

