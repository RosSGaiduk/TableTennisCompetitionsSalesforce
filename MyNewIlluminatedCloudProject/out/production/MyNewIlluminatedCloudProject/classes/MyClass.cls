/*Hello World*/
public class MyClass {
    public static String hello(){
        List<String> myStrings = new List<String>();
        myStrings.add('hello');
        myStrings.add('world');
        myStrings.add('!!!');
        String myStr = '';
        for (String s: myStrings){
          myStr+=s;
        }
        List<Opportunity> opportunities = new List<Opportunity>();
        return myStr;
    }

    public static void allInv(){
        /*Opportunity__r.Name,Account__r.Name*/
        /*List<Invoice__c> invoices = [select i.Name from Invoice__c i where i.Opportunity__r.Id != null];*/

        List<Invoice__c> invoices = [select i.Name from Invoice__c i where i.Account__r.Id in (select Id from Invoice__c where Invoice__c.Name = '')];

        /*List<Invoice__c> invoices = [select i.Name from Invoice__c i where i.Account__c != null];*/

        /*List<Invoice__c> invoices = [select i.Name from Invoice__c i where
                                     i.Account__c in (select o.AccountId from Opportunity o where o.Name = i.Name)];
        */

        for (Invoice__c inv: invoices){
            System.debug(inv.Name);
        }
    }
}