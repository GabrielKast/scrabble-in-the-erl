-module(scrabble).

-export([scrabbleLetterValueEN/1]).
-export([scrabbleLetterValueFR/1]).
-export([getScrabbleScore/1]).
-export([main/0]).

scrabbleENScore ()->
    %% a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p,  q, r, s, t, u, v, w, x, y,  z
    [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10].

scrabbleENDistribution()->
    %% a, b, c, d,  e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
    [9, 2, 2, 1, 12, 2, 3, 2, 9, 1, 1, 4, 2, 6, 8, 2, 1, 6, 4, 6, 4, 2, 2, 1, 2, 1].

scrabbleFRScore()->
  %% a,  b, c, d, e, f, g, h, i, j,  k, l, m, n, o, p, q, r, s, t, u, v,  w,  x,  y,  z
    [1,  3, 3, 2, 1, 4, 2, 4, 1, 8, 10, 1, 2, 1, 1, 3, 8, 1, 1, 1, 1, 4, 10, 10, 10, 10].

scrabbleFRDistribution()->
    %% a, b, c, d,  e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
    [9, 2, 2, 3, 15, 2, 2, 2, 8, 1, 1, 5, 3, 6, 6, 2, 1, 6, 6, 6, 6, 2, 1, 1, 1, 1].

scrabbleLetterValueEN(C)-> lists:nth(C - $a + 1, scrabbleENScore()).

scrabbleLetterValueFR(C) -> lists:nth(C - $a + 1, scrabbleFRScore()).


getScrabbleScore(Word)->
    lists:foldl(fun(Letter, Acc)-> scrabbleLetterValueFR(Letter)+Acc end,
		0, string:to_lower(Word)).

main()->
    {ok, Words_1} = read_lines("resources/ospd.txt"),
    Words = sets:from_list(Words_1),
    {ok, Shakespeare} = read_lines("resources/words.shakespeare.txt"),
    io:fwrite ("# de mots autorisés au Scrabble : ~B~n", [sets:size(Words)]),
    io:fwrite("# ofmots utilisés par Shakespeare  : ~B~n",  
	      [length(Shakespeare)]),

    %% number of words used by Shakespeare and allowed at Scrabble
    Allowed = lists:filter(fun(W)->sets:is_element(W, Words) end, Shakespeare),
    io:fwrite("# number of words used by Shakespeare and allowed at Scrabble ~B~n", [length(Allowed)]),
    
    %% words of Shakespeare grouped by their length
    Grouped_by_length = 
	lists:foldl(fun(W, Dict_acc)->
			    dict:update_counter(length(W), 1, Dict_acc)
		    end, dict:new(), Shakespeare),
    io:fwrite("Words of Shakespeare grouped by their length = ~p~n",
	      [dict:to_list(Grouped_by_length)]),

   %% words of Shakespeare of 16 letters and more
    Sixteen = 
	lists:foldl(fun(W, Dict_acc) when length(W)>=16 -> 
			    dict:append(length(W), W, Dict_acc);
		       (_, Dict_acc) -> Dict_acc
		    end, dict:new(), Shakespeare),
    io:fwrite("Words of Shakespeare grouped by their length = ~p~n",
	      [dict:to_list(Sixteen)]),
     
    %% words of Shakespeare grouped by their Scrabble score
    %% in ascending order
    Shakespeare_score = 
	lists:foldl(
	  fun(W1, Acc)-> 
		  W = string:to_lower(W1),
		  case sets:is_element(W, Words) of
			    false -> Acc;
		      _ -> 
			  Score = getScrabbleScore(W),
			  Fun =fun(Set)->sets:add_element(W, Set) end,
			  orddict:update(Score, Fun, sets:new(), Acc)
		  end
	  end, orddict:new(), Shakespeare),
    Shakespeare_score2 = [{Sc, lists:sort(sets:to_list(Ws))} 
			  || {Sc, Ws} <- orddict:to_list(Shakespeare_score)],
    io:fwrite("Words of Shakespeare grouped by their Scrabble score ~n~p~n",
	      [Shakespeare_score2]),
        
        %% // words of Shakespeare grouped by their Scrabble score, with a score greater than 29
        %% // in ascending order
        %% Predicate<String> scoreGT28 = word -> score.apply(word) > 28 ;
        %% Map<Integer, List<String>> map4 =
        %% shakespeareWords.stream()
        %%         .map(String::toLowerCase)
        %%         .filter(scrabbleWords::contains)
        %%         .filter(scoreGT28)
        %%         .collect(
        %%                 Collectors.groupingBy(
        %%                         score, 
        %%                         TreeMap::new,
        %%                         Collectors.toList()
        %%                 )
        %%         ) ;
        %% System.out.println("Words of Shakespeare grouped by their Scrabble score = " + map4) ;
        
        %% // histogram of the letters in a given word
        %% Function<String, Map<Integer, Long>> lettersHisto = 
        %%     word -> word.chars()
        %%                 .mapToObj(Integer::new)
        %%                 .collect(
        %%                         Collectors.groupingBy(
        %%                                 Function.identity(),
        %%                                 Collectors.counting()
        %%                         )
        %%                 ) ;
            
        %% // score of a given word, taking into account that the given word
        %% // might contain blank letters
        %% Function<String, Integer> scoreWithBlanks = 
        %%     word -> lettersHisto.apply(word)
        %%                 .entrySet()
        %%                 .stream() // Map.Entry<letters, # used>
        %%                 .mapToInt(
        %%                    entry -> scrabbleENScore[entry.getKey() - 'a']*
        %%                             (int)Long.min(entry.getValue(), scrabbleENDistribution[entry.getKey() - 'a'])
        %%                 )
        %%                 .sum() ;
            
        %% // number of blanks used for the given word
        %% Function<String, Integer> blanksUsed = 
        %%         word -> lettersHisto.apply(word)
        %%                     .entrySet()
        %%                     .stream() // Map.Entry<letters, # used>
        %%                     .mapToInt(
        %%                        entry -> (int)Long.max(0L, entry.getValue() - scrabbleENDistribution[entry.getKey() - 'a'])
        %%                     )
        %%                     .sum() ;
                
        %% System.out.println("Number of blanks in [buzzards] = " + blanksUsed.apply("buzzards")) ;
        %% System.out.println("Real score of [buzzards] = " + scoreWithBlanks.apply("buzzards")) ;
        %% System.out.println("Number of blanks in [whizzing] = " + blanksUsed.apply("whizzing")) ;
        %% System.out.println("Real score of [whizzing] = " + scoreWithBlanks.apply("whizzing")) ;
                
        %% // best words of Shakespeare and their scores
        %% Map<Integer, List<String>> map = 
        %%         shakespeareWords.stream()
        %%                 .filter(scrabbleWords::contains)
        %%                 .filter(word -> blanksUsed.apply(word) <= 2L)
        %%                 .filter(word -> scoreWithBlanks.apply(word) >= 24)
        %%                 .collect(
        %%                         Collectors.groupingBy(
        %%                         		scoreWithBlanks, 
        %%                                 Collectors.toList()
        %%                         )
        %%                 ) ;
        %% System.out.println("Best words of Shakespeare : " + map) ;


    ok.


read_lines(File)->
    {ok, FD} = file:open(File, [read_ahead]),
    Lines =
        try get_all_lines(FD, [])
        after file:close(FD)
        end,
    {ok, Lines}.

get_all_lines(FD, Accum) ->
    case io:get_line(FD, "") of
        eof  -> lists:reverse(Accum);
        "" -> get_all_lines(FD, Accum);
        "\n" -> get_all_lines(FD, Accum);
        Line -> 
	    L = string:strip(Line, both, $\n),
	    get_all_lines(FD, [L|Accum])
    end.

    
