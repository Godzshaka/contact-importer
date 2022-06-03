# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BpeGeneratorSingleWorker, type: :worker do
  let(:worker) { described_class.new }
  let(:order) { build(:order) }

  it { is_expected.to be_retryable 2 }

  it 'raises error when order does not exist' do
    expect(ReservedSeat.count).to eq 0
    expect do
      BpeGeneratorSingleWorker.new.perform(1)
    end.to raise_error { ActiveRecord::RecordNotFound }
  end

  context 'when order exists' do
    let(:seat) { create_order(:approved).seats.first }

    before do
      seat.update_columns sale_number: nil, ticket_number: nil, bpe: nil, bpe_url: nil
      expect(SidekiqJob.find_by(job: 'BpeGeneratorSingleWorker')).to be_nil
    end

    after do
      expect(SidekiqJob.where(job: 'BpeGeneratorSingleWorker').size).to eq 1
    end

    context 'and bpe is expected' do
      before do
        allow_any_instance_of(ReservedSeat).to receive(:expect_bpe?).and_return(true)
      end

      context 'and operator returns BPE' do
        it 'persists bpe URL' do
          mock_operator_api do
            BpeGeneratorSingleWorker.new.perform(seat.id)
          end
          expect(seat.reload.bpe_url).to be_present
          expect(seat.reload.sale_number).to be_present
          expect(seat.reload.ticket_number).to be_present
          expect(seat.reload.bpe_generated_at).to be_present
          expect(SidekiqJob.find_by(job: 'BpeGeneratorSingleWorker')).to be_success
        end
      end

      context 'and operator does not return BPe' do
        it 'sends e-mail to suporte@arcasoltec.com.br and persists returned information' do
          VCR.use_cassette 'princesa/sales/empty_bpe', match_requests_on: %i[path] do
            expect(FailedBpeMailer).to receive(:backoffice).and_call_original
            BpeGeneratorSingleWorker.new.perform(seat.id)
            seat.reload
            expect(seat.sale_number).to be_present
            expect(seat.ticket_number).to be_present
            expect(seat.bpe_url).to_not be_present
            expect(seat.boarding_code).to_not be_present
          end
        end
      end

      context 'and operator API fails' do
        # TODO: It is replacing disabled retries
        it 'flag the seat as ticket_error' do
          VCR.use_cassette('princesa/sales/failed_bpe', match_requests_on: %i[path]) do
            BpeGeneratorSingleWorker.new.perform(seat.id)
          end

          expect(seat.reload.status).to eq('ticket_error')
        end

        # TODO: Retries are disabled temporary
        context 'for the first or second time' do
          xit 'does not create pipefy card' do
            expect(PipefyCardMailer).to_not receive(:create_card)

            2.times do
              VCR.use_cassette 'princesa/sales/failed_bpe', match_requests_on: %i[path], allow_playback_repeats: true do
                expect do
                  Sidekiq::Testing.inline! do
                    BpeGeneratorSingleWorker.new.perform(seat.id)
                  end
                end.to raise_error(BpeGeneratorService::BpeApiError)
              end
            end
          end
        end

        # TODO: Retries are disabled temporary
        context 'for the third time' do
          xit 'created card on pipefy' do
            expect(PipefyCardMailer).to(
              receive(:create_card).twice.and_call_original
            )

            3.times do
              VCR.use_cassette 'princesa/sales/failed_bpe', match_requests_on: %i[path], allow_playback_repeats: true do
                expect do
                  Sidekiq::Testing.inline! do
                    BpeGeneratorSingleWorker.new.perform(seat.id)
                  end
                end.to raise_error(BpeGeneratorService::BpeApiError)
              end
            end

            expect(seat.reload.status).to eq('pending_boarding')
          end
        end
      end
    end

    context 'and bpe is NOT expected' do
      it 'persists bpe URL' do
        mock_operator_api do
          BpeGeneratorSingleWorker.new.perform(seat.id)
        end
        expect(seat.reload.bpe_url).to be_present
        expect(seat.reload.sale_number).to be_present
        expect(seat.reload.ticket_number).to be_present
      end
    end
  end

  describe '.handle_error!' do
    let!(:order) { create_order(:approved) }

    it 'set seat with status ticket_error' do
      seat = order.seats.first

      VCR.use_cassette('wirecard/refund_payment') do
        VCR.use_cassette('wirecard/get_payment_authorized') do
          BpeGeneratorSingleWorker.handle_error!(order.seats.first.id)
        end
      end

      expect(seat.reload.status).to eq('ticket_error')
    end
  end
end
