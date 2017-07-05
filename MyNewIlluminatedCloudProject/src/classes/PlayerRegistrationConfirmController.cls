/**
 * Created by Rostyslav on 20.06.2017.
 */

public with sharing class PlayerRegistrationConfirmController {

    public Id ID_Player{ get {
        //ID_Player = 'a0858000017fAdRAAU';
        return ID_Player;
    }
        set;
    }

    public PlayerRegistrationConfirmController(){
        //ID_Player = 'a0858000017fAdRAAU';
    }


    public PageReference confirmPlayer(){
        Player__c player = [select Id,Status__c from Player__c where Id =: ID_Player limit 1];
        player.Status__c = 'Active';
        update player;
        return Page.HelloWorld;
    }
}