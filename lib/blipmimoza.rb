require "restclient"
require "crack"

class Blipmimoza
  attr_reader :dashboard, :tag, :bliposphere
  # Tworzy nową klasę, przy okazji sprawdzając poprawność wprowadzonych danych
  def initialize(login, password)
    @login = login
    @password = password

    # Tablica z nickami użytkowników, których wiadomości zawierały słowo 'anonim'
    @users = []

    # Przechowuje główny zasób
    @blip = RestClient::Resource.new 'http://api.blip.pl', :user => @login, :password => @password, :accept => 'application/json', :headers => {:blip_api => 0.02}

    # Przechowuje poszczególne zasoby
    @resources = {
      :dashboard => @blip['/dashboard'],
      :tag => @blip['/tags/anonim'],
      :bliposphere => @blip['/bliposphere']}

    # Sprawdza poprawność loginu i hasła
    @blip['/dashboard?limit=1'].get :accept => 'application/json'
  end

  def get_dashboard_of(user)
    @blip["/users/#{user}/dashboard?limit=1"].get :accept => 'application/json'
  end

  def messages_from(resource)
    resource = resource.to_sym
    raise ArgumentError, "Invalid resource - #{resource}" unless @resources.include?(resource)

    Crack::JSON.parse(@resources[resource].get :accept => 'application/json')
  end

  def fetch_resources
    @resources.each_key do |resource|
      messages_from(resource).each do |msg|
        # Jeśli wiadomość zawiera słowo 'anonim' i powstała w przeciągu ostatnich 5 minut,
        # dodaj nick autora wiadomości do tablicy @users
        if (msg['body'].match(/anonim/i) and Time.parse(msg['created_at']) > Time.now - 300)
          @users.push(msg['user_path'].gsub('/users/', '')) 
        end
      end
    end
  end

  def fetch_users
    puts "Lista uzytkownikow jest pusta" if @users.empty?
    @users.uniq.each do |user|
      get_dashboard_of user
      puts "Odwiedzilem kokpit uzytkownika #{user}"
    end
    @users.clear
  end
end
