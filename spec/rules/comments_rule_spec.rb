require 'rules/comments_rule'
require 'parser'

RSpec.describe Rules::CommentsRule do
  let(:rule) { Rules::CommentsRule.new }

  def violations_for(source_code)
    parser = Parser.new(source_code)
    rule.check(parser)
  end

  it 'flags legacy comments after vim9script' do
    source_code = <<~VIM
      vim9script
      " Legacy comment
      var x = 1  # valid comment
    VIM
    result = violations_for(source_code)
    expect(result).to include(
      hash_including(
        rule: 'Comments',
        message: "Legacy comments using `\"` are not allowed in Vim9script. Use `#` instead.",
        line: 2
      )
    )
  end

  it 'does not flag legacy comments before vim9script' do
    source_code = <<~VIM
      " Legacy comment
      vim9script
      var x = 1  # valid comment
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end

  it 'flags missing space before # in comments' do
    source_code = <<~VIM
      vim9script
      var x = 1#comment
    VIM
    result = violations_for(source_code)
    expect(result).to include(
      hash_including(
        rule: 'Comments',
        message: "Comments must have a space before the `#`: `1#`.",
        line: 2
      )
    )
  end

  it 'flags invalid #{ comment usage' do
    source_code = %q(
      vim9script
      var x = 1  #{ invalid comment
    )
    result = violations_for(source_code)
    expect(result).to include(
      hash_including(
        rule: 'Comments',
        message: 'Starting a comment with `#{` is not allowed. Use `#{{` or `#{{{` if starting a fold.',
        line: 3 # seems like %q adds a line before the content
      )
    )
  end

  it 'does not flag valid comments' do
    source_code = <<~VIM
      vim9script
      var x = 1  # valid comment
      # Another valid comment
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end
end

