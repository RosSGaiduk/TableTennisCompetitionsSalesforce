/**
 * Created by Rostyslav on 22.06.2017.
 */

@isTest(seeAllData = true)
public with sharing class TestCreatePlayerController {

    public static testMethod void testSaveEmail(){
       CreatePlayerController createPlayerController = new CreatePlayerController();
       createPlayerController.player = [select Id,Name,Email__c from Player__c limit 1];
        for (Integer i = 0; i < 100; i++) createPlayerController1.sendEmail();
    }
}