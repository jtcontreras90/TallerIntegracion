# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Bodega.create([{name: 'grupo1', password: 'KB74LrBL'},
               {name: 'grupo2', password: '89yFuPvQ'},
               {name: 'grupo3', password: 'HrjVuCJC'},
               {name: 'grupo4', password: 'nf4mnAmt'},
               {name: 'grupo5', password: 'deB96hkU'},
               {name: 'grupo6', password: 'FYCBFpTt'},
               {name: 'grupo7', password: 'LRZjGEM5'},
               {name: 'grupo8', password: 'crtwjh4J'}])

#Spree::Core::Engine.load_seed if defined?(Spree::Core)
#Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
