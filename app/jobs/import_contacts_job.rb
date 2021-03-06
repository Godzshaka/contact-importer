# frozen_string_literal: true

class ImportContactsJob < ApplicationJob
  # include Sidekiq::Job
  # include Sidekiq::Worker

  def perform(user_id, import_id)
    ImportService.new(user_id, import_id).import_contacts
  end
end
