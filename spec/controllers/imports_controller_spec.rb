# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportsController, type: :controller do
  render_views
  describe 'GET index' do
    context 'as guest' do
      it 'redirects to login page' do
        get :index

        expect(response.status).to eq(302)
      end
    end

    context 'as logged user' do
      let(:user) { create :user }

      before do
        sign_in user
      end
      it 'returns a successfull response' do
        get :index

        expect(response.status).to eq(200)
      end

      context 'when importing a correct sheet' do
        csv = Rack::Test::UploadedFile.new('./spec/fixtures/sheets/successful_contacts.csv', 'text/csv')
        params = { file: csv, filename: 'successful_contacts.csv', content_type: 'text/csv' }

        it 'runs the job on background' do
          expect do
            post :import, params: params
          end.to have_enqueued_job(ImportContactsJob)
        end

        it 'creates an import' do
          post :import, params: params

          expect(Import.all.count).to eq(1)
        end
      end

      context 'when importing something other than a file' do
        params = { file: 2 }

        it 'does not run the job on background' do
          expect do
            post :import, params: params
          end.not_to have_enqueued_job(ImportContactsJob)
        end

        it 'returns an invalid file error' do
          post :import, params: params

          expect(response.body).to include('You uploaded an invalid file')
        end
      end
    end
  end
end
