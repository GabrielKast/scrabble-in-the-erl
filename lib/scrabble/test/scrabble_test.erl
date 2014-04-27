-module(scrabble_test).


-include_lib("eunit/include/eunit.hrl").


scrabble_scrore_test()->
    1+3+3+1+1 = scrabble:getScrabbleScore("accra"),
    22 = scrabble:getScrabbleScore("zozo").
