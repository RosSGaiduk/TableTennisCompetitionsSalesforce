/**
 * Created by Rostyslav on 27.06.2017.
 */

public with sharing abstract class CookiePlayerAndPermissinsController {

    public Player__c playerCookie {get;set;}
    public Boolean isAdmin {get;set;}
    public Boolean loggedIn {get;set;}

    public CookiePlayerAndPermissinsController(){
        loggedIn = ApexPages.currentPage().getCookies().get('PlayerCookie')!=null;
        if (loggedIn) {
            Id playerId = ApexPages.currentPage().getCookies().get('PlayerCookie').getValue();
            playerCookie = [select Id,Name,isAdmin__c,Email__c from Player__c where Id = :playerId];
            isAdmin = playerCookie.isAdmin__c;
        } else {
            isAdmin = false;
        }
    }
}