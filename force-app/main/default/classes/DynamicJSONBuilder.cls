public class DynamicJSONBuilder {

    private static final String getValue = 'GET';
    private static final String setValue = 'SET';

    public abstract class Parsed {
        private Map<String, Object> jsonFields;
        
        public Object get(String key) {
            //return safelyReadJSONValue(jsonFields, key);
            return GetSetJSONValue(jsonFields, getValue, key, '');
        }
        public void set(String key, Object value){
            //safelySetJSONValue(jsonFields, key, value);
            GetSetJSONValue(jsonFields, setValue, key, value);
        }

        protected void setFields(Map<String, Object> pFields) {
            jsonFields = pFields;
        }
    
        public override String toString() {
            return JSON.serialize(jsonFields);
        }
    }

    public static Object deserialize(String jsonString, Type targetType) {
        validateTargetType(targetType);
        Parsed parsedJson = (Parsed)JSON.deserialize(jsonString, targetType);
        parsedJson.setFields((Map<String,Object>)JSON.deserializeUntyped(jsonString));
        return parsedJson;
    }

    private static Object GetSetJSONValue(Map<String, Object> jsonData, String action, String identifier, Object value) {
        List<String> nestedKeys = identifier.split('\\.');

        if(nestedKeys.size() == 1) {
            if(action==getValue) return getNestedObject(jsonData, nestedKeys.remove(0));
            else if(action==setValue) {
                if(!nestedKeys[0].contains('[')){ 
                    jsonData.put(identifier, value);
                    return null;
                }
                else{
                    Object jsonValue = getNestedObject(jsonData, identifier.substringBefore('['));
                    if(jsonValue instanceOf List<Object>){
                        Integer index = Integer.valueOf(identifier.substringBetween('[',']'));
                        if(index < ((List<Object>) jsonValue).size()){
                            ((List<Object>) jsonValue).set(index, value);
                        }
                    }
                    return null;
                }
            }
        }
        String topLevelKey = nestedKeys.remove(0);
        Object jsonValue = getNestedObject(jsonData, topLevelKey);

        if(jsonValue != null && jsonValue instanceof Map<String,Object>) {
            return GetSetJSONValue((Map<String,Object>)jsonValue, action,  String.join(nestedKeys, '.'),value);
        } else {
            return null;
        } 
    }

    private static Object getNestedObject(Map<String, Object> jsonData, String identifier){
        if(!identifier.contains('[')){
            return jsonData.get(identifier);
        }

        Integer index = Integer.valueOf(identifier.substringBetween('[',']'));
        identifier = identifier.substringBefore('[');
        
        Object jsonValue = jsonData.get(identifier);
        
        if(jsonValue instanceOf List<Object>){
            List<Object> nestedList = (List<Object>) jsonValue;
            if(nestedList.size()<=index){
                throw new DynamicJSONException('List index out of bounds: '+index);
            }
            jsonValue = nestedList[index];
        }
        return jsonValue;
    }

    private static void validateTargetType(Type targetType) {
        if(targetType == null) {
            throw new DynamicJSONException('Target Type cannot be null');
        } else if (!Parsed.class.isAssignableFrom(targetType)) {
            throw new DynamicJSONException('Target Type must be a subclass of DynamicJSON.Parsed');
        }
    }

    public class DynamicJSONException extends Exception {}
}