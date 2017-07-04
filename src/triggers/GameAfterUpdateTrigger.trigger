trigger GameAfterUpdateTrigger on Game__c (after update) {
    
    GameTriggerMethods.manageGameUpdate(Trigger.new);
    
}