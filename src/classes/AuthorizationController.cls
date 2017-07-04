public class AuthorizationController {
	
	public static AuthorizationController AUTHORIZATION_CONTROLLER = new AuthorizationController();
	
    private AuthorizationController() {
    	
    }
    
    public Boolean isLoggedIn() {
    	return isLoggedInAndManagerPrivate().isLoggedIn;
    }
    
    public Boolean isManager() {
    	return isLoggedInAndManagerPrivate().isManager;
    }
    
    public LoggedInAndManager isLoggedInAndManager() {
    	return isLoggedInAndManagerPrivate();
    }
    
    private LoggedInAndManager isLoggedInAndManagerPrivate() {
    	String playerId = findPlayerId(); 
    	if (playerId == null) {
    		return new LoggedInAndManager();
    	}
    	List<Player__c> players = [SELECT Is_manager__c FROM Player__c WHERE  Id = :playerId];
    	if (players.size() == 0) {
    		return new LoggedInAndManager();
    	}
    	Player__c foundPlayer = players[0];
    	return new LoggedInAndManager(true, foundPlayer.Is_manager__c);
    }
    
    private String findPlayerId() {
    	Cookie cook = ApexPages.currentPage().getCookies().get('PlayerCookie');
    	if (cook == null) {
    		return null;
    	}
    	return cook.getValue();
    }
      
}