class RequestController < ApplicationController

	skip_before_action :verify_authenticity_token, :only => [:read, :validar_json]

  def index
  	# saludo = Operaciones.prueba 
  	# puts saludo
  end

  def validar_json
    if params["_json"].present?
      puts "val el json"
      # puts params["_json"].class
      raw_data =  params["_json"]
      raw_data = raw_data.to_json
      data = JSON.parse raw_data
      puts data
      puts data.class
      puts data[0].class

      resultado = Operaciones.ValidarJson(data)
      if resultado == 200
        puts "El JSON es correcto !!!"
        file_name = "datos_reporte.json"
        raw_data = data.to_json
        open(file_name, 'wb') do |file|
          file.write(raw_data)
        end
      end
    else
      resultado = 404
    end

    respond_to do |format|
      format.json { render json: resultado }
    end
  end

  def read

    data = File.read("datos_reporte.json")
    puts "obtuvimos el file y es"
    puts data
    puts data.class
    raw_data = JSON.parse data
    puts raw_data.class
    salida = Operaciones.requestFedex(raw_data)
    la_data = salida[1].to_json
    puts "la data fainl obtenida es "
    puts la_data

    file_name = "datos_reporte.json"
    open(file_name, 'wb') do |file|
      file.write(la_data)
    end
      
    if salida[0] == 200
      render status: 200, json: { datos: salida }.to_json
    else
      render status: 400, json: {datos: "Fedex Error",}.to_json
    end
  end

  def reporte_pdf
    puts "los params para report son"
    puts params
    nombre_pdf = "Reporte Sobre Peso"

    raw_data = File.read("datos_reporte.json")
    data = JSON.parse raw_data
    puts "antes de enviar la data la data es"
    puts data
    pdf = ReporteShipments.new(data)
    send_data pdf.render, filename: nombre_pdf, type: 'application/pdf', disposition: "inline"
  end

  private

  def request_params
    params.permite(:_json)
  end
end
