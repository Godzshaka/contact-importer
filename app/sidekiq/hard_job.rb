# frozen_string_literal: true

class HardJob
  include Sidekiq::Job

  def perform(*args)
    # Do something
  end
end
