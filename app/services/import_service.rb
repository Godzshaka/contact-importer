# frozen_string_literal: true

class ImportService
  def initialize(user_id, import_id)
    @user_id = user_id
    @import_id = import_id
  end

  def import_contacts
    import = Import.find(@import_id)
    file_name = Rails.root.join("/tmp/#{import.filename}")
    parsed_csv = CSV.read(file_name, headers: true)

    return if parsed_csv.count.zero?

    import.update(status: 'Processing')

    parsed_csv.each do |row|
      contact = Contact.import_from_csv(row, @user_id, import.id)

      import.error << contact.errors.to_s unless contact.save
    end

    import.save
    if import.contacts.count.positive?
      import.update(status: 'Finished')
    else
      import.update(status: 'Failed')
    end

    import.status
  end
end
