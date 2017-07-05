/**
 * Created by Rostyslav on 21.06.2017.
 */

public with sharing class LoginPlayerSessionController {
    public String playerEmail{get; set;}
    public String playerPassword {get; set;}
    public LoginPlayerSessionController(){}

    public PageReference login(){
        try {
            playerEmail = ApexPages.currentPage().getParameters().get('playerEmailName');
            Player__c player = [select ID,Name,Password__c,Status__c from Player__c where email__c =: playerEmail limit 1];
            MyException exceptionCausedBadCredentials = new MyException();
            if (player.Password__c != playerPassword){
                exceptionCausedBadCredentials.setMessage('Wrong email or password');
                throw exceptionCausedBadCredentials;
            } else if (player.Status__c != 'Active'){
                exceptionCausedBadCredentials.setMessage('You are not active user. Please, ' +
                        'check your email and find message with confirmation link' +
                        'to verify your account');
                throw exceptionCausedBadCredentials;
            } else {
                Cookie playerCookie = new Cookie('PlayerCookie', player.Id, null, 1440, false);
                ApexPages.currentPage().setCookies(new Cookie[]{playerCookie});
                return Page.HelloWorld;
            }
        } catch (Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
    }
}