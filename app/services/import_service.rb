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

    if parsed_csv.count.zero?
      import.update(status: 'Failed')
      import.error << 'The sheet is empty'
      import.save
      return
    end

    import.update(status: 'Processing')

    parsed_csv.each_with_index do |row, index|
      contact = Contact.import_from_csv(row, @user_id, import.id)

      import.error << "Error on row number #{index + 2}" unless contact.save
      import.error << contact.errors.messages.to_s unless contact.save
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
