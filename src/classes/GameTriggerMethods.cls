public class GameTriggerMethods {
	
	public static List<TournamentParticipantStatistics> sortedParticipants { get; private set; }
    
    public static void manageGameUpdate(Game__c[] games){
    	for (Game__c g : games) {
    		if (g.isApproved__c) {
    			generateNextRounds(g);
    			finishTournament(g);
    		}
    	}
    }
    
    private static void generateNextRounds(Game__c g) {
    	List<Tournament__c> tournaments = [SELECT Type__c FROM Tournament__c 
    		WHERE Id = :g.Tournament_Id__c];
    	if (tournaments.size() > 0) {
    		Tournament__c t = tournaments[0];
    		if (t.Type__c == 'Single Elimination Tournament') {
    			generateSETNextRounds(g);
    		}
    		if (t.Type__c == 'Double Elimination Tournament') {
    			//generateDETNextRounds(g);
    		}
    	}
    }
    
    private static void generateSETNextRounds(Game__c g) {
    	List<Game__c> gamesToGenerate = [SELECT Id, firstCompetitor__c, secondCompetitor__c
    		FROM Game__c WHERE Tournament_Id__c = :g.Tournament_Id__c AND round__c > :g.round__c];
    	String target = g.firstCompetitor__c + '-' + g.secondCompetitor__c;
    	String replacement = g.firstCompetitorScore__c > g.secondCompetitorScore__c ? 
    		g.firstCompetitor__c : g.secondCompetitor__c;
    	for (Game__c game : gamesToGenerate) {
    		game.firstCompetitor__c = game.firstCompetitor__c.replace(target, replacement);
    		game.secondCompetitor__c = game.secondCompetitor__c.replace(target, replacement);
    	}
    	try {
    		update(gamesToGenerate);
    	} catch (System.DmlException e) {
    		ApexPages.addMessages(e);
    	}
    }
    
    private static void finishTournament(Game__c g) {
    	List<Game__c> unApprovedGames = [SELECT Id FROM Game__c WHERE 
    		Tournament_Id__c = :g.Tournament_Id__c AND isApproved__c = false];
    	if (unApprovedGames.size() == 0) {
    		List<Tournament__c> ts = [SELECT Id, Type__c, Status__c FROM Tournament__c 
    			WHERE Id = :g.Tournament_Id__c];
    		if (ts.size() > 0) {
    			Tournament__c t = ts[0];
    			t.Status__c = 'Complete';
    			try {
    				update(t);
    				notifyManagers();
    				if (t.Type__c == 'Round Robin') {
    					calculateRRResult(t);
    				}
    			} catch (System.DmlException e) {
    				//ApexPages.addMessages(e);
    			} catch (Exception e) {
    				//ApexPages.addMessages(e);
    			}
    		}
    	}
    }
    
    private static void notifyManagers() {
    	List<Player__c> managers = [SELECT E_Mail__c FROM Player__c WHERE Is_Manager__c = true];
    	List<String> emails = new List<String>();
    	for (Player__c p : managers) {
    		emails.add(p.E_Mail__c);
    	}
    	String htmlBody = 'The last game has been played. So, the tournament is finished! <b>Congratulations!</b>';
    	EmailSender.EMAIL_SENDER.sendLetter(3, emails, 'The last game has been played',
    		'The last game has been played', 'The last game has been played', htmlBody);
    }
    
    private static void calculateRRResult(Tournament__c t) {
    	List<Game__c> games = [SELECT firstCompetitor__c, secondCompetitor__c,
    		firstCompetitorScore__c, secondCompetitorScore__c FROM Game__c
    		WHERE Tournament_Id__c = :t.Id];
    	Map<String, TournamentParticipantStatistics> pMap = new Map<String, TournamentParticipantStatistics>();
    	for (Game__c g : games) {
    		TournamentParticipantStatistics tps1 = pMap.get(g.firstCompetitor__c);
    		Integer wonGame1 = g.firstCompetitorScore__c > g.secondCompetitorScore__c ? 1 : 0;
    		if (tps1 == null) {
    			tps1 = new TournamentParticipantStatistics(g.firstCompetitor__c, wonGame1, g.firstCompetitorScore__c);
    		} else {
    			tps1 = new TournamentParticipantStatistics(g.firstCompetitor__c, 
    				tps1.wonGames + wonGame1, tps1.wonSets + g.firstCompetitorScore__c);
    		}
    		pMap.put(g.firstCompetitor__c, tps1);
    		
    		TournamentParticipantStatistics tps2 = pMap.get(g.secondCompetitor__c);
    		Integer wonGame2 = g.firstCompetitorScore__c < g.secondCompetitorScore__c ? 1 : 0;
    		if (tps2 == null) {
    			tps2 = new TournamentParticipantStatistics(g.secondCompetitor__c, wonGame2, g.secondCompetitorScore__c);
    		} else {
    			tps2 = new TournamentParticipantStatistics(g.secondCompetitor__c, 
    				tps2.wonGames + wonGame2, tps2.wonSets + g.secondCompetitorScore__c);
    		}
    		pMap.put(g.secondCompetitor__c, tps2);
    	}
    	sortedParticipants = sortTPS(pMap.values());
    }
    
    private static List<TournamentParticipantStatistics> sortTPS(List<TournamentParticipantStatistics> listToSort) {
    	for (Integer i = 0; i < listToSort.size(); i++) {
    		for (Integer j = 1; j < listToSort.size() - 1; j++) {
    			if (listToSort[j].betterThan(listToSort[j-1])) {
    				TournamentParticipantStatistics temp = listToSort[j];
    				listToSort[j] = listToSort[j-1];
    				listToSort[j-1] = temp;
    			}
    		}
    	}
    	return null;
    }
    
}