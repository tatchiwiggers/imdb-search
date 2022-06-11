# SEARCH
Hoje vamos ver 3 maneiras diferentes de fazer pesquisa:
1. a primeira vai usar o AR simples e um pouco de SQL. Então não vamos usar qualquer gem, apenas activerecord 
para que possamos entender bem qual query está por trás da nossa busca. Mas tenha em mente que - A MENOS QUE VOCÊ ESTEJA FAZENDO UM SEACRH MUITO SIMPLES...
você raramente usará esse método - pode ficar muito complicado. Mas é importante entender o que acontece
por trás dele - mas na maioria das vezes vocês vão uilizar um gem, ou dois gems diferentes na verdade...
2. o primeiro será o PG SEARCH, que é bastante poderoso e robusto e este é o que eu aconselho vcs a usarem em seus projetos;
3. e o outro é o elasticsearh e o elasticsearch é um gem extremamente profisisonal, até demais na minha opinião para o trabalho que vcs vão fazer no bootcamp. Então acredito que o PG é uma excelente escolha, de facil configuração e recomendo que sigam com ele.

# SET UP
vamos usar miniaml template do LW sem o devise porque não teremos nenhum usuário, apenas alguns modelos
sobre filmes e pesquisar por eles, sem login, sem nada.

# SCHEMA
então vamos ter este schema - onde podemos facilmente pesquisar filmes, certo? Mas também vamos aprender um método bastante avançado de busca onde poderemos procurar pelos diretores dos filmes e esse metodo vai nos devolver os filmes que pertencem a esses diretores. E no final veremos também como podemos ter o MULTI MODEL SEARCH, o que significa - se procurarmos um filme imdb e esse filme também tiver uma TV, ele retornará os dois pra gente.

# MIGRATIONS
lembrar de adicionar ao modelo do diretor:
class Director < ApplicationRecord
  has_many :movies
end

# SEED
repassar pelo arquivo seed

# ROUTES
então não precisamos de um monte de rotas, vamos precisar apenas de um home page e um índice de filmes

# CONTROLLER & VIEW  - COPY PASTE SLIDE
então aqui mostramos todos os filmes certo?
@movies = Movie.all
VAMOS COPIAR O VIEW E COLAR AQUI PARA ECONOMIZAR TEMPO FAZENDO
ALGO QUE VOCÊS JÁ SABEM - CERTO??!

FAZER RAILS S
HOME PAGE - vamos adicionarum linkt_to aqui rapidinho  para facilitar a navegação

<div class="containter text-center mt-5">
  <%= link_to 'Browse Movies', movies_path, class: 'btn btn-secondary' %>
</div>
so here we have our movies

# PLAIN ACTIVERECORD
Então vamos começar a pesquisar usando o plain activerecord

# SEARCH FORM
então, se como usuário vamos fazer uma pesquisa, precisamos de um formulário, certo? precisamos de um lugar para digitar nossa consulta, então vamos adicionar este formulário ao nosso index.

Para isso, usaremos form_tag - poderíamos usar o simple form, mas seria uma forma não convencional maneira de usar SF.

O simple form geralmente está vinculado a um determinado modelo e também faz algumas validações pra gente, então se vocês passarem informação dentro do formulário que não está relacionado ao modelo, ele vai gerar um erro. Podemos usar um simple form desabilitando recursos, mas é muito mais fácil utilizar o form tag que é um tipo muito mais simples de formulário que não tem vínculos com o modelo.

Aqui não podemos usar f.input, o form tag tem seu próprio campo padrão que é text-field-tag.
por enquanto isso é tudo que vocês precisam saber, para esta implementação, caso tenha curiosidade, vocês podem olhar a documentação - o que eu recomendo.

então, se vocês implementarem um search em seus aplicativos, copie e cole esses formulários e altere as variáveis.

VAMOS OLHAR PARA FORA LOCALHOST!

# WHERE - lets find a movie by title but with no spoilers
  def index
    <!-- query will usually be either a string or nil so empty? is not a good choice -->
    if params[:query].present?
      @movies = Movie.where(title: params[:query])
    else
      @movies = Movie.all
    end
  end

Como eu disse a vocês, super não vai retornar Superman Returns não vai retornar nada!
é aqui que entra uma consulta muito útil... alguma ideia?

# WHERE ILIKE
@movies = Movie.where("title ILIKE ?", "%#{params[:query]}%")

# SEARCHING MULTIPLE COLUMNS - OR
O termo pode estar no título do filme ou na sinopse... digamos que eu queira
encontrar um filme que tenha gotham dentro da sinopse, mas nenhum deles tenha gotham em 
título. Como faríamos isso?
Observe que no nosso modelo filme tem um atributo sinopse, então podemos usar esse atributo  
no nosso search.


lembrete rápido sobre as injeções de SQL -> essa consulta NÃO é parte da consulta, ou
seja, do query- por isso, ninguém poderá dizer na pesquisa DELETE
para excluir algo no banco de dados -essas informações serão interpretadas apenas como uma 
string que é apenas a pesquisa.

# SEARCHING MULTIPLE TERMS - @@
agora não podemos procurar batman superman porque há um v aqui no meio. Apesar de
termos nosso curinga para ambas as consultas, ele não corresponderá. Mas podemos
trazer algo do postgresql, que é bastante poderoso, que é a busca de texto completo.
E para isso vamos ussar o @@. 
O que a pesquisa completa faz é - ela procura palavras em inglês associadas, por exemplo, se você pesquisar por exemplo por JUMP -> ele vai procurar por jumping, jumped etc e também vai procurar se você passar termos múltiplos e vai fazer a mesma coisa para cada um deles individualmente.

Mas agora temos outro problema: se não terminarmos a palavra, não encontrará a correspondência.
não permite palavras parciais. Veremos como consertar isso em um minuto.

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