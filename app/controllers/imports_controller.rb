class ImportsController < ApplicationController
  require './app/services/import_service'

  before_action :set_import, only: %i[ show edit update destroy ]

  # GET /imports or /imports.json
  def index
    @imports = current_user.imports.page(params[:page]).per(5)
  end

  # GET /imports/1 or /imports/1.json
  def show
  end

  # GET /imports/new
  def new
    @import = Import.new
  end

  # GET /imports/1/edit
  def edit
  end

  # POST /imports or /imports.json
  def create
    @import = Import.new(import_params)

    respond_to do |format|
      if @import.save
        format.html { redirect_to import_url(@import), notice: "Import was successfully created." }
        format.json { render :show, status: :created, location: @import }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /imports/1 or /imports/1.json
  def update
    respond_to do |format|
      if @import.update(import_params)
        format.html { redirect_to import_url(@import), notice: "Import was successfully updated." }
        format.json { render :show, status: :ok, location: @import }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /imports/1 or /imports/1.json
  def destroy
    @import.destroy

    respond_to do |format|
      format.html { redirect_to imports_url, notice: "Import was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def import
    import_instance = Import.create(
      status: "On Hold", 
      user_id: current_user.id, 
      error:"", 
      filename: params[:file].original_filename
    )
    
    file = File.open(Rails.root.join("/tmp/#{params[:file].original_filename}"), 'w')
    file.write(params["file"].read)
    file.close

    ImportContactsJob.perform_async(current_user.id, import_instance.id)
    # ImportService.new(current_user.id, params["file"]).import_contacts
    # parsed_csv = CSV.read(params["file"], headers: true)
    # return if parsed_csv.count == 0

    # import_instance = Import.create(
    #   status: "On Hold", 
    #   user_id: current_user.id, 
    #   error:"", 
    #   filename: params["file"].original_filename
    # )
    
    # import_instance.update(status: "Processing")

    # parsed_csv.each do |row|
    #   contact = Contact.import_from_csv(row, current_user.id, import_instance.id)

    #   unless contact.save { import_instance.error << contact.errors.to_s }
    # end

    # import_instance.save

    # if import_instance.contacts.count > 0
    #   import_instance.update(status: "Finished")
    # else
    #   import_instance.update(status: "Failed")
    # end

    # if import_instance == "Finished"
    #   redirect_to root_path, notice: "Contacts imported successfully, status: Finished!"
    # else
    #   redirect_to root_path, alert: "Something serious happened, status: Failed"
    # end
    redirect_to root_path
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_import
      @import = Import.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def import_params
      params.require(:import).permit(:status, :error, :filename, :user_id)
    end
end