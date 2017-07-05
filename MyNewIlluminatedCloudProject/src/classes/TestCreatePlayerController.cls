/**
 * Created by Rostyslav on 22.06.2017.
 */

@isTest
public with sharing class TestCreatePlayerController {

    public static testMethod void testSaveEmail(){
        Player__c player = new Player__c(
                Name = 'Player',
                Email__c = 'rgaidukevich9@gmail.com',
                Password__c = '12345678910',
                Status__c = 'Active'

        );
       CreatePlayerController createPlayerController = new CreatePlayerController();
       createPlayerController.player = player;

       //Trying to send too many emails
       //for (Integer i = 0; i < 100; i++) createPlayerController.sendEmail();

       //Passwords are the same
       createPlayerController.confirmPassword = '12345678910';
       createPlayerController.save();

       //Passwords are not the same
       createPlayerController.confirmPassword = '123456789';
       createPlayerController.save();
    }
}