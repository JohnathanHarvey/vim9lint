require 'parser'

RSpec.describe Parser do
  describe '#parse' do
    let(:parser) { Parser.new(source_code) }

    context 'with a simple Vim9 script' do
      let(:source_code) do
        <<~VIM
          vim9script
          let var1 = 42
          let var2 = 84
          echo var1
        VIM
      end

      it 'parses the source code into a list of lines with line numbers and text' do
        result = parser.parse
        expect(result).to eq([
          { line_number: 1, text: 'vim9script' },
          { line_number: 2, text: 'let var1 = 42' },
          { line_number: 3, text: 'let var2 = 84' },
          { line_number: 4, text: 'echo var1' }
        ])
      end
    end

    context 'with empty lines and comments' do
      let(:source_code) do
        <<~VIM

          " This is a comment
          let var = 42

        VIM
      end

      it 'includes empty lines and comments in the parsed output' do
        result = parser.parse
        expect(result).to eq([
          { line_number: 1, text: '' },
          { line_number: 2, text: '" This is a comment' },
          { line_number: 3, text: 'let var = 42' },
          { line_number: 4, text: '' }
        ])
      end
    end

    context 'with an empty file' do
      let(:source_code) { '' }

      it 'returns an empty array' do
        result = parser.parse
        expect(result).to eq([])
      end
    end

    context 'with multiline code' do
      let(:source_code) do
        # This whitespace probably matters in the future
        <<~VIM
          let var = {
          'key': 'value'
          }
        VIM
      end

      it 'parses each line independently' do
        result = parser.parse
        expect(result).to eq([
          { line_number: 1, text: "let var = {" },
          { line_number: 2, text: "'key': 'value'" },
          { line_number: 3, text: "}" }
        ])
      end
    end
  end
end

