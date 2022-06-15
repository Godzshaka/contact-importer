# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportService do
  describe '#import_contacts' do
    context 'when it is called using a right sheet' do
      let(:file_path) { Rails.root.join('spec/fixtures/sheets/successful_contacts.csv') }
      let(:import) { create :import }
      let(:user) { create :user }

      before do
        allow(Rails.root).to receive(:join).and_return(file_path)
        ImportService.new(user.id, import.id).import_contacts
      end

      it 'creates all sheet contacts' do
        expect(Contact.all.count).to eq(17)
      end

      it 'updates import status to finished' do
        expect(import.reload.status).to eq('Finished')
      end

      it 'does not return errors' do
        expect(import.reload.error).to eq('')
      end
    end

    context 'when it is called using an empty sheet' do
      let(:file_path) { Rails.root.join('spec/fixtures/sheets/empty_contacts.csv') }
      let(:import) { create :import }
      let(:user) { create :user }

      before do
        allow(Rails.root).to receive(:join).and_return(file_path)
        ImportService.new(user.id, import.id).import_contacts
      end

      it 'creates all sheet contacts' do
        expect(Contact.all.count).to eq(0)
      end

      it 'updates import status to finished' do
        expect(import.reload.status).to eq('Failed')
      end

      it 'return empty sheet error' do
        expect(import.reload.error).to eq('The sheet is empty')
      end
    end

    context 'when it is called using an invalid data sheet' do
      let(:file_path) { Rails.root.join('spec/fixtures/sheets/wrong_format_contacts.csv') }
      let(:import) { create :import }
      let(:user) { create :user }

      before do
        allow(Rails.root).to receive(:join).and_return(file_path)
        ImportService.new(user.id, import.id).import_contacts
      end

      it 'creates all sheet contacts' do
        expect(Contact.all.count).to eq(0)
      end

      it 'updates import status to finished' do
        expect(import.reload.status).to eq('Failed')
      end

      it 'return empty sheet error' do
        expect(import.reload.error).to include('phone in wrong format')
      end
    end
  end
end
