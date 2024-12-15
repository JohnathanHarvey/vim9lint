require 'rules/require_vim9script_rule'
require 'parser'

RSpec.describe Rules::RequireVim9scriptRule do
  let(:rule) { Rules::RequireVim9scriptRule.new }

  it 'flags missing vim9script' do
    source_code = "let unused_var = 42\n"
    parser = Parser.new(source_code)
    result = rule.check(parser)

    expect(result).to include(
      hash_including(
        rule: 'RequireVim9script',
        message: "Missing 'vim9script' directive at the beginning of the file.",
        line: 1
      )
    )
  end

  it 'flags misplaced vim9script' do
    source_code = "\" Comment\nlet unused_var = 42\nvim9script\n"
    parser = Parser.new(source_code)
    result = rule.check(parser)

    expect(result).to include(
      hash_including(
        rule: 'RequireVim9script',
        message: "Missing 'vim9script' directive at the beginning of the file.",
        line: 2
      )
    )
  end

  it 'does not flag correct vim9script placement' do
    source_code = "vim9script\nlet unused_var = 42\n"
    parser = Parser.new(source_code)
    result = rule.check(parser)

    expect(result).to be_empty
  end
end

