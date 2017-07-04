public class TeamController {
    
    public TeamController() {
        
    }
	
	public void create(Team__c team) {
		try {
				validateTeam(team);
        		insert(team);
        	} catch (System.DMLException e) {
        		ApexPages.addMessages(e);
        	}
	}
	
	private void validateTeam(Team__c team) {
		List<Team__c> teams = [SELECT Id FROM Team__c WHERE Name = :team.Name AND Tournament_Id__c = :team.Tournament_Id__c];
		if (teams.size() > 0) {
			DMLException ex = new DMLException();
			ex.setMessage('This team is already applied to this tournament!');
			throw ex;
		}
		teams = [SELECT Id FROM Team__c WHERE Tournament_Id__c = :team.Tournament_Id__c AND isComplete__c = true];
		if (teams.size() > 15) {
			DMLException ex = new DMLException();
			ex.setMessage('Too many teams!');
			throw ex;
		}
	}
    
}