public class ManagerController {
	
	public PageReference checkManager() {
		Boolean isManager = AuthorizationController.AUTHORIZATION_CONTROLLER.isManager();
    	if (isManager) {
    		return null;
    	}
    	return Page.myHome;
     }
}