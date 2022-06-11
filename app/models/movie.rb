class Movie < ApplicationRecord
  belongs_to :director
  searchkick
  # here we include the module from pg search
  include PgSearch::Model
  # this line here refers to the content are are searching for
  # in our pg search documents table
  # multisearchable against: [ :title, :synopsis]


  # # method that will be called in the controller
  # # this is the method that will be called when we search
  # # you can name this method here whatever you want
  pg_search_scope :search_by_title_and_synopsis_and_director,
    # here we set the columns we wanna search
    against: [ :title, :synopsis ],
  #   # with pg search you can search using diff features. lets look at the
  #   # documentation real quick. show weighing and prefix

    # here we can look to other models as well by passing the
    # the model we wanna do the search for and then passing the
    # fields on that model
    associated_against: {
      director: [ :first_name, :last_name ]
    },
    using: {
      # tsearch here stands for the full text search
      # and here we are enabling prefix so that the search
      # for partial words are allowed
      tsearch: { prefix: true } # <-- now `superman batm` will return something!
    }

end
