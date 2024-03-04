require 'json'
require 'open-uri'

class GamesController < ApplicationController
  GRID_SIZE = 10

  def new
    @letters = Array.new(GRID_SIZE) { ('A'..'Z').to_a.sample }
  end

  def score
    @attempt = params[:attempt]
    @letters = params[:letters].split(' ')

    result = run_game(@attempt, @letters)

    render json: result
  end

  private

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : (attempt.size * (1.0 - (time_taken / 60.0)))
  end

  def run_game(attempt, grid)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "Well done"]
      else
        [0, "Not an English word"]
      end
    else
      [0, "Not in the grid"]
    end
  end

  def english_word?(word)
    response = URI.parse("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end
end
