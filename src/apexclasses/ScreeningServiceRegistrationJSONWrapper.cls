public class ScreeningServiceRegistrationJSONWrapper {
    public Integer transaction_id;  //2450317
    public static ScreeningServiceRegistrationJSONWrapper parse(String json){
        return (ScreeningServiceRegistrationJSONWrapper) System.JSON.deserialize(json, ScreeningServiceRegistrationJSONWrapper.class);
    }
}