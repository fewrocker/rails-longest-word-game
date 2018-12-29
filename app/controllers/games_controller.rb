require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @start_time_now = Time.now
    @grid_size = 12
    @letter_grid = (0...@grid_size).map { rand() < 0.3 ? %w(A E I O U).sample : %w(B C D F G H J K L M N P Q R S T V X W Z Y).sample }
  end

  def score
    @word = params['word']
    @grid = params['grid'].split(" ")
    @start_time = params[:start_time_post].to_datetime.to_i
    @end_time = Time.now.to_i
    @time_elapsed = @end_time - @start_time

    data = parse(@word)
    gridfit = include_grid?(@word, @grid)

    @result_score, @result_main, @result_description = result_definer(@word, data, gridfit, @time_elapsed)
  end

  def include_grid?(attempt, grid)
    gridok = true
    attempt_letters = attempt.upcase.split("")
    attempt_letters.each do |letter|
      if grid.include?(letter) == true
        grid[grid.index(letter)] = "NIL"
      else
        gridok = false
      end
    end

    return gridok
  end

  def parse(attempt)
    url = 'https://wagon-dictionary.herokuapp.com/' + attempt
    user_serialized = open(url).read
    data = JSON.parse(user_serialized)
    return data
  end

  def result_definer(word, data, gridok, time_elapsed)
    result_score = 0
    if data["found"] == false
      result_main = "Fail!"
      result_description = word.capitalize + " is not an English Word"
    elsif data["found"] == true && gridok == false
      result_main = "Fail!"
      result_description = word.capitalize + " is not in the grid"
    else
      result_main = "Well done!"
      result_description = word.capitalize + " has " + word.length.to_s + " letters and you took " + time_elapsed.to_s + " seconds to respond"
      result_score += word.length**2
      result_score -= time_elapsed * 2
    end
    return result_score.to_f.round(2), result_main, result_description
  end
end
