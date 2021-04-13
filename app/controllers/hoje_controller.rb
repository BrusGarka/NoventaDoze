class HojeController < ApplicationController
  def index
    # byebug
    @agora = Time.zone.now
    @trimestre = (@agora.month / 3.0).ceil
    @nascimento = Time.zone.parse("22/11/1993")
    diff = @agora - @nascimento
    @idade = (diff/60/60/24/365).round(1) #age
    @semanas_vividas = (diff/60/60/24/7).round(0)
    @expectativa = (((@nascimento + 72.years) - @agora)/60/60/24/7).round(0)
    @anos_restantes = age(@agora, @nascimento+72.years)
    # yday
    coletar_pensador
  end

  def age(inicial, final)
    final.year - inicial.year - ((final.month > inicial.month || (final.month == inicial.month && final.day >= inicial.day)) ? 0 : 1)
  end

  def coletar_pensador
    require 'mechanize'
    agent = Mechanize.new

    temas = ['frases_de_belchior', 'frases_de_fernando_pessoa']
    tema_escolhido = rand(0..(temas.count-1))
    homepage = agent.get("https://pensador.com/#{temas[tema_escolhido]}")

    paginas = homepage.css('div#paginacao > a').count - 1
    paginacao_escolhida = rand(0..paginas)

    pagina_escolhida = agent.get("https://pensador.com/#{temas[tema_escolhido]}/#{paginacao_escolhida}")
    card_frases = pagina_escolhida.css('div.thought-card').count + 1 
    card_escolhido = rand(2..card_frases)
    @frase_do_dia = pagina_escolhida.css("div.thought-card[#{card_escolhido}]>p").text
    @autor = pagina_escolhida.css("div.thought-card[#{card_escolhido}]>span>a").text
  end
end
