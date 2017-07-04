public class LogInLogOutPlayerController {
	public Player__c player { get; set; }
	public Cookie cook { get; set; }
	
	public LogInLogOutPlayerController() {
        player = new Player__c();
    }
    
    public PageReference logOut() {
    	cook = ApexPages.currentPage().getCookies().get('PlayerCookie');
    	if (cook != null) {
    		cook = new Cookie('PlayerCookie', '', null, 0, false);
    		ApexPages.currentPage().setCookies(new Cookie[]{cook});
    	}
    	return Page.myHome;
    }
    
    public PageReference logInPageCheck() {
    	cook = ApexPages.currentPage().getCookies().get('PlayerCookie');
    	if (cook == null) {
    		return null;
    	}
    	return Page.myHome;
    }
    
    public PageReference logIn() {
    	Player__c foundPlayer = null;
    	try {
    		foundPlayer = checkLogInPlayer();
    	} catch (MyLogInException e) {
    		ApexPages.addMessages(e);
    		return null;
    	}
        cook = new Cookie('PlayerCookie', foundPlayer.Id, null, 2440, false);
        ApexPages.currentPage().setCookies(new Cookie[]{cook});
        return Page.myHome;
    }
    
    private Player__c checkLogInPlayer() {
    	List<Player__c> players = [SELECT E_mail__c, Password__c, User_Status__c FROM Player__c WHERE  E_mail__c = :player.E_mail__c];
    	Player__c foundPlayer = null;
    	if (players.size() == 0) { 
    	    throw new MyLogInException('Email is not correct');
        } else {
        	foundPlayer = players[0];
        	if (foundPlayer.Password__c != player.Password__c) {
    	    	throw new MyLogInException('Password is not correct');
        	}
        	if (foundPlayer.User_Status__c != 'Active') {
    	    	throw new MyLogInException('Your player account is not activated');
        	}
        }
    	return foundPlayer;
    }
  
}