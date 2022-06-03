class ImportService
	def initialize(user_id, import_id)
		@user_id = user_id
		@import_id = import_id
	end

	def import_contacts
		import = Import.find(@import_id)
		file_name = Rails.root.join("/tmp/#{import.filename}")
		parsed_csv = CSV.read(file_name, headers: true)

		return if parsed_csv.count == 0

		import.update(status: "Processing")

		parsed_csv.each do |row|
		  contact = Contact.import_from_csv(row, @user_id, import.id)

		  unless contact.save 
		  	import.error << contact.errors.to_s
		  end
		end

		import.save
		if import.contacts.count > 0
		  import.update(status: "Finished")
		else
		  import.update(status: "Failed")
		end

		return import.status
	end
end