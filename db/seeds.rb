# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require "open-uri"
require "yaml"

puts 'Cleaning DB...'

Movie.destroy_all
Director.destroy_all
TvShow.destroy_all

puts 'DB Clean!!!'
# WHAT IS A SLUG????? 
# - a slug is a unique identifier for the resource.

file = "https://gist.githubusercontent.com/juliends/461638c32c56b8ae117a2f2b8839b0d3/raw/3df2086cf31d0d020eb8fcf0d239fc121fff1dc3/imdb.yml"
# we are using the yaml library because it is the type of file that we have here.
sample = YAML.load(URI.open(file).read)

# # ======= understanding what it is returning to us
# # sample here is a hash
# p sample.class
# # movies heres is an array of hashes
# p sample['movies'].class
# # grabbing the title
# p sample['movies'].first['title']
# # ======= understanding what it is returning to us

puts 'Creating directors...'
directors = {}  # stores slug => Director
# sample['directors'] => an array of director hashes

sample["directors"].each do |director|
  # p director => {"slug"=>"nolan", "first_name"=>"Christopher", "last_name"=>"Nolan"}
  # p director.slice("first_name", "last_name") excludes slug
  directors[director["slug"]] = Director.create! director.slice("first_name", "last_name")
end

# The merge() is an inbuilt method in Ruby that returns the new set after merging the passed objects into a set
puts 'Creating movies...'
# p sample["movies"].each { |movie| p movie["director_slug"] }
# p directors[movie["director_slug"]]
sample["movies"].each do |movie|
  # p movie.slice("title", "year", "synopsis")
  # p director: directors[movie["director_slug"]]
  Movie.create! movie.slice("title", "year", "synopsis").merge(director: directors[movie["director_slug"]])
end

puts 'Creating tv shows...'
sample["series"].each do |tv_show|
  # p sample['series'].class
  TvShow.create! tv_show
end

puts 'Finished!'