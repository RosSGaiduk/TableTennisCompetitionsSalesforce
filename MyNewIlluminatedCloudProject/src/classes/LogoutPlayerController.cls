/**
 * Created by Rostyslav on 22.06.2017.
 */

public with sharing class LogoutPlayerController {

    public LogoutPlayerController(){}

    public PageReference logoutPlayer(){
        //ApexPages.currentPage().getCookies().remove('PlayerCookie');
        Cookie playerCookie = new Cookie('PlayerCookie', '', null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[]{playerCookie});
        return Page.HelloWorld;
    }
}