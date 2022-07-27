require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    arr = ('A'..'Z').to_a
    @letters = []
    10.times do |_|
      @letters.push(arr.sample)
    end
  end

  def score
    status_code = valid?(params[:word], params[:wordlist]) ? 1 : 0
    @letters = params[:wordlist].split('').join(', ')
    if status_code.positive?
      result = JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{params[:word]}").read)
      status_code = result['found'] ? 2 : 1
    end
    @res =
      case status_code
      when 0
        "Sorry but <strong>#{params[:word].upcase}</strong> can't be built out of #{@letters}"
      when 2
        "<strong>Congratulations!</strong> #{params[:word].upcase} is a valid English word"
      else
        "Sorry but <strong>#{params[:word].upcase}</strong> is not even a word"
      end
  end
end

def valid?(attempt, letters)
  char_count = Hash.new(0)
  letters.each_char do |c|
    char_count[c.downcase] += 1
  end
  attempt.each_char do |c|
    return false if char_count[c.downcase].zero?

    char_count[c.downcase] -= 1
  end
  true
end
