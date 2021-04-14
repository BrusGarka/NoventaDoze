class HojeController < ApplicationController
  def index
    # byebug
    @passou_param = params[:date].present?
    if !@passou_param
      params[:date] = '22-11-1993'
    end

    @agora = Time.zone.now
    @trimestre = (@agora.month / 3.0).ceil
    @nascimento = Time.zone.parse(params[:date])
    diff = @agora - @nascimento
    @idade = (diff/60/60/24/365).round(1) #age
    @semanas_vividas = (diff/60/60/24/7).round(0)
    @expectativa = (((@nascimento + 72.years) - @agora)/60/60/24/7).round(0)
    @anos_restantes = age(@agora, @nascimento+72.years)
    # yday
    coletar_pensador params[:date]
  end

  def age(inicial, final)
    final.year - inicial.year - ((final.month > inicial.month || (final.month == inicial.month && final.day >= inicial.day)) ? 0 : 1)
  end

  def coletar_pensador data
    require 'mechanize'
    agent = Mechanize.new

    temas = ['frases_chorao', 'frases_de_belchior', 'frases_de_fernando_pessoa', 'leon_tolstoi', 'soren_kierkegaard', 'carlos_drummond_de_andrade']
    if data == '23-06-1995'
      tema_escolhido = 0
    else
      tema_escolhido = rand(0..(temas.count-1))
    end
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
