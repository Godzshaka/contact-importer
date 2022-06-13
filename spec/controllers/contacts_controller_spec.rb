# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/devise'

RSpec.describe ContactsController, type: :controller do
  render_views
	describe "GET index" do
  	context 'as guest' do
      it 'redirects to login page' do
        get :index
        
        expect(response.status).to eq(302)
      end
    end

    context 'as logged user' do
      let(:user){create :user}

      before do
        sign_in user
      end
      it 'returns a successfull response' do
        get :index

        expect(response.status).to eq(200)
      end
      context 'when the user has contacts' do
        let(:contact){create :contact, user: user}
        before do
          contact.reload
        end
        # let(:contact) {build :contact, email:'batata'}
        # c = Contact.new(asdjaskld)
        # c.validate
        # c.save

        it 'shows contacts for this user' do
          get :index
          
          expect(response.body).to include(contact.name)
        end
 
        context 'when there are other users contacts' do
          let(:other_contact){create :contact}

          before do
            other_contact.reload
          end

          it 'doesnt show other user contacts' do
            get :index
            
            expect(response.body).not_to include(other_contact.name)
          end
        end
      end
    end
  end
end
