require 'linter'

RSpec.describe Linter do
  describe '#load_rules' do
    it 'loads all rule instances matching files in lib/rules, ignoring base_rule.rb' do
      rule_files = Dir[File.join('lib', 'rules', '*.rb')].reject do |file|
        File.basename(file) == 'base_rule.rb'
      end

      expected_classes = rule_files.map do |file|
        class_name = File.basename(file, '.rb').split('_').map(&:capitalize).join
        Object.const_get("Rules::#{class_name}")
      end

      linter = described_class.new("vim9script")
      loaded_rules = linter.load_rules

      expect(loaded_rules.map(&:class)).to match_array(expected_classes)
    end
  end
end

