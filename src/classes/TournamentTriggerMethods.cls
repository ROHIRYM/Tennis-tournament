public class TournamentTriggerMethods {
	
	private static String notifySchedulerId {private get; private set;}
	
	public static void manageTournament(Tournament__c[] tournaments){
		Tournament__c startedTournament;
		for (Tournament__c t : tournaments) {
			if (t.Status__c == 'Current') {
				startedTournament = t;
				break;
			}
			if (t.Status__c == 'Complete') {
				//System.abortJob(notifySchedulerId);
				break;
			}
		}
		if (startedTournament != null) {
			generateCurrentTournamentGames(startedTournament);
    		startSendingEmails(startedTournament);
		}
    }
    
    private static void generateCurrentTournamentGames(Tournament__c tournament){
    	List<Game__c> games = [SELECT Id FROM Game__c WHERE Tournament_Id__c = :tournament.Id];
    	if (games.size() == 0) {
    		GameController gameController = new GameController();
        	gameController.generateGames(tournament.Id);
    	}
    }
    
    private static void startSendingEmails(Tournament__c tournament){ 	
    	try{
        	notifySchedulerId = System.schedule('Notifying all the players about games they have not played yet',
        		'0 1 0 * * ?', new NotifyAboutGamesToPlay(tournament));
		} catch(Exception ex){
        	System.debug('An exception occured while creating new schedule(if it exists)');  
        }
    }
}