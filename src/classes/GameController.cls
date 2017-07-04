public class GameController {
	
	public Game__c insertScoreGame {get; set;}
	public Map<String, String> idNameMap {get; private set;}
	
	public PageReference insertScore() {
		Double score1 = insertScoreGame.firstCompetitorScore__c;
		Double score2 = insertScoreGame.secondCompetitorScore__c;
		if (score1 >= 0 && score2 >=0 && (score1 + score2) > 0 && (score1 > score2 || score2 > score1)) {
			try {
				update(insertScoreGame);
				//sendAcceptGameResultEmail()
			} catch (System.DmlException e) {
				ApexPages.addMessages(e);
			} catch (Exception e) {
				
			}
			return Page.Profile;
		}
		return null;
	}
	
	public PageReference getGameInfo() {
		String gameId = ApexPages.currentPage().getParameters().get('gameid');
		Boolean isLoggedIn = AuthorizationController.AUTHORIZATION_CONTROLLER.isLoggedIn();
		if (isLoggedIn && gameId != null) {
			List<Game__c> foundGames = [SELECT Id, firstCompetitor__c, secondCompetitor__c,
				firstCompetitorScore__c, secondCompetitorScore__c, tournament_Id__c, isApproved__c
				FROM Game__c WHERE Id = :gameId];
			if (foundGames.size() > 0) {
				insertScoreGame = foundGames[0];
				List<Tournament__c> tournaments = [SELECT Id, Status__c, Format__c FROM Tournament__c
					WHERE Id = :insertScoreGame.tournament_Id__c];
				if (tournaments.size() > 0) {
					Tournament__c t = tournaments[0];
					if (t.Status__c == 'Current' && !insertScoreGame.isApproved__c) {
						idNameMap = new Map<String, String>();
						if (t.Format__c == '1 x 1') {
							List<Player__c> players = [SELECT Id, Name FROM Player__c WHERE
								Id = :insertScoreGame.firstCompetitor__c OR Id = :insertScoreGame.secondCompetitor__c];
							for (Player__c p : players) {
								idNameMap.put(p.Id, p.Name);
							}
						} else {
							List<Team__c> teams = [SELECT Id, Name FROM Team__c WHERE
								Id = :insertScoreGame.firstCompetitor__c OR Id = :insertScoreGame.secondCompetitor__c];
							for (Team__c te : teams) {
								idNameMap.put(te.Id, te.Name);
							}
						}
						return null;
					}
				}
			}
		}
		return Page.myHome;
	}
    
    public void generateGames(String tournamentId) {
    	Tournament__c tournament = [SELECT Id, Format__c, Type__c FROM Tournament__c WHERE Id = :tournamentId];
        List<String> ids = getCompetitorsIds(tournament);
        if (tournament.Type__c == 'Single Elimination Tournament') {
        	generateSETgames(tournamentId, ids);
        } else if (tournament.Type__c == 'Double Elimination Tournament') {
        	generateDETGames(tournamentId, ids);
        } else {
            generateRRGames(tournamentId, ids);
        }
    }
    
    private List<String> getCompetitorsIds(Tournament__c tournament) {
    	List<String> result;
    	if (tournament.Format__c == '1 x 1') {
        	result = getPlayersIds(tournament.Id);
        } else {
        	result = getTeamsIds(tournament.Id);
        }
    	return result;
    }
    
    private List<String> getPlayersIds(String tournamentId) {
        List<String> result = new List<String>();
        List<Player_Tournament__c> playerTournaments = [SELECT Player_Id__c 
            FROM Player_Tournament__c 
            WHERE Tournament_Id__c = :tournamentId];
        for (Player_Tournament__c pT : playerTournaments) {
            result.add(pT.Player_Id__c);
        }
        return result;
    }
    
    private List<String> getTeamsIds(String tournamentId) {
        List<String> result = new List<String>();
        List<Team__c> teams = [SELECT Id 
            FROM Team__c 
            WHERE Tournament_Id__c = :tournamentId AND isComplete__c = true];
        for (Team__c t : teams) {
            result.add(t.Id);
        }
        return result;
    }
    
    private void generateRRgames(String tournamentId, List<String> ids) {
        List<Game__c> games = new List<Game__c>();
        for(Integer i = 0; i < ids.size(); i++) {
            for(Integer j = i + 1; j < ids.size(); j++) {
                Game__c game = createGame(ids[i], ids[j], tournamentId, 0, 0, 0);
                games.add(game);
            }
        }
        insert(games);
    }
    
    private void generateSETGames(String tournamentId, List<String> ids) {
        List<Game__c> games = generateSETGamesTree(tournamentId, ids, 1, new List<Game__c>());
        insert(games);
    }
    
    private List<Game__c> generateSETGamesTree(String tournamentId, List<String> ids,
    										   Integer round, List<Game__c> result) {
    	Integer idsSize = ids.size();
    	if (idsSize <= 1) {
    		return result;
    	} else if (math.mod(idsSize, 2) > 0) {
    		generateAdditionalSETRound(idsSize-2, idsSize-1, tournamentId, ids, round, result);
    		return generateSETGamesTree(tournamentId, ids, round + 1, result);
    	} else {
    		List<String> newIds = generateSETRound(tournamentId, ids, idsSize, round, result);
    		return generateSETGamesTree(tournamentId, newIds, round + 1, result);
    	}
    }
    
    private void generateAdditionalSETRound(Integer firstCompetitorIndex, Integer secondCompetitorIndex,
    								        String tournamentId, List<String> ids, Integer round, 
    								        List<Game__c> result) {
		String firstCompetitor = ids[firstCompetitorIndex];
		String secondCompetitor = ids[secondCompetitorIndex];
		Game__c game = createGame(firstCompetitor, secondCompetitor, tournamentId, 0, 0, round);
		result.add(game);
		ids.remove(secondCompetitorIndex);
		ids.remove(firstCompetitorIndex);
		String undefinedCompetitor = firstCompetitor + '-' + secondCompetitor;
		ids.add(undefinedCompetitor);
    }
    
    private List<String> generateSETRound(String tournamentId, List<String> ids, Integer idsSize, 
    							 Integer round, List<Game__c> result) {
    	List<String> newIds = new List<String>();
    	for(Integer i = 0; i <= idsSize - 2; i = i + 2) {
    		String firstCompetitor = ids[i];
			String secondCompetitor = ids[i+1];
			Game__c game = createGame(firstCompetitor, secondCompetitor, tournamentId, 0, 0, round);
			result.add(game);
			String undefinedCompetitor = firstCompetitor + '-' + secondCompetitor;
			newIds.add(undefinedCompetitor);
    	}
    	return newIds;
    }
    
    private void generateDETGames(String tournamentId, List<String> ids) {
        List<Game__c> games = generateDETGamesTree(tournamentId, ids, 1, new List<Game__c>());
        insert(games);
    }
    
    private List<Game__c> generateDETGamesTree(String tournamentId, List<String> ids,
    										   Integer round, List<Game__c> result) {
		
		return result;
    }
    
    private Game__c createGame(String firstCompetitor, String secondCompetitor, 
    						   String tournamentId, Integer firstCompetitorScore,
    						   Integer secondCompetitorScore, Integer round) {
    	Game__c game = new Game__c();
    	game.firstCompetitor__c = firstCompetitor;
    	game.secondCompetitor__c = secondCompetitor;
    	game.Tournament_Id__c = tournamentId;
    	game.firstCompetitorScore__c = firstCompetitorScore;
    	game.secondCompetitorScore__c = secondCompetitorScore;
    	game.round__c = round;
    	return game;
    }
    
}