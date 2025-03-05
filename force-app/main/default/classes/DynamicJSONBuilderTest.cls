@IsTest
private class DynamicJSONBuilderTest {

    //This is incompatible because it doesn't extend DynamicJSONBuilder.Parsed
    private class IncompatibleType {
        public String username;
        public Integer postCount;
    }

    private static final String SAMPLE_JSON = JSON.serialize(
        new Map<String, Object> {
            'username' => 'testUser123@test.com',
            'postCount' => 5,
            'alias' => 'testUser',
            'contactInfo' => new Map<String, Object> {
                'phoneNumber' => 1234567890,
                'address' => new Map<String, Object> {
                    'street' => 'Test Street 123',
                    'city' => 'City'
                }
            },
            'profile'=> new List<Object>{
                'Facebook', 'Instagram', 'Snapchat'
            }
        }
    );

    @IsTest
    static void parsesAndExposesUnknownFields() {
        DynamicJson example = (DynamicJson)DynamicJSONBuilder.deserialize(SAMPLE_JSON, DynamicJson.class);

        System.assertEquals('testUser', String.valueOf(example.get('alias')));
    }

    @IsTest
    static void parsesAndSetUnKnownFields() {
        DynamicJson example = (DynamicJson)DynamicJSONBuilder.deserialize(SAMPLE_JSON, DynamicJson.class);

        System.assertEquals(5, Integer.valueOf(example.get('postCount')));

        example.set('postCount',7);
        System.assertEquals(7, Integer.valueOf(example.get('postCount')));
    }

    @IsTest
    static void parsesAndExposesNestedUnknownFields() {
        DynamicJson example = (DynamicJson)DynamicJSONBuilder.deserialize(SAMPLE_JSON, DynamicJson.class);

        //Should return existing properties
        System.assertEquals('1234567890', String.valueOf(example.get('contactInfo.phoneNumber')));
        System.assertEquals('Test Street 123', String.valueOf(example.get('contactInfo.address.street')));

        //Should return null for invalid properties
        System.assertEquals(null, example.get('alias.invalidProperty'));
        System.assertEquals(null, example.get('invalidProperty.invalidNestedProperty.evenMoreInvalidProperties'));
    }

    @IsTest
    static void parsesAndExposesNestedUnknownList() {
        try{
            DynamicJson example = (DynamicJson)DynamicJSONBuilder.deserialize(SAMPLE_JSON, DynamicJson.class);
    
            //Should return existing properties
            System.assertEquals('Instagram', String.valueOf(example.get('profile[1]')));
            System.assertEquals('Snapchat', String.valueOf(example.get('profile[2]')));
            
            //Should return exception for list index out of bound
            System.assertEquals('Snapchat', String.valueOf(example.get('profile[3]')));
        } catch(DynamicJSONBuilder.DynamicJSONException e){
            System.assert(true);
        }
    }
    
    @IsTest
    static void parsesAndSetNestedUnknownList() {
        try{
            DynamicJson example = (DynamicJson)DynamicJSONBuilder.deserialize(SAMPLE_JSON, DynamicJson.class);
            //Should return existing properties
            System.assertEquals('Snapchat', String.valueOf(example.get('profile[2]')));
            example.set('profile[2]','Threads');
            System.assertEquals('Threads', String.valueOf(example.get('profile[2]')));
            example.set('contactInfo.address.city','Mumbai');
            System.assertEquals('Mumbai', String.valueOf(example.get('contactInfo.address.city')));
        } catch (DynamicJSONBuilder.DynamicJSONException e){
            System.assert(true);
        }
    }
    
    @isTest
    static void TesttoStringMethod(){
        DynamicJson example = (DynamicJson)DynamicJSONBuilder.deserialize(SAMPLE_JSON, DynamicJson.class);
        String json = example.toString();
        String expectedJson = '{"username":"testUser123@test.com","postCount":5,"alias":"testUser","contactInfo":{"phoneNumber":1234567890,"address":{"street":"Test Street 123","city":"City"}},"profile":["Facebook","Instagram","Snapchat"]}';
        System.assertEquals(expectedJson, json);
    }

    @IsTest
    static void throwsWhenGivenIncompatibleType() {
        try {
            DynamicJSONBuilder.deserialize(SAMPLE_JSON, IncompatibleType.class);
            System.assert(false, 'An exception should have been thrown');
        } catch (DynamicJSONBuilder.DynamicJSONException e) {
            System.assert(true); //Expected exception was thrown
        } catch (Exception e) {
            System.assert(false, 'An unexpected exception was thrown: ' + e);
        }
    }

    @IsTest
    static void throwsWhenGivenNullType() {
        try {
            DynamicJSONBuilder.deserialize(SAMPLE_JSON, null);
            System.assert(false, 'An exception should have been thrown');
        } catch (DynamicJSONBuilder.DynamicJSONException e) {
            System.assert(true); //Expected exception was thrown
        } catch (Exception e) {
            System.assert(false, 'An unexpected exception was thrown: ' + e);
        }
    }
}