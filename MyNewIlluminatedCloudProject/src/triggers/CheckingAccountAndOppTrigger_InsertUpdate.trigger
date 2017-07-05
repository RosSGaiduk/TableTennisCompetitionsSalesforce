/**
 * Created by Rostyslav on 16.06.2017.
 */
trigger CheckingAccountAndOppTrigger_InsertUpdate on Invoice__c (after insert,before update) {
//    List<Id> ids = new List<Id>();
//    for (Invoice__c invoices: Trigger.new){
//        ids.add(invoices.Id);
//    }
    CheckingClass.checkAccountAndOppTrigger(Trigger.newMap);
}