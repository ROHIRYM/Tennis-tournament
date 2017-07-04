global class NotifyAboutGamesToPlay implements Schedulable{
    
    private Tournament__c tournament {private get; private set;}
    
    public NotifyAboutGamesToPlay(Tournament__c tournament) {
    	this.tournament = tournament;
    }
    
    global void execute(SchedulableContext ctx) {
    	System.debug(JSON.serialize(tournament));
    	List<String> emails = new List<String>();
    	if (tournament.Format__c == '1 x 1') {
    		emails = getPlayersEmails();
    	} else {
    		emails = getTeamMembersEmails();
    	}
    	String htmlBody = '<h1>Do not forget to play games</h1>';
    	EmailSender.EMAIL_SENDER.sendLetter(4, emails, 'You still have games to play', 
    	'You still have games to play', 'You still have games to play', htmlBody);
    }
    
    private List<String> getPlayersEmails() {
    	Set<String> resultEmails = new Set<String>();
    	List<Player__c> players = [SELECT E_Mail__c FROM Player__c WHERE Id IN
    		(SELECT Player_Id__c FROM Player_Tournament__c WHERE Tournament_id__c = :tournament.Id)];
    	List<Game__c> games = [SELECT firstCompetitor__c, secondCompetitor__c FROM Game__c
    		WHERE Tournament_Id__c = :tournament.Id AND firstCompetitorScore__c = 0
    		AND secondCompetitorScore__c = 0];
    	for (Player__c p : players) {
    		for (Game__c g : games) {
    			if (g.firstCompetitor__c == p.Id || g.secondCompetitor__c == p.Id) {
    				resultEmails.add(p.E_Mail__c);
    				break;
    			}
    		}
    	}
    	return new List<String>(resultEmails);
    }
    
    private List<String> getTeamMembersEmails() {
    	Set<String> resultEmails = new Set<String>();
    	List<Game__c> games = [SELECT firstCompetitor__c, secondCompetitor__c FROM Game__c
    		WHERE Tournament_Id__c = :tournament.Id AND firstCompetitorScore__c = 0
    		AND secondCompetitorScore__c = 0];
    	Set<String> teamIds = new Set<String>();
    	for (Game__c g : games) {
    		teamIds.add(g.firstCompetitor__c);
    		teamIds.add(g.secondCompetitor__c);
    	}
    	List<Player__c> players = [SELECT E_Mail__c FROM Player__c WHERE Id IN
    		(SELECT Player_Id__c FROM Player_Team__c WHERE Team_Id__c IN :teamIds)];
    	for (Player__c p : players) {
    		resultEmails.add(p.E_Mail__c);
    	}
    	return new List<String>(resultEmails);
    }
    
}