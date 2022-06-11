class MoviesController < ApplicationController
  # def index
  #   # if there is a params, if the user inserts something:
  #   # why use present? bc the query here would be either a string or nil.
  #   # for a string it would work but for nil it wouldnt bc nil is an empty
  #   # object and present is a method that does just that - checks if an 
  #   # object is present we can also use blank? and invert the condition
  #   # now lets make it all work including case insensitive
  #   # .downcase wouldnt work bc we cannot title is coming from the DB and
  #   # we cannot downcase the title from the DB
  #   # if params[:query].blank?
  #   if params[:query].present?
  #     # what do we want to search for? for title - so we check
  #     # for queries - if there is a query for films:
  #     # @movies = Movie.where(title: params[:query])

  #     # @movies = Movie.where("title ILIKE ?", "%#{params[:query]}%")
  #     # rememeber to put the % wild card before and after
  #     # @movies = Movie.where("title ILIKE :query OR synopsis ILIKE :query", query: params[:query])
  #     # @movies = Movie.where("title ILIKE :query OR synopsis ILIKE :query", query: "%#{params[:query]}%")

  #     # FULL SEARCH
  #     @movies = Movie.where("title @@ :query OR synopsis @@ :query", query: "%#{params[:query]}%")
  #   else
  #     @movies = Movie.all
  #   end
  # end

  def index
    if params[:query].present?
    #   sql_query = " \
    #     movies.title ILIKE :query \
    #     OR movies.synopsis ILIKE :query \
    #     OR directors.first_name ILIKE :query \
    #     OR directors.last_name ILIKE :query \
    #   "

      # PG search
      # @movies = Movie.search_by_title_and_synopsis_and_director(params[:query])

      # PG multisearch
      @results = PgSearch.multisearch(params[:query])

      # Elastic Search
      # @results = Movie.search(params[:query])
    else
      @results = Movie.all
    end
  end
end
