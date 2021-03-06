require 'spec_helper'
require 'gitsh/tab_completion/dsl/rule_set_factory'
require 'gitsh/tab_completion/dsl/rule_factory'

describe Gitsh::TabCompletion::DSL::RuleSetFactory do
  describe '#build' do
    it 'delegates to the various rule factories' do
      start_state = double(:start_state)
      rule_factory_1 = stub_rule_factory
      rule_factory_2 = stub_rule_factory
      factory = described_class.new([rule_factory_1, rule_factory_2])

      factory.build(start_state)

      expect(rule_factory_1).to have_received(:build).with(start_state).once
      expect(rule_factory_2).to have_received(:build).with(start_state).once
    end
  end

  def stub_rule_factory
    instance_double(
      Gitsh::TabCompletion::DSL::RuleFactory,
      build: nil,
    )
  end
end
