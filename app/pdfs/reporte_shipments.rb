class ReporteShipments < Prawn::Document
  def initialize(data)
    super(:page_layout=> :landscape)

    puts data
    @shipments = data
    @shipments_error = []
    @shipments_without = []

    header
    table_content
    footer
    render_file('prawn.pdf')
  end

  def footer
    bounding_box([25,30], :width => 800) do
      green = "#{Rails.root}/app/assets/images/green.png"
      red = "#{Rails.root}/app/assets/images/red.png"
      gray = "#{Rails.root}/app/assets/images/gray.png"
      image green, :at => [-35,20], :width => 25
      bounding_box([-35,0], :width => 25, :height => 14) do
        stroke_bounds
        image gray, :width => 25
      end
      image red, :at => [-35, -6], :width => 25
      draw_text "Sobre peso NO incurrido o diferencia de peso en negativo", :size => 5, :at => [0, 25],:style => :bold
      draw_text "Sobre peso Incurrido", :size => 5, :at => [0, 5],:style => :bold
      draw_text "Error en la guia", :size => 5, :at => [0, -15],:style => :bold
      # curve [50,100], [100,100], :bounds => [[90,90],[75,75]]
    end
  end

  def header
    logo = "#{Rails.root}/app/assets/images/logo.png"
    image logo, :at => [-10,570], :width => 70
    draw_text "Shipment Report",  :size => 30, :style => :bold, :at => [225, 530]
    draw_text "Informe de Sobre Peso",  :size => 10, :style => :bold, :at => [295, 520]
    draw_text "Fecha: " + (Time.now.strftime("%d/%m/%y")).to_s,  :size => 11, :style => :bold, :at => [660, 520]
    draw_text "Generado por: Carlos Alberto Ivan Carreon Silva",  :size => 6, :style => :bold, :at => [605, 510]
  end

  def table_content

    bounding_box([-35, 500], :width => 800) do    
      table linea do
        # self.row_colors = ['FF0000', 'FFFFFF']
        self.column_widths = [800]
        self.column(0..2).style(:size => 13, :align => :center, :height => 30)
        self.cell_style = {:size => 7, :height =>2,  :align => :center, :padding => 3}
        row(0).column(0..-1).style :text_color => 'ffffff'
        row(0).column(0..-1).font_style = :bold
        row(0).style :background_color => '000000'   
        row(0).style :border_color => '00FFFF'   
      end
    end


    bounding_box([-10, 490], :width => 900) do    
      table encabezado do

      # self.row_colors = ['FF0000', 'FFFFFF']
      self.column_widths = [50, 85, 38, 38, 38, 38,38, 38,38, 38, 38, 38, 38, 190]
      self.column(0..2).style(:size => 13, :align => :center, :height => 30)
      self.cell_style = {:size => 8,  :align => :center, :padding => 3}
      row(0).column(0..-1).style :text_color => 'ffffff'
      row(0).column(0..-1).font_style = :bold
      row(0).style :background_color => '008080'
      
      end

      if shipments.present?
       table shipments do 
        self.row_colors = ['eeecec']
        self.column_widths = [50, 85, 38, 38, 38, 38,38, 38,38, 38, 38, 38, 38, 190]
        self.column(0..2).style(:size => 8, :align => :center)
        self.cell_style = {:size => 8, :align => :center, :padding => 3}
       end
      end

      if shipments_without.present?
       table shipments_without do 
        self.row_colors = ['09fa02']
        self.column_widths = [50, 85, 38, 38, 38, 38,38, 38,38, 38, 38, 38, 38, 190]
        self.column(0..2).style(:size => 8, :align => :center)
        self.cell_style = {:size => 8, :align => :center, :padding => 3}
       end
      end

      if shipments_error.present?
         table shipments_error do 
          self.row_colors = ['de5a4d']
          self.column_widths = [50, 85, 38, 38, 38, 38,38, 38,38, 38, 38, 38, 38, 190]
          self.column(0..-1).style(:size => 8, :align => :center)
          self.cell_style = {:size => 8, :align => :center, :padding => 3}
          # self.row(0..-1).column(0..-1).style :text_color => 'FFFFFF'
         end
      end
      

    end
  end

  def linea
    [
      [
        ""
      ]
    ]
  end

  def encabezado
    [
      [
        "Carrier", 
        "Tracking number", 
        "Peso Vol. / Plataforma", 
        "Peso Vol Final / Plataforma",
        "Peso / Plataforma", 
        "Peso Final",
        "Peso Vol. Fedex", 
        "Peso Vol. Final Fedex",
        "Peso Real Fedex", 
        "Peso Real Final Fedex",
        "Sobre Peso", 
        "Valor Sobre Peso",
        "Error",
        "Descripcion"
      ]
    ]
  end

  def shipments
    salida = []
    @shipments.each do |shp|
      # puts "shipments es #{@shipments.size}"
      puts "vamos con el trackin #{shp["tracking_number"]}"
      if shp["errors"].present?
        @shipments_error << shp
        # puts "\n\n\nshipmentos error al momento es"
        # puts @shipments_error
        next
      else
        pesoV = ((shp["parcel"]["length"]*shp["parcel"]["width"]*shp["parcel"]["height"])/5000.to_f)
        pesoKG = shp["parcel"]["weight"].to_f
        pesoVFdx = ((shp["fedex_parcel"]["length"]*shp["fedex_parcel"]["width"]*shp["fedex_parcel"]["height"])/5000.to_f).truncate(5)
        pesoKGFdx = (shp["fedex_parcel"]["weight"].to_f).truncate(5)
        peso_final = [pesoV.ceil, pesoKG.ceil].max
        if pesoKGFdx.ceil <= peso_final
          puts "vamos con shipment without"
          @shipments_without << shp
          next
        end
       
        row = [
                shp["carrier"],
                shp["tracking_number"],
                pesoV.to_s, 
                pesoV.ceil.to_s, 
                pesoKG, 
                peso_final.to_s, 
                pesoVFdx.to_s, 
                pesoVFdx.ceil.to_s,
                pesoKGFdx.to_s, 
                pesoKGFdx.ceil.to_s, 
                if pesoKGFdx.ceil != peso_final then "SI" else "NO" end,
                if pesoKGFdx.ceil != peso_final then (pesoKGFdx.ceil - peso_final).ceil.to_s else "0" end,
                "NO",
              ]
        salida << row
      end
    end
    salida
  end

  def shipments_without
    salida = []
    puts "Shipment wtihout es #{@shipments_without.size}"
    @shipments_without = @shipments_without.uniq
    @shipments_without.each do |shp|
      # puts "shipments es #{@shipments.size}"
      puts "vamos con el trackin #{shp["tracking_number"]}"
      if shp["errors"].present?
        @shipments_error << shp
        # puts "\n\n\nshipmentos error al momento es"
        # puts @shipments_error
        next
      else
        pesoV = ((shp["parcel"]["length"]*shp["parcel"]["width"]*shp["parcel"]["height"])/5000.to_f)
        pesoKG = shp["parcel"]["weight"].to_f
        pesoVFdx = ((shp["fedex_parcel"]["length"]*shp["fedex_parcel"]["width"]*shp["fedex_parcel"]["height"])/5000.to_f).truncate(5)
        pesoKGFdx = (shp["fedex_parcel"]["weight"].to_f).truncate(5)
        peso_final = [pesoV.ceil, pesoKG.ceil].max
       
        row = [
                shp["carrier"],
                shp["tracking_number"],
                pesoV.to_s, 
                pesoV.ceil.to_s, 
                pesoKG, 
                peso_final.to_s, 
                pesoVFdx.to_s, 
                pesoVFdx.ceil.to_s,
                pesoKGFdx.to_s, 
                pesoKGFdx.ceil.to_s, 
                if pesoKGFdx.ceil != peso_final then "SI" else "NO" end,
                if pesoKGFdx.ceil != peso_final then (pesoKGFdx.ceil - peso_final).ceil.to_s else "0" end,
                "NO",
              ]
        salida << row
        # @shipments.pop
      end
    end
    salida
  end

  def shipments_error
    salida = []
    puts "shipmentos error es #{@shipments_error.size}"
    @shipments_error = @shipments_error.uniq
    # @shipments_error = @shipments_error*10
    @shipments_error.each do |shp, indx|
      pesoV = ((shp["parcel"]["length"]*shp["parcel"]["width"]*shp["parcel"]["height"])/5000.to_f)
      pesoKG = shp["parcel"]["weight"].to_f
      peso_final = [pesoV.ceil, pesoKG.ceil].max
      error = shp["errors"].first
      row = [
              shp["carrier"],
              shp["tracking_number"],
              pesoV.to_s, 
              pesoV.ceil.to_s, 
              pesoKG, 
              peso_final.to_s, 
              "N/A", 
              "N/A",
              "N/A", 
              "N/A", 
              "N/A",
              "N/A",
              "SI",
              error[1]
            ]
      salida << row
    end
    salida
  end

end