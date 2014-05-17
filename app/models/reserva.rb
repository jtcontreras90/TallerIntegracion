require "google_drive"
class Reserva < ActiveRecord::Base
  
  def self.getReservasXSKU(sku)
    session=GoogleDrive.login('centralahorro@gmail.com','12qwaszx12qw')
    ws = session.spreadsheet_by_key("0As9H3pQDLg79dC1Dd1VJckF6eTZFc0Z4S1JqTW1UZmc").worksheets[0]
    reservas=0
    row=5
    celda=ws[row,1]
    while celda!="" do
      if "#{celda}"=="#{sku}"
        utilizados=0
        if ws[row,4]!=""
          utilizados=ws[row,4].to_i
        end
        reservas=reservas+ws[row,3].to_i-utilizados
      end
      row=row+1
      celda=ws[row,1]
    end
    return reservas
  end
  def self.getReservasXCliente(sku,rut)
    session=GoogleDrive.login('centralahorro@gmail.com','12qwaszx12qw')
    ws = session.spreadsheet_by_key("0As9H3pQDLg79dC1Dd1VJckF6eTZFc0Z4S1JqTW1UZmc").worksheets[0]
    reservas=0
    row=5
    celda=ws[row,1]
    while celda!="" do
      if "#{celda}"=="#{sku}" and "#{rut}"=="#{ws[row,2]}"
        utilizados=0
        if ws[row,4]!=""
          utilizados=ws[row,4].to_i
        end
        reservas=reservas+ws[row,3].to_i-utilizados
      end
      row=row+1
      celda=ws[row,1]
    end
    return reservas
  end
  def self.quitarReservasXCliente(sku,rut,cantidad)
    session=GoogleDrive.login('centralahorro@gmail.com','12qwaszx12qw')
    ws = session.spreadsheet_by_key("0As9H3pQDLg79dC1Dd1VJckF6eTZFc0Z4S1JqTW1UZmc").worksheets[0]
    row=5
    celda=ws[row,1]
    while celda!="" do
      if "#{celda}"=="#{sku}" and "#{rut}"=="#{ws[row,2]}"
        utilizados=0
        if ws[row,4]!=""
           utilizados=ws[row,4].to_i
        end
          ws[row,4]=(utilizados+cantidad).to_s
      end
      row=row+1
      celda=ws[row,1]
    end
    ws.save()
  end
end