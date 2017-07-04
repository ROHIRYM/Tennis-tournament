public class Player_RegConfirmController {
    
    public String idd {get; set;}
    public Player__c player {get; set;}

    public Player_RegConfirmController() {
       
    }
    
    public PageReference checkAndRedirect() {
        idd = ApexPages.currentPage().getParameters().get('code');
        
        List<Player__c> players = [SELECT Id, User_Status__c, E_mail__c, Password__c FROM Player__c WHERE Id = :idd];
        
        if (players.size() == 0) { 
        	return Page.Out_Of_Date_Confirmation;
        }
        player = players[0];
        if (player != null && player.User_Status__c == 'Waiting for activation') {
        	player.User_Status__c = 'Active';
        	try {
        		update(player);
        	} catch (System.DMLException e){
        		ApexPages.addMessages(e);
        		return null;
        	}
        	LogInLogOutPlayerController logInController = new LogInLogOutPlayerController();
        	logInController.player = player;
            return logInController.logIn();
        } else {
            return Page.Out_Of_Date_Confirmation;
        }
    }
}