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
  	runner "Pedido.cargar" #ok
end

every 2.hours do 
	runner "Pedido.preguntarPedidosPendientes" #revisar conexión con otros. Funciona en 1 de 3 grupos
											   #revisar despacharStock de ApiBodega. Por alguna razón se cae
end


every 15.minutes do
 	runner "Bodega.enviarProducto" #ok
end

every 3.hours do
  	runner "ApiBodega.vaciarBodegaRecepcion" #ok
end

every 2.hours do
	runner "ApiBodega.vaciarBodegaPulmon" #ok
end

every :day, :at => '11:57pm' do
  	runner "Venta.generarReportes"
	runner "ApiBodega.reportarBPulmonDw" #ok
end
every :day, :at => '4:30 am' do
	runner "Database.accdb_to_csv" #ok
end
