require "restclient"
require "crack"

class Blipmimoza
  attr_reader :dashboard, :tag, :bliposphere
  # Tworzy nowa klase, przy okazji sprawdzajac poprawnosc wprowadzonych danych
  def initialize(login, password)
    @login = login
    @password = password

    # Tablica z nickami uzytkownikow, ktorych wiadomosci zawieraly slowo 'anonim'
    @users = []

    # Przechowuje glowny zasob
    @blip = RestClient::Resource.new 'http://api.blip.pl', :user => @login, :password => @password, :accept => 'application/json', :headers => {:blip_api => 0.02}

    # Przechowuje poszczegolne zasoby
    @resources = {
      :dashboard => @blip['/dashboard'],
      :tag => @blip['/tags/anonim'],
      :bliposphere => @blip['/bliposphere']}

    # Sprawdza poprawnosc loginu i hasla
    @blip['/dashboard?limit=1'].get :accept => 'application/json'
  end

  # Odwiedza kokpit pojedynczego uzytkownika
  def get_dashboard_of(user)
    @blip["/users/#{user}/dashboard?limit=1"].get :accept => 'application/json'
  end

  # Pobiera wiadomosci z danego zasobu
  def messages_from(resource)
    resource = resource.to_sym
    raise ArgumentError, "Invalid resource - #{resource}" unless @resources.include?(resource)

    Crack::JSON.parse(@resources[resource].get :accept => 'application/json')
  end

  # Jesli wiadomosc zawiera slowo 'anonim' i powstala w przeciagu ostatnich 5 minut,
  # dodaje nick autora wiadomosci do tablicy @users
  def fetch_resources
    @resources.each_key do |resource|
      messages_from(resource).each do |msg|
        if (msg['body'].match(/anonim/i) and Time.parse(msg['created_at']) > Time.now - 300)
          @users.push(msg['user_path'].gsub('/users/', '')) 
        end
      end
    end
  end

  # Odwiedza kokpit kazdego uzytkownika z tablicy @users
  def fetch_users
    puts "Lista uzytkownikow jest pusta" if @users.empty?
    @users.uniq.each do |user|
      get_dashboard_of user
      puts "Odwiedzilem kokpit uzytkownika #{user}"
    end
    @users.clear
  end
end
