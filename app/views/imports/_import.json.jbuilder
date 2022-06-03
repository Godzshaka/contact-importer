# frozen_string_literal: true

json.extract! import, :id, :status, :error, :filename, :user_id, :created_at, :updated_at
json.url import_url(import, format: :json)
