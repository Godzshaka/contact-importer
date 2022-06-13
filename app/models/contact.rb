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
  validate :name_formatmport_from_csv
  validates :email, uniqueness: { scope: :user_id }

  # encrypts :credit_card
  @revealed_card_numbers = 4

  def self.import_from_csv(row, user_id, import_id)
    Contact.new(
      name: row['name'],
      address: row['address'],
      date_of_birth: row['date_of_birth'],
      phone: row['phone'],
      card_number_length: row['credit_card'].length - @revealed_card_numbers,
      card_last_digits: card_number_four_digits(row['credit_card']),
      credit_card: encrypt_credit_card(row['credit_card']),
      franchise: retrieve_franchise(row['credit_card']),
      email: row['e-mail'],
      user_id: user_id,
      import_id: import_id
    )
  end
  # params = {asdasd}.merge(eamil: errado)
  # contact = Contact.import_from_csv(params, user, import.id)
  # contact.validate.errors > 0

  private

  def self.card_number_four_digits(credit_card)
    credit_card[-@revealed_card_numbers..-1] || credit_card
  endmber_four_digits(credit_card)
  credit_card[-@revealed_card_numbers..-1] || credit_card
end

def self.encrypt_credit_card(credit_card_number)
  crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
  crypt.encrypt_and_sign(credit_card_number)
end

def self.retrieve_franchise(credit_card_number)
  detector = CreditCardValidations::Detector.new(credit_card_number)

  detector.brand.to_s

  def self.encrypt_credit_card(credit_card_number)
    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
    crypt.encrypt_and_sign(credit_card_number)
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
    unless date_of_birth.to_datetime.strftime('%F') == date_of_birth.to_s ||
           date_of_birth.to_datetime.strftime('%Y%m%d') == date_of_birth.to_s
      errors.add(
        :date_of_birth,
        "date of birth in wrong format,
        please use YYYY-MM-DD or YYYYMMDD format"
      )
    end
  end

  def phone_format
    regex = /^\(\+\d{2}\)\s\d{3}(\s|-)\d{3}(\s|-)\d{2}(\s|-)\d{2}$/

    unless phone.match(regex)
      errors.add(:phone, "phone in wrong format,
        please use (+00) 000-000-00-00 or
        (+00) 000 000 00 00 format")
    end
  end

  def email_format
    regex = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

    errors.add(:email, 'email is in wrong format') unless email.match(regex)
  end
end
