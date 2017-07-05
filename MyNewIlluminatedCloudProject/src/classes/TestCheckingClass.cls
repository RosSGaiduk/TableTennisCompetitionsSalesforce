/**
 * Created by Rostyslav on 17.06.2017.
 */
@isTest
public with sharing class TestCheckingClass {
    public static testMethod void checkAccountAndOppTriggerTest() {
        List<Invoice__c> invoices = new List<Invoice__c>();
        
        //******************************** якщо добавити (seealldate = true) після @isTest, тоді можна робити такі запити ********************************//
        //Account account = [select Id from Account where Name = 'Burlington Textiles Corp of America' limit 1];
        //Opportunity opportunity = [select Id,AccountId from Opportunity where Name = 'Burlington Textiles Weaving Plant Generator' limit 1];
        //System.assertEquals(opportunity.AccountId == account.Id,true);
        
        Account account = new Account();
        account.Name = 'New account name';
        insert(account);
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'New opp name'; //required field
        opportunity.StageName = 'Prospect'; //required field
        opportunity.CloseDate = Date.today(); //required field
        opportunity.AccountId = account.Id;
        insert(opportunity);
        
        
        for (Integer i = 0; i < 150; i++){
        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'Name'+i;
        invoice.Account__c = account.Id;
        invoice.Opportunity__c = opportunity.Id;
        invoices.add(invoice);
        }
        
        insert(invoices);
        System.assertEquals(invoices.size(),150); 
        
        Invoice__c invoiceNull;
        
        try{
            invoiceNull = new Invoice__c(Name = 'NameNull');
            invoiceNull.Account__c = null;
            invoiceNull.Opportunity__c = null;
            insert(invoiceNull);
        } catch (DmlException ex){
            System.debug('Account or Opportunity is nullable');
        }
        
        Invoice__c invalidDataInvoice = new Invoice__c(Name = 'Invalid invoice');
        
        
        DmlException expectedException;
    
        try
        {
            invalidDataInvoice.Account__c = account.Id;
            Opportunity opp = new Opportunity(Name = 'invalidOpp',StageName = 'Prospect',CloseDate = Date.today());
            insert opp;
            invalidDataInvoice.Opportunity__c = opp.Id;
            insert invalidDataInvoice;
        } catch(DmlException dmx){
                expectedException = dmx;
         } finally{
            System.assertNotEquals(expectedException, null);
    }
  }

    public static testMethod void insertInvoiceTest() {
        CheckingClass.insertInvoice();
    }
}