public class LoggedInAndManager {
    
    public Boolean isLoggedIn {get; private set;}
    
    public Boolean isManager {get; private set;}
    
    public LoggedInAndManager() {
    	this.isLoggedIn = false;
    	this.isManager = false;
    }
    
    public LoggedInAndManager(Boolean isLoggedIn, Boolean isManager) {
    	this.isLoggedIn = isLoggedIn;
    	this.isManager = isManager;
    }
    
}