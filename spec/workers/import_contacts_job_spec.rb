# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportContactsJob, type: :worker do
  describe '#perform' do
    subject(:perform) { described_class.perform_now(user.id, import.id) }

    context 'when passing right params' do
      let(:import) { create :import }
      let(:user) { create :user }
      let(:import_service_instance) { instance_double(ImportService) }

      before do
        allow(ImportService).to receive(:new).and_return(import_service_instance)
        allow(import_service_instance).to receive(:import_contacts).and_return(true)
        perform
      end

      it 'calls ImportService' do
        expect(import_service_instance).to have_received(:import_contacts)
      end

      it 'calls with correct params' do
        expect(ImportService).to have_received(:new).with(user.id, import.id)
      end
    end
  end
end
