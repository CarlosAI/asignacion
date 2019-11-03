class RequestController < ApplicationController

	skip_before_action :verify_authenticity_token, :only => [:read]

  def index
  	# saludo = Operaciones.prueba 
  	# puts saludo
  end

  def read
  	puts "entro y params son"
  	puts params
  	salida = 200

    if params["_json"].present?
      salida = Operaciones.requestFedex(params["_json"])
      puts "ok" 
      puts "la salida antes de file es"
      puts salida[1]
      la_data = salida[1].to_json
      puts "la data es"
      puts la_data
      file_name = "prueba_2.json"
      open(file_name, 'wb') do |file|
        file.write(la_data.to_json)
      end



      data = File.read(file_name)

      puts "Conseguimos la data y es"
      puts data


    else
      salida = 404
    end


    puts "la salida es"
    puts salida
    if salida[0] == 200
      salida = salida.to_json
      render status: 200, json: {
        datos: salida, code: 200
      }.to_json
    elsif salida == 404
      render status: 201, json: {
        datos: "No seleccionaste los datos correctos", code: 202,
      }.to_json
    else
      render status: 400, json: {datos: "Internal Server Error",}.to_json
    end
  end

  def reporte_pdf
    puts "los params para report son"
    puts params
    # respond_to do |format|
    #   format.pdf do
    #     pdf = Prawn::Document.new
    #     pdf.text "Hellow World!"
    #     send_data pdf.render,
    #       filename: "export.pdf",
    #       type: 'application/pdf',
    #       disposition: 'inline'
    #   end
    # end
      # # puts skus
      nombre_pdf = "reporte"

      # respond_to do |format|
        # format.json { render json: [] }
        #format.html
        # format.pdf do
        # respond_to do |format|
        #   format.pdf do
            pdf = ReporteShipments.new("hola")
            # file_name = pdf.render
            # pdf = Base64.decode64 file_name
            # puts pdf

            # puts "el pdf es"
            # file_name = "prueba_2.pdf"
            # open(file_name, 'wb') do |file|
            #   file.write(pdf)
            # end
            # puts file_name
            send_data pdf.render, filename: nombre_pdf, type: 'application/pdf', disposition: "inline"
        #   end
        # end
  end
end
