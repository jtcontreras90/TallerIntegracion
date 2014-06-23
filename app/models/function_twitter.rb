#!/usr/bin/env ruby
require 'rubygems'
require 'googl'
require 'twitter'

#Para twittear llamar FunctionTwitter.twittear(sku,precio,fecha_de_termino)

class FunctionTwitter

	@@key = 'YqLJXIWScxny9EiJXSNW2MKpG'
  @@secret= '3CyB2RrV4d44bNS08snBDmyAXALMEu7axVNG4Q5Y0miCZGyv9l'

  def self.Auntentificar_REST
  
    client_rest = Twitter::REST::Client.new do |config|
        config.consumer_key        = @@key
        config.consumer_secret     = @@secret
        config.access_token        = "2559550507-LG3k3ChNtgRMJwyKPukH51RaOWsZI0BNLQ7kvvg"
        config.access_token_secret = "3iNZim5pj4RceHEvMcQawRhuUc7sbJDt9kUkOcJmH0zaD"
    end
    return client_rest

  end

  def self.publicar
    Oferta.where('publicado = ? and fecha_inicio < ?',false,DateTime.now).each do |o|
      begin
        puts "entra acá"
        FunctionTwitter.twittear(o.sku,o.precio,o.fecha_termino)
        o.publicado=true
        o.save
      rescue
      end
    end    
  end

  def self.Auntentificar_Streaming
      
    client_streaming = Twitter::Streaming::Client.new do |config|
        config.consumer_key        = @@key
        config.consumer_secret     = @@secret
        config.access_token        = "2559550507-LG3k3ChNtgRMJwyKPukH51RaOWsZI0BNLQ7kvvg"
        config.access_token_secret = "3iNZim5pj4RceHEvMcQawRhuUc7sbJDt9kUkOcJmH0zaD"
    end
    return client_streaming
  end

  def self.twittear(sku, precio, fecha_termino)
    name=""
    url=""
    url_imagen=""
    file = 0

    begin
      path_imagen = Spree::Variant.where(sku: sku).first.product.images.first.attachment.path
      file = File.new(path_imagen)
    rescue Exception => e  
      begin
        aux = Spree::Variant.where(sku: sku).first.product.images.first.attachment.url
        aux1 = "integra9.ing.puc.cl#{aux}"
        url_imagen = Googl.shorten(aux1).short_url
        puts "integra9.ing.puc.cl#{aux}"
        puts url_imagen
        url_imagen1 = " #{url_imagen}."
      rescue Exception => e
        puts "No se encontró url de imagen para este producto"
      
      end
      puts "No se encontró imagen para este producto"

    end

    begin
      name = Spree::Variant.where(sku: sku).first.product.name
    rescue Exception => e
      puts "No se encontró nombre para el producto de sku: #{sku}"
    end

    begin
      slug = Spree::Variant.where(sku: sku).first.product.slug
      aux = "integra9.ing.puc.cl/products/#{slug}" 
      puts "integra9.ing.puc.cl/products/#{slug}"
      url = Googl.shorten(aux).short_url
      puts url
      url1= " #{url},"
    rescue Exception => e
      puts "No se encontró slug para el producto de sku: #{sku}"
    end



    post = "#ofertagrupo9 !#{url1}#{url_imagen1} (Válido hasta #{fecha_termino.strftime("%e/%-m/%y %H:%M")}) a sólo $#{precio} el producto #{name}."
    puts post
    if post.length > 140
      post = "#{post[0,134]}..."
    end
    puts post
    FunctionTwitter.tweet(post,file)

  end

  def self.tweet(post,imagen)

    client_rest = self.Auntentificar_REST
    if imagen and imagen!=0 and imagen!=""
      begin
        response=client_rest.update_with_media("#{post}", imagen) 
      rescue
        response=client_rest.update(post)
      end
    else  
      puts post.length
      puts post
      client_rest.update(post)
    end

  end

  def self.timelineEntenera
    client_rest = self.Auntentificar_REST
    tweets = {}
    cont=0
    client_rest.user_timeline("C_Ahorro_G9").collect do |tweet|
        tweets[cont]={fecha: tweet.created_at.to_s[0..18], texto: tweet.text}
        puts tweets[cont]
        cont+=1
    end            

  end

  def self.MostrarTimeline(user,cant)

    client_rest = self.Auntentificar_REST
    client_rest.user_timeline(user).take(cant).collect do |tweet|
        puts "#{tweet.user.screen_name}: #{tweet.text}"
    end    
    return client_rest.user_timeline(user).take(cant).collect
  end

  def self.EsperarTweet
    
    client_streaming.user do |object|
        case object
        when Twitter::Tweet
          puts "It's a tweet!"
          puts "#{object.user.screen_name}: #{object.text}"
      when Twitter::DirectMessage
        puts "It's a direct message!"
        when Twitter::Streaming::StallWarning
          warn "Falling behind!"
        end
    end
  end


	def self.run

    #self.twittear(3478040, 2000, "16/06/2014")

    client_rest = self.Auntentificar_REST


    dayhash = {}
    timeline = client_rest.user_timeline("C_Ahorro_G9", :count => 200 )
    timeline.each do |t|

      tweetday = t.created_at.to_s[0..9]
      if dayhash[tweetday]==nil
        dayhash[tweetday]={}
        dayhash[tweetday]["cont"]=0
      end
      cont = dayhash[tweetday]["cont"]
      dayhash[tweetday][cont] = t.text
      dayhash[tweetday]["cont"]+=1
      puts tweetday

    end

		#client_rest.update_with_media("Se viene el mundial <3", File.new("image.jpg"))
		client_rest.home_timeline.take(3).collect do |tweet|
  			puts "#{tweet.user.screen_name}: #{tweet.text}"
		end

    #self.MostrarTimeline("C_Ahorro_G9",6)
    self.timelineEntenera

    puts dayhash["2014-06-12"]


	end
 
end