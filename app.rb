require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  before do
    @game = session[:game] || WordGuesserGame.new('')
  end

  after do
    session[:game] = @game
  end

  get '/' do
    redirect '/new'
  end

  get '/new' do
    erb :new
  end

  post '/create' do
    word = params[:word] || WordGuesserGame.get_random_word
    @game = WordGuesserGame.new(word)
    redirect '/show'
  end

  post '/guess' do
    guess = params[:guess].to_s[0]

    if guess.nil? || guess.empty? || guess =~ /[^a-zA-Z]/
      flash[:message] = "Invalid guess."
    elsif (@game.word_with_guesses + @game.wrong_guesses).include?(guess.downcase)
      flash[:message] = "You have already used that letter."
    else
      @game.guess(guess)
    end

    redirect '/show'
  end

  get '/show' do
    case @game.check_win_or_lose
    when :win
      redirect '/win'
    when :lose
      redirect '/lose'
    else
      erb :show
    end
  end

  get '/win' do
    erb :win
  end

  get '/lose' do
    erb :lose
  end
end