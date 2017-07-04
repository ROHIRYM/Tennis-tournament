public class PlayerTeamAcceptController {
	
	public PageReference acceptTeamInvitation() {
    	String playerId = ApexPages.currentPage().getParameters().get('code');
    	String teamId = ApexPages.currentPage().getParameters().get('team');
    	Savepoint sp = Database.setSavepoint();
    	try {
    		Player_Team__c playerTeam = new Player_Team__c();
    		playerTeam.Player_Id__c = playerId;
    		playerTeam.Team_Id__c = teamId;
    		insert(playerTeam);
    		List<Team__c> teams = [SELECT Id FROM Team__c WHERE Id = :teamId];
    		if (teams.size() > 0) {
    			teams[0].isComplete__c = true;
    			update(teams[0]);
    		} else {
    			throw new DMLException();
    		}
    	} catch (System.DMLException e){
    		Database.rollback(sp);
        	ApexPages.addMessages(e);
        	return Page.Out_Of_Date_Confirmation;
        }
    	return Page.myHome;
    }
    
}