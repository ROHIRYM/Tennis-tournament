public with sharing class MyHomeController {

    public Boolean isNotLogedIn {get; set;}
    public Boolean isManager {get; set;}
    
    public MyHomeController() {
    	isNotLogedIn = !AuthorizationController.AUTHORIZATION_CONTROLLER.isLoggedIn();
    	isManager = AuthorizationController.AUTHORIZATION_CONTROLLER.isManager();
    }
    
}