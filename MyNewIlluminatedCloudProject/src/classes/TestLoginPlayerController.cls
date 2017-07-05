/**
 * Created by Rostyslav on 22.06.2017.
 */

@isTest
public with sharing class TestLoginPlayerController {
    public static testMethod void testCheckValidUser() {
        LoginPlayerSessionController loginPlayerSessionController = new LoginPlayerSessionController();
        loginPlayerSessionController.playerEmail = 'rgaidukevich9@gmail.com';
        loginPlayerSessionController.playerPassword = 'somePassword';
        loginPlayerSessionController.login();
    }
}