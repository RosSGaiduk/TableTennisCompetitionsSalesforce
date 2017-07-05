/**
 * Created by Rostyslav on 17.06.2017.
 */
public with sharing class CheckingClass {
    public static void checkAccountAndOppTrigger(Invoice__c []invoices,Integer startIndex,List<Opportunity> opportunityAccountsId){
        Integer addingStep = invoices.size();

        if (invoices == null) {
                System.debug('Invoices == null');
                return;
       }
        if (startIndex == 0){
            List<String> ids = new List<String>();
            for (Integer i = 0; i < invoices.size(); i++){
                ids.add(invoices.get(i).Opportunity__c);
            }
            opportunityAccountsId = [select Id,AccountId from Opportunity where Id in :ids];
        }
        
        if (startIndex < invoices.size()){
            List<Invoice__c> currentInvoices = new List<Invoice__c>();
            Integer max = invoices.size()>startIndex+addingStep?(startIndex+addingStep):invoices.size();
            
            for (Integer i = startIndex; i < max; i++){
                currentInvoices.add(invoices.get(i));
                currentInvoices.get(currentInvoices.size()-1).Account__c = invoices.get(i).Account__c;
            }
            
     
            for (Invoice__c inv: currentInvoices) {
            //Opportunity opportunityAccountId = [select AccountId from Opportunity where Id = :inv.Opportunity__c limit 1];
            System.debug('INVACC: '+inv.Account__c);
                Opportunity opp;
                for (Integer index = 0; index < opportunityAccountsId.size(); index++){
                    if (opportunityAccountsId.get(index).Id == inv.Opportunity__c){
                        opp = opportunityAccountsId.get(index);
                        break;
                    }
                }    
            
           
            if (inv.Account__c != null && inv.Opportunity__c != null){  
            if (inv.Account__c != opp.AccountId) {
                    System.debug('INV:' + inv);
                    inv.addError('An error occured while inserting new invoice: selected opportunity is not reated to the selected account');
                    return;
                }
               } else {
                   System.debug('Inv.opp or Inv.account == null:');
               }  
            }
            startIndex+=addingStep;
            checkAccountAndOppTrigger(invoices,startIndex,opportunityAccountsId);
        } else {
            return;
        }
      }


    public static void checkAccountAndOppTrigger(Map<Id,Invoice__c> invoices){
        Map<Id, Invoice__c> check = new MAP<Id, Invoice__c>([select Id,Account__c,Opportunity__r.AccountId from Invoice__c where id = :invoices.keySet()]);
        for (Invoice__c invoice: invoices.values()){
            if (invoice.Account__c != check.get(invoice.id).Opportunity__r.AccountId){
                invoice.addError('(After insert) An error occured while inserting new invoice: selected opportunity is not reated to the selected account');
            }
        }
    }


    public static void insertInvoice(){
        System.debug('Hello');
        try {
            insert generateInvoice('Name1','Burlington Textiles Corp of America','Burlington Textiles Weaving Plant Generator');
        } catch(QueryException ex){
            System.debug('Query exception occured!!!');
        } finally {
            System.debug('End of inserting method');
        }
    }


    public static  void insertListOfIvoices(){
        List<Invoice__c> invoices = new List<Invoice__c>();
        try {
            invoices.add(generateInvoice('Name1','Burlington Textiles Corp of America','Burlington Textiles Weaving Plant Generator'));
            invoices.add(generateInvoice('Name2','Burlington Textiles Corp of America','Burlington Textiles Weaving Plant Generator'));
            insert invoices;
        } catch(QueryException ex){
            System.debug('Query exception occured!!!');
        } finally {
            System.debug('End of inserting method');
        }
    }
    
    public static  void insert_A_LOT_OF_Invoices(){
        List<Invoice__c> invoices = new List<Invoice__c>();
        //                                                                              Burlington Textiles Weaving Plant Generator
        Invoice__c inv = generateInvoice('Name1','Burlington Textiles Corp of America','Burlington Textiles Weaving Plant Generator');
        Invoice__c inv1 = generateInvoice('Name1','Burlington Textiles Corp of America','CEO');
        try {
            
                Invoice__c inv2 = new Invoice__c();
                inv2.Account__c = inv.Account__c;
                inv2.Opportunity__c = inv.Opportunity__c;
                inv2.Name = 'Name';
                invoices.add(inv2);
            
            for (Integer i = 0; i < 150; i++){
                Invoice__c inv3 = new Invoice__c();
                inv3.Account__c = inv1.Account__c;
                inv3.Opportunity__c = inv1.Opportunity__c;
                inv3.Name = 'Name'+i;
                invoices.add(inv3);
            }
            
            insert invoices;
        } catch(QueryException ex){
            System.debug('Query exception occured!!!');
        } finally {
            System.debug('End of inserting method');
        }
    }


    public static Invoice__c generateInvoice(String name,String accountName,String opportunityName){
        Invoice__c invoice = new Invoice__c(
                Name = name
        );
        Account account = [select Name,Id from Account where Name =: accountName limit 1];
        Opportunity opportunity = [select Name,Id from Opportunity where Name =: opportunityName limit 1];
        invoice.Account__c = account.Id;
        invoice.Opportunity__c = opportunity.Id;
        return invoice;
    }
    
    public static void deleteAllInvoices(){
        List<Invoice__c> invoices = [select Id from Invoice__c];
        try{
            delete invoices;
        } catch(DmlException ex){
            System.debug('Error while deleting recs');
        }
    }
}