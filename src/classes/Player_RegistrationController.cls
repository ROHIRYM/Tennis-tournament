public class Player_RegistrationController {

    public Player__c player { get; private set; }
    public String confirmPassword { get; set; }

    public Player_RegistrationController() {
        player = new Player__c();
    }
    
    public PageReference registerPageCheck() {
    	Boolean isLoggedIn = AuthorizationController.AUTHORIZATION_CONTROLLER.isLoggedIn();
    	if (!isLoggedIn) {
    		return null;
    	}
    	return Page.myHome;
    }

    public PageReference save() { 
        try {
       		if (confirmPassword == player.Password__c) {
        		insert(player);
        		try{
        			System.schedule('Deleting player if status will not be Active', '0 1 * * * ?', new DeleteUnactivatedPlayers());
				} catch(Exception ex){
        			System.debug('An exception occured while creating new schedule(if it exists)');  
        		}
        	} else {
    			DMLException myException = new DMLException();
    			myException.setMessage('Passwords do not match');
    			throw myException;
    		}
    		sendEmail();
        } catch(System.DMLException e) {
	    	ApexPages.addMessages(e);
    	    return null;
	    } catch(Exception e) {
	    	return Page.myHome;
	    }
    	return Page.myHome;
    }
    
    public void sendEmail(){
    	String htmlBody = 'Your player:<b> ' + player.Id +' </b>has been created.'+
                'To activate your player account <a href="https://mytabletennistournamen-developer-edition.eu6.force.com/registration?code=' 
                + player.Id + '">Click here</a>';
    	
    	EmailSender.EMAIL_SENDER.sendLetter(2, new String[] {player.E_mail__c}, 
    		'Submit your email address', 'Submit your email address', 'Test', htmlBody);
    }
}