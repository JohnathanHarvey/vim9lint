require 'rules/for_loop_rule'
require 'parser'

RSpec.describe Rules::ForLoopRule do
  let(:rule) { Rules::ForLoopRule.new }

  def violations_for(source_code)
    parser = Parser.new(source_code)
    rule.check(parser)
  end

  it 'flags re-declaration of loop variables' do
    source_code = <<~VIM
      var i = 1
      for i in [1, 2, 3]
        echo i
      endfor
    VIM
    result = violations_for(source_code)

    expect(result).to include(
      hash_including(
        rule: 'ForLoop',
        message: "Loop variable 'i' is already declared. Use a unique variable name.",
        line: 2
      )
    )
  end

  it 'does not flag global variables used as loop variables' do
    source_code = <<~VIM
      g:i = 1
      for g:i in [1, 2, 3]
        echo g:i
      endfor
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end

  it 'flags excessive loop depth' do
    source_code = <<~VIM
      for i in [1, 2, 3]
        for j in [1, 2, 3]
          for k in [1, 2, 3]
            for l in [1, 2, 3]
              for m in [1, 2, 3]
                for n in [1, 2, 3]
                  for o in [1, 2, 3]
                    for p in [1, 2, 3]
                      for q in [1, 2, 3]
                        for r in [1, 2, 3]
                          for s in [1, 2, 3]
                            echo r
                          endfor
                        endfor
                      endfor
                    endfor
                  endfor
                endfor
              endfor
            endfor
          endfor
        endfor
      endfor
    VIM
    result = violations_for(source_code)

    expect(result).to include(
      hash_including(
        rule: 'ForLoop',
        message: "Nesting of loops exceeds the maximum depth of 10.",
        line: 11
      )
    )
  end

  it 'flags modification of the iterated list' do
    source_code = <<~VIM
      let l = [1, 2, 3]
      for i in l
        call remove(l, index(l, i))
      endfor
    VIM
    result = violations_for(source_code)

    expect(result).to include(
      hash_including(
        rule: 'ForLoop',
        message: "Modifying the list 'l' being iterated over can cause skipped items.",
        line: 3
      )
    )
  end

  it 'does not flag modifying nested lists' do
    source_code = <<~VIM
      let nested = [[1, 2], [3, 4]]
      for sublist in nested
        call remove(sublist, 0)
      endfor
    VIM
    result = violations_for(source_code)
    expect(result).to be_empty
  end
end

