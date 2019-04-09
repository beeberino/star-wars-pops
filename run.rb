require 'httparty'

class Planet
  attr_reader :name, :residents

  def initialize(name, residents)
    @name = name
    @residents = residents
  end

  def resident_names
    residents.map(&:name)
  end
end

class Person
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

def deserialize_results(results)
  results.map do |result|
    planet_name = result['name']
    residents = result['residents'].map do |link|
      person_name = HTTParty.get(link)['name']
      Person.new(person_name)
    end
    Planet.new(planet_name, residents)
  end
end

def get_planets(planets=[], page=1)
  response = HTTParty.get("https://swapi.co/api/planets/?page=#{page}")
  results = response['results']
  planets << deserialize_results(results) if results
  if response['next']
    get_planets(planets, page + 1) 
  else
    planets
  end
end

puts 'Fetching data...'
planets = get_planets.flatten
loop do
  puts 'Which of the following planets would you like to explore?'
  puts planets.map(&:name)
  planet_name = gets.chomp
  puts "The planet #{planet_name} birthed the following individuals:"
  puts planets.find { |planet| planet.name == planet_name }.resident_names
  puts "Would you like to explore another planet (Y/N)?"
  continue = gets.chomp.upcase
  break if continue == 'N'
end