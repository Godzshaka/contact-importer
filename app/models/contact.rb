# frozen_string_literal: true

require 'time'
require 'openssl'

class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :import
  validates :name, presence: true
  validates :address, presence: true
  validates :date_of_birth, presence: true
  validates :phone, presence: true
  validates :credit_card, presence: true
  validates :email, presence: true
  validate :name_format
  validate :date_format
  validate :phone_format
  validate :email_format
  validates :credit_card, presence: true
  validates :email, uniqueness: { scope: :user_id }

  @revealed_card_numbers = 4

  def self.import_from_csv(row, user_id, import_id)
    Contact.new(
      name: row['name'],
      address: row['address'],
      date_of_birth: row['date_of_birth'],
      phone: row['phone'],
      card_number_length: hidden_credit_card_numbers(row['credit_card']),
      card_last_digits: card_number_four_digits(row['credit_card']),
      credit_card: encrypt_credit_card(row['credit_card']),
      franchise: retrieve_franchise(row['credit_card']),
      email: row['e-mail'],
      user_id: user_id,
      import_id: import_id
    )
  end

  private

  def self.hidden_credit_card_numbers(credit_card_number)
    begin
      credit_card_number.length - @revealed_card_numbers
    rescue
      nil
    end
  end

  def self.card_number_four_digits(credit_card)
    begin
      credit_card[-@revealed_card_numbers..-1] || credit_card
    rescue
      nil
    end
  end

  def self.encrypt_credit_card(credit_card_number)
    if credit_card_number.present?
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
      crypt.encrypt_and_sign(credit_card_number)
    end
  end

  def self.retrieve_franchise(credit_card_number)
    detector = CreditCardValidations::Detector.new(credit_card_number)
    detector.brand.to_s
  end
  # validations
  def name_format
    special = "?<>',?[]}{=)_(*&^%$#`~{}"
    regex = /[#{special.gsub(/./) { |char| "\\#{char}" }}]/
    errors.add(:name, 'name is null or name contains special character on row') if name.nil? || name.match(regex)
  end

  def date_format
    begin
      unless date_of_birth.to_datetime.strftime('%F') == date_of_birth.to_s ||
            date_of_birth.to_datetime.strftime('%Y%m%d') == date_of_birth.to_s
        errors.add(
          :date_of_birth,
          "date of birth in wrong format,
          please use YYYY-MM-DD or YYYYMMDD format"
        )
      end
    rescue
      errors.add(
          :date_of_birth,
          "The value for date is not a valid date"
        )
    end
  end
  
  def phone_format
    regex = /^\(\+\d{2}\)\s\d{3}(\s|-)\d{3}(\s|-)\d{2}(\s|-)\d{2}$/
    unless phone&.match(regex)
      errors.add(:phone, "phone in wrong format,
        please use (+00) 000-000-00-00 or
        (+00) 000 000 00 00 format")
    end
  end

  def email_format
    regex = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
    errors.add(:email, 'email is in wrong format') unless email&.match(regex)
  end
end