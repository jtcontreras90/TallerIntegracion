# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
# Learn more: http://github.com/javan/whenever
every 10.minutes do
  	runner "Pedido.cargar" #ok - no cargó ningun stfp porque no habían disponibles
end

every 2.hours do 
	runner "Pedido.preguntarPedidosPendientes" #ok - revisar conexión con otros
end


every 15.minutes do
 	runner "Bodega.enviarProducto" #ok - no se envió nada porque no habían pendientes
end

every 3.hours do
  	runner "ApiBodega.vaciarBodegaRecepcion" #ok
end

every 2.hours do
	runner "ApiBodega.vaciarBodegaPulmon" #ok
end

every :day, :at => '11:57pm' do
	runner "ApiBodega.reportarBPulmonDw" #Pendiente
end
every :day, :at => '4:30 am' do
	runner "Database.readcsv"
end
