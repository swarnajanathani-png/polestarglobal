public class ScreeningServiceTransactionJSONWrapper{
    public cls_objects[] objects;
    public class cls_objects {
        public Integer id;//transaction id
        public String registered_name;  //9722625
        public cls_screen_results[] screen_results;
    }
    public class cls_screen_results {
        public String check;    //COMPANY_SANCTIONS
        public String status;   //OK
    }
    
    public static ScreeningServiceTransactionJSONWrapper parse(String json){
        return (ScreeningServiceTransactionJSONWrapper) System.JSON.deserialize(json, ScreeningServiceTransactionJSONWrapper.class);
    }
}