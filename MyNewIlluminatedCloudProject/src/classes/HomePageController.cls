/**
 * Created by Rostyslav on 21.06.2017.
 */

public with sharing class HomePageController extends CookiePlayerAndPermissinsController{
    public List<String> values {get;set;}
    public HomePageController(){
        values = new List<String>();
        String value1 = JSON.serialize('{"res":true,"count":1}');
        String value2 = JSON.serialize('{"res":false,"count":2}');
        values.add(value1);
        values.add(value2);
    }
}