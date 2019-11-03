class ReporteShipments < Prawn::Document
  def initialize(info)
    super(:page_layout=> :landscape)

    @shipments = ["fjwkfj","fjwkfj","fjwkfj","fjwkfj","fjwkfj","fjwkfj","fjwkfj","fjwkfj"]


    header
    table_content

  end


  def header
    logo = "#{Rails.root}/app/assets/images/logo.jpg"
    image logo, :at => [25,540], :width => 130
    draw_text "Shipment Report",  :size => 30, :style => :bold, :at => [200, 480]
    draw_text "Fecha: " + (Time.now.strftime("%d/%m/%y")).to_s,  :size => 11, :style => :bold, :at => [645, 410]
  end

  def table_content

    bounding_box([-35, 400], :width => 800) do    
      table linea do
        # self.row_colors = ['FF0000', 'FFFFFF']
        self.column_widths = [800]
        self.column(0..2).style(:size => 13, :align => :center, :height => 30)
        self.cell_style = {:size => 7, :height =>2,  :align => :center, :padding => 3}
        row(0).column(0..-1).style :text_color => 'ffffff'
        row(0).column(0..9).font_style = :bold
        row(0).style :background_color => '000000'   
        row(0).style :border_color => '00FFFF'   
      end
    end


    bounding_box([-10, 370], :width => 900) do    
      table encabezado do

      # self.row_colors = ['FF0000', 'FFFFFF']
      self.column_widths = [20, 50, 80, 38, 38, 38, 38,38, 38,38, 38, 38, 38, 38, 175]
      self.column(0..2).style(:size => 13, :align => :center, :height => 30)
      self.cell_style = {:size => 8,  :align => :center, :padding => 3}
      row(0).column(0..-1).style :text_color => 'ffffff'
      row(0).column(0..-1).font_style = :bold
      row(0).style :background_color => '008080'
      
      end

      if shipments.present?
       table shipments do 
        self.row_colors = ['FFFFFF', 'eeecec']
        self.column_widths = [20, 50, 80, 38, 38, 38, 38,38, 38,38, 38, 38, 38, 38, 175]
        self.column(0..2).style(:size => 7, :align => :center)
        self.cell_style = {:size => 7, :align => :center, :padding => 3}
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
        "N°",
        "Carrier", 
        "Tracking number", 
        "Peso Vol. / Plataforma", 
        "Peso Vol Final / Plataforma",
        "Peso / Plataforma", 
        "Peso Final /Plataforma",
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
    @shipments.each_with_index do |t,indx|
      # {"tracking_number"=>"149331877648230", "carrier"=>"FEDEX", "parcel"=>{"length"=>29.7, "width"=>5, "height"=>21, "weight"=>2.0, "distance_unit"=>"CM", "mass_unit"=>"KG"}}
      # {"weight"=>24.13, "length"=>10.886208, "width"=>7.257472, "height"=>3.175144} permitted: false>}
      este_producto = [
                        (indx+1).to_s,
                        "FedEx",
                        231300687629630,
                        "0.6237", 
                        "1", 
                        "2.0", 
                        "2", 
                        "0.05017", 
                        "1",
                        "24.13", 
                        "25", 
                        "SI",
                        "24",
                        "SI",
                        "Tracking number not found contact client"
                      ]
      salida << este_producto
       este_producto = [
                        "FedEx",
                        231300687629630,
                        "0.6237", 
                        "1", 
                        "2.0", 
                        "2", 
                        "0.05017", 
                        "1",
                        "24.13", 
                        "25", 
                        "SI",
                        "24",
                        "NO",
                        "NA"
                      ]
    end

    salida
  end

end