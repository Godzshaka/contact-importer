# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'validations' do
    context 'when the sheet contains valid data' do
      let(:contact){build :contact}

      it 'creates contact successfully' do
        expect(contact.save).to be true
        expect(Contact.count).to eq(1)
        expect(contact.errors.messages.present?).to be false
      end
    end

    context 'when the sheet contains invalid date' do
      let(:contact){build :contact, date_of_birth: 12/06/1970}

      it 'does not save and returns date format error' do
        expect(contact.save).to be false
        expect(contact.errors.messages[:date_of_birth].present?).to be true
        expect(Contact.count).to eq(0)
      end
    end

    context 'when the sheet contains invalid email' do
      let(:contact){build :contact, email: 123}

      it 'does not save and returns email error' do
        expect(contact.save).to be false
        expect(contact.errors.messages[:email].present?).to be true
        expect(Contact.count).to eq(0)
      end
    end

    context 'when the sheet contains invalid name' do
      let(:contact){build :contact, name: "*!test"}

      it 'does not save and returns name error' do
        expect(contact.save).to be false
        expect(contact.errors.messages[:name].present?).to be true
        expect(Contact.count).to eq(0)
      end
    end

    context 'when the sheet does not contain an address' do
      let(:contact){build :contact, address: nil}

      it 'does not save and returns address error' do
        expect(contact.save).to be false
        expect(contact.errors.messages[:address].present?).to be true
        expect(Contact.count).to eq(0)
      end
    end
  end
end
