public with sharing class ProfileController {
	
	public Player__c player {get; private set;}
    public Boolean isLoggedIn {get; private set;}
    
    public Tournament__c currentTournament {get; private set;}
    public Player__c teamMate {get; private set;}
    public List<Tournament__c> playerTournaments {get; private set;}
    public List<Tournament__c> teamTournaments {get; private set;}
    public List<Game__c> games {get; private set;}
    public Map<String, String> idNameMap  {get; private set;}
    
    public ProfileController() {
    	isLoggedIn = AuthorizationController.AUTHORIZATION_CONTROLLER.isLoggedIn();
    	if (isLoggedIn) {
    		String playerId = ApexPages.currentPage().getCookies().get('PlayerCookie').getValue(); 
    		player = [SELECT Id, Name, E_Mail__c FROM Player__c WHERE Id = :playerId];
    		findRelatedTournaments(playerId);
    		currentTournament = findCurrentTournament(playerTournaments);
    		currentTournament = currentTournament == null ? findCurrentTournament(teamTournaments) : currentTournament;
    		if (currentTournament != null) {
    			teamMate = (currentTournament == null || currentTournament.Format__c == '1 x 1') ? null 
    				: [SELECT Name FROM Player__c WHERE Id != :playerId AND 
    				Id IN (SELECT Player_Id__c FROM Player_Team__c
    				WHERE Team_Id__c = :currentTournament.Teams__r[0].Id)];
    			String competitor = currentTournament.Format__c == '1 x 1' ? playerId :currentTournament.Teams__r[0].Id;
    			games = [SELECT firstCompetitor__c, secondCompetitor__c, round__c,
    				firstCompetitorScore__c, secondCompetitorScore__c FROM Game__c
    				WHERE Tournament_Id__c = :currentTournament.Id AND
    				(firstCompetitor__c = :competitor OR secondCompetitor__c = :competitor) AND
    				isApproved__c = false];
    			defineCompetitorsNames();
    		}
    	}
    }
    
    public PageReference checkLogIn() {
    	if (!isLoggedIn) {
    		return Page.myHome;
    	}
    	return null;
    }
    
    private void defineCompetitorsNames() {
    	idNameMap = new Map<String, String>(); 
    	if (currentTournament.Format__c == '1 x 1') {
			List<Player__c> players = [SELECT Id, Name FROM Player__c WHERE Id IN (SELECT Player_Id__c FROM Player_Tournament__c WHERE Tournament_Id__c = :currentTournament.Id)];
			for (Player__c p : players) {
				idNameMap.put(p.Id, p.Name);
			}
		} else {
			List<Team__c> teams = [SELECT Id, Name FROM Team__c WHERE Tournament_Id__c = :currentTournament.Id];
			for (Team__c tt : teams) {
				idNameMap.put(tt.Id, tt.Name);
			}
		}
    }
    
    private void findRelatedTournaments(String playerId) {
    	playerTournaments = [SELECT Name, Status__c, Type__c, Format__c FROM Tournament__c
    		WHERE Id IN (SELECT Tournament_Id__c FROM Player_Tournament__c WHERE Player_Id__c = :playerId)];
    	
    	teamTournaments = [SELECT Name, Status__c, Type__c, Format__c,
    		(SELECT Id, Name FROM Teams__r WHERE isComplete__c = true AND Id IN 
    		(SELECT Team_Id__c FROM Player_Team__c WHERE Player_Id__c = :playerId)) 
    		FROM Tournament__c WHERE Format__c = '2 x 2'];
    		
    	for (Integer i = 0; i < teamTournaments.size(); i++) {
    		if (teamTournaments[i].Teams__r == null || teamTournaments[i].Teams__r.isEmpty()) {
    			teamTournaments.remove(i);
    			i--;
    		}
    	}
    }
    
    private Tournament__c findCurrentTournament(List<Tournament__c> tournaments) {
    	for (Tournament__c t : tournaments) {
    		if (t.Status__c == 'Current') {
    			return t;
    		}
    	}
    	return null;
    }
    
}