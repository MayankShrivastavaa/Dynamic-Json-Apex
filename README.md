# Typed JSON Parsing with Dynamic properties in Apex

## Background

Feature enhancement to [Adrian Castellanos Gutierrez's](https://github.com/adrian-cg) implementation to support [Dynamic-json-in-apex](https://github.com/adrian-cg/dynamic-json-apex) \
Inspired by [Adrian Castellanos Gutierrez's](https://github.com/adrian-cg) , [Robert Sösemann's tweet](https://twitter.com/rsoesemann/status/1270484037551951872) and [StackExchange question](https://salesforce.stackexchange.com/questions/309042/handle-unknown-properties-with-typed-json-deserialize). 


The problem at hand is the ability to parse JSON with some known properties but still be able to dynamically access the one's you don't know. It felt like an interesting problem to solve in Apex so I searched for online resources that support this use case and found [Dynamic-json-apex](https://github.com/adrian-cg/dynamic-json-apex).

There were a few limitations to this implementation. Main two:

1. Lack of Write Support: The existing implementation only supports reading JSON with no support for writing, making it unusable for most cases where updates are required.
2. No Support for Accesing List Elements: The existing implementation does not support accessing elements when a node is an array or list, making it difficult to work with dynamic JSON structures.

## Take 2

With those two issues in mind, I tried again. The focus was on to able to update JSON element values and read/write deep nested elements along with Lists/Array elements:

1. Very little boilerplate: You only need to create an instance of DynamicJson class for each new JSON.

```apex
DynamicJson wrapper = (DynamicJson)DynamicJSONBuilder.deserialize(YourJsonString, DynamicJson.class);
```
2. The following are methods for dynamicJson. All are instance methods.
```apex
get(node)
Returns the value of Json node.

set(node, value)
Sets the specified value for the element at the given node.
 
toString()
Returns the string representation of the json.  
```

we can easily get/set json elements, much like using Map functions:

```apex
/*
{
  "some": {
    "deeplyNested" {
      "property": "failure"
      "ListElement": ["One","Two","Four"]
  }
}
*

wrapper.set('some.deeplyNested.property''Success') 
wrapper.get('some.deeplyNested.property')   //Success

wrapper.get('some.deeplyNested.ListElement[2]')    //Four
wrapper.set('some.deeplyNested.ListElement[2]','Three')
```

## Examples

Some examples of how this works can be found in the [Apex Test Class](force-app/main/default/classes/DynamicJSONBuilderTest.cls).