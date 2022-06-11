# SEARCH
SO this morning we will see 3 different ways of doing search:
1. the first one will be using plain active record and a little bit of SQL. So we wont
be using any gems, just plain activerecord so that we can fully understand what query
is behind our search. But keep in mind that - UNLESS YOU ARE DOING A VERY VERY SIMPLE SEACRH...
you will rarely use this method - it can get really tricky. But it is important to understand what goes
behind it - but most of the time you will be using a gem, or two different gems actually -
2. the first one will be PG SEARCH, which is quite powerfull and robust and this is the one i will definitely
advise your guys to use in yout projects
3. and the other one will be going a bit further with elastic search - which is a really professional gem - but this one i'd advise for the future not for your projects... for your projects lets try and stick to search.

# SET UP
we are gonna use the miminal template here because we are not gonna have any users, just a few models
about movies and search through them, no sign in no nothing.

# SCHEMA
so we are gonna have this schema - where we can easily search through movies right? But we are also
gonna learn a pretty advanced method od searching where we'll be able to serch for directors and it will
return us the movies that belog to those directors. And towards the end we will also see how we can have the
MULTI MODEL SEARCH, which means - if we search for a movie imdb and that movie happens to also have a TV it will return them both for us.

# MIGRATIONS
remember to add to the director model:
class Director < ApplicationRecord
  has_many :movies
end

# SEED
quickly go over it

# ROUTES
so we dont need a bunch of routes, we are only gonna need a home page and a movies index

# CONTROLLER & VIEW  - COPY PASTE SLIDE
so here we display all movies right?
@movies = Movie.all
WE ARE JUST GONNA COPY PASTE HERE TO SAVE SOME TIME DOING
SOMETHING YOU GUYS ALREADY KNOW!

LETS GO RAILS S
HOME PAGE - no link nothing lets quickly add a link_to it just to facilitate navigation

<div class="containter text-center mt-5">
  <%= link_to 'Browse Movies', movies_path, class: 'btn btn-secondary' %>
</div>
so here we have our movies

# PLAIN ACTIVERECORD
So lets start searching using plain activerecord

# SEARCH FORM
so if as a user we are gonna do a search we need a form, ye? we need somewhere to type
our query so lets just add this form to our index page.

For this we are gonna use form_tag - we could use simple form but it would be an unconventional
way of using SF.
Simple form is usualy tied to a certain model and it also does some validations for us
so if you pass an input inside the form that is not related to the model it is gonna throw
an error. we can user simple form by disabling features, so form tag is a much simpler type
of form that has no ties to the model - here is the form and here is where you need to go.

here we cant use f.input, form tag has its own default field which is text-field-tag.
for now that is all you need to know, for this implementation, if you are curious
you can dig into the documentation - which i highly recommend.

so if you implement search in your apps, copy paste this forms and change the variables.

LETS LOOK AT OUT LOCALHOST!

TALK ABOUT THE FORM! play with query and change it to banana etc...

# WHERE - lets find a movie by title but with no spoilers
  def index
    <!-- query will usually be either a string or nil so empty? is not a good choice -->
    if params[:query].present?
      @movies = Movie.where(title: params[:query])
    else
      @movies = Movie.all
    end
  end

As i told you guys, super wont return Superman Returns it wont return anything!
this is where a very handy query comes in... any ideas?

# WHERE ILIKE
@movies = Movie.where("title ILIKE ?", "%#{params[:query]}%")

# SEARCHING MULTIPLE COLUMNS - OR
The term might be in the movie's title or in its synopsis... lets say that i wanna
find a movie that has gotham inside the synopsis but none of them have gotham in
the title. How would we do this?
Note that in our movie model has a synopsis attribute, so we can use that in our
search.
quick reminder on the SQL injections -> query here will take that NOT as a part of the
query, just as a search - therefore no one will be able to say in the search DELETE
in order to delete something in the DB, it will just be interpreted as a string which
is just the search.

# SEARCHING MULTIPLE TERMS - @@
now we cant search batman superman because there is a v here in the middle. although
we have our wild card for both queries, it is not gonna match. so this is when we can
bring something from postgresql, that is quite powerful, which is the fulltext search.
here we are going to use @@.
What the full search does is - it looks for associated english words, for example if you search
for jump -> it'll search for jumped, jumping, etc AND it will also search if you pass
multile terms and it will do the same thing for each of them individually.

But now we have another problem: if we dont finish the word, it is not gonna find the match.
it doesnt allow partial words. We'll see how to fix that in a minute.

# SEARCHING THROUGH ASSOCIATION - JOINS

So what would be really nice now is to search for movies directed by nolan, for example,
which we cant do now. now remember that director is a different model, so in order to do
that we are gonna have to make a JOIN query, right? we will need to JOIN the tables.

def index
    if params[:query].present?
      sql_query = " \
        <!-- so inside the movies table we are looking for the title -->
        movies.title ILIKE :query \
        <!-- so inside the movies table we are looking for the synopsis -->
        OR movies.synopsis ILIKE :query \
        <!-- so inside the directors table we are looking for the first_name -->
        OR directors.first_name ILIKE :query \
        <!-- so inside the directors table we are looking for the last_name -->
        OR directors.last_name ILIKE :query \
      "
      <!-- notice that all of this is saved inside our variable sql_query -->
      <!-- now in here all we have to do is call the joins method on the directors -->
      <!-- table and pass our query variable as argument of where -->
      @movies = Movie.joins(:director).where(sql_query, query: "%#{params[:query]}%")
    else
      @movies = Movie.all
    end
  end

# SEARCHING MULTIPLE TERMS - @@
But as i mentioned earlier `superman batm` won't return anything either...
We need something stronger!
So this is as far as we will go when it comes to using plain activerecord

# PG SEARCH
so the gem we are going to use for this is pg search. like i said earlier in class
today, PG SEARCH is quite powerfull and robust and this is the one i will definitely
advise your guys to use in yout projects.

# PG_SEARCH GEM
the setup is quite simple - in the slide there is the link to the documentation,
so you guys can dive right in!

# SEARCHING ONE MODEL (SCOPE)
so here we will add some elements to our model that tells how pg search will work in
that model, instead of the controller and in the controller we will call the method
that is in our model.
GO TO MOVIE MODEL

GO TO CONTROLLER:
  def index
    # if params[:query].present?
    #   sql_query = " \
    #     movies.title ILIKE :query \
    #     OR movies.synopsis ILIKE :query \
    #     OR directors.first_name ILIKE :query \
    #     OR directors.last_name ILIKE :query \
    #   "
      @movies = Movie.search_by_title_and_synopsis
    else
      @movies = Movie.all
    end

# SEARCHING THROUGH ASSOCIATION
we can still search through associations by adding this:
GO TO SLIDE THEN ADD CODE TO MODEL. IF YOU WANT CHANGE THE METHOD
NAME TO MAKE MORE SENSE.

# What about our tv_shows table 🤔
But remember we have a tv shows table as well!
can can we search through that tabe too?
the ideia here is to have a bunch of movies and a bunch of tv shows
coming all back in the same query. for that we need to do set up
because with pg search, if we wanna do a search on multiple models we
still needs one table to search for... it is not gonna ask to search for
two tables, it is gonna say lets create a new table with all the information
that i need and search through that.

so we need to create that table by running this migration:
IN THE SCHEMA:
we have a new table called pg search documents.

so here this table stores:
content: here it stores what we want to search
searchable type: what the original type was(movie, tv show, director)
searchabe id: with that we ca find the instance very easily(movie, with this id
or tv show with this id)

# MULTI-SEARCH - USAGE
now we need to add the documents by using the console. and it basicaly inserts all
the information form our tv show table and our movies table to the pg documents table.
so we only need to do this once:
now our table pg search documents is populated with both info!
and also when we add a new record to the DB, say a movie or a tv show it will also
be added to the pg search documents.

results = PgSearch.multisearch('superman')
this will search all the models in which we have multisearchable

<PgSearch::Document:0x00007efdf819fcd8
so it is one og the pg search documents
it has id 2, the content is the type and the syllabus
searchable type is a movie

if we do results.last
now in order for us to convert them back to a movie instance or a tv show instance
we just call:

results.first.searchable -> the searchable will return us the instace itself
not the polymorphic collection that multiseacrh returns. a polymorphic association is an Active Record association that can connect a model to multiple other models. that is exactly what multisearch does
right?

# A LOT MORE

# GOING FURTHER

# WHEN USE IT? - read slide

# INFRASTRUCTURE
with elastic search, we create a table and add stuff to it and we search on that table instead
of our table. The difference is - with elastic search the table is not on your DB is o their DB, 
because they have some servers that are really fast - so return we get the results that are on an external service - when we are on localhost of course it is just another server running in the background but when you are in production it is actually their own service.
`sudo service elasticsearch start`

# ON HEROKU 
FIND OUT HOW TO DO THIS

# SEARCHKICK GEM
elasticsearch was coded in java, so the search kick gem is a ruby wrapper, which is basically
a conversion.
lets add searchkick on the model we want to search.

adding this here is basically the equivalent of saying, we are using searchkick on this model,
so when