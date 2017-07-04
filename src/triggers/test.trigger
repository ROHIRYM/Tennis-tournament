trigger test on Invoice__c (before insert, before update)
{
  MyTest.addHelloWorld(Trigger.new);
}