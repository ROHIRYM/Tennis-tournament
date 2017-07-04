public class PlayerTournamentController {
	
	public Player_Tournament__c playerTournament { get; set; }
	
	public PlayerTournamentController() {
        playerTournament = new Player_Tournament__c();
    }
	
	public PageReference create(String tournamentId) {
        String playerId = ApexPages.currentPage().getCookies().get('PlayerCookie').getValue();
        playerTournament = new Player_Tournament__c();
	    playerTournament.Tournament_Id__c = tournamentId;
        playerTournament.Player_Id__c = playerId;
        try {
        	validate(tournamentId, playerId);
        	insert(playerTournament);
        	return new PageReference('/PlayerTournament_Create');
        } catch (System.DMLException e) {
        	ApexPages.addMessages(e);
    	    return new PageReference('/Tournament_View?id=' + tournamentId);
        }
	}
	
	private void validate(String tournamentId, String playerId) {
		List<Player_Tournament__c> playerTournaments = [SELECT Id FROM Player_Tournament__c WHERE Player_Id__c = :playerId AND Tournament_Id__c = :tournamentId];
		List<Player_Tournament__c> secondPlayerTournaments = [SELECT Id FROM Player_Tournament__c WHERE Tournament_Id__c = :tournamentId];
		if (playerTournaments.size() > 0) {
			DMLException ex = new DMLException();
			ex.setMessage('You are already applied to this tournament!');
			throw ex;
		}
		if (secondPlayerTournaments.size() > 15) {
			DMLException ex = new DMLException();
			ex.setMessage('Too many players!');
			throw ex;
		}
	}
    
}