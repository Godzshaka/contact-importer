require 'rails_helper'

shared_examples_for 'cpf_validated' do

  let(:model) { described_class }
  let(:object) { mock_operator_api { build(model.to_s.underscore) } }
  let(:field) { model.column_names.find { |column| column =~ /cpf/ }.to_sym }

  context 'when cpf is invalid' do
    it 'and formatted' do
      object.send("#{field}=", '123.456.789-94')
      expect(object).to be_invalid
      expect(object.errors.keys).to include field
    end

    it 'and not formatted' do
      object.send("#{field}=", '12345678994')
      expect(object).to be_invalid
      expect(object.errors.keys).to include field
    end
  end

  context 'when cpf is valid' do
    it 'and formatted' do
      object.send("#{field}=", CPF.generate(true))
      expect(object).to be_valid
    end

    it 'and not formatted' do
      object.send("#{field}=", CPF.generate)
      expect(object).to be_valid
    end
  end
end
