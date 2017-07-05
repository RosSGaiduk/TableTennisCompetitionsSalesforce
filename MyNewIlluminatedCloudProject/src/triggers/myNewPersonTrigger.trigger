trigger myNewPersonTrigger on Person__c (before insert) {
    List<Person__c> persons = Trigger.new; 
    for (Person__c p: persons){
        p.Name = 'I am person';
    }
}