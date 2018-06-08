/**
 *  Controller for ltng_FieldSetContainer Lightning Component.
 *  @see https://metillium.com/2018/02/lightning-field-set-form-component-v2/
 **/
public with sharing class ltng_FieldSetContainerCtrl {
    
    /**
     * Determines the fields for a given fieldSet off an object.
     * @param fieldSetName (String) - API Name of the FieldSet.
     * @param recordId (Id) - id of the record
     * @param sObjectName (String?) - Name of the SObject - only needed if recordId not provided
     * @return (FormInfo) - container with the fields to return
     **/
    @AuraEnabled
    public static FormInfo getForms(String[] fieldSetNames, Id recordId, String sObjectName) {
        UserRecordAccess accessRights = getRecordAccess(null, recordId);
        FormInfo results = new FormInfo(accessRights);
        FieldSetInfo form;
        Schema.FieldSet[] fieldSetDescribes = getFieldSetDescribe(fieldSetNames, recordId, sObjectName);

        for(Schema.FieldSet fieldSetDescribe : fieldSetDescribes){
            form = new FieldSetInfo(fieldSetDescribe);
            form.Fields = getFields(fieldSetDescribe);
            results.FieldSets.add(form);
        }
        
        return results;
    }

    /*
    @AuraEnabled
    public static FieldSetInfo getForm(String fieldSetName, Id recordId, String sObjectName){
        FieldSetInfo[] results = getForms( new String[]{ fieldSetName }, recordId, sObjectName );
        FieldSetInfo result = null;

        if( results.size() > 0 ){
            result = results[0];
        }

        return(result);
    }
    */

    /**
     * Determines the user's access to the record
     * @param userId (Id) - id of the user requesting access
     * @param recordId (Id) - id of the record to access
     * @return UserRecordAccess
     **/
    public static UserRecordAccess getRecordAccess( Id userId, Id recordId ){
        UserRecordAccess results;
        if( userId == null ){
            userId = UserInfo.getUserId();
        }
        try {
            results = [
                SELECT HasAllAccess, HasDeleteAccess, HasEditAccess, HasReadAccess, MaxAccessLevel, RecordId
                FROM UserRecordAccess
                WHERE RecordId=:recordId and UserId=:userId
                LIMIT 1
            ];
        } catch(Exception err){
            throw new AuraHandledException('Unable to find record:' + recordId + ', to determine access');
        }
        return(results);
    }

    /**
     * Determines the FieldSet Describe for a given SObject.
     * @param fieldSetNames (String[]) - API Name of the FieldSet.
     * @param recordId (Id) - id of the record
     * @param sObjectName (String?) - Name of the SObject - only needed if id not provided
     * @return (Schema.FieldSet[])
     **/
    public static Schema.FieldSet[] getFieldSetDescribe(String[] fieldSetNames, Id recordId, String sObjectName){
        Schema.FieldSet[] results = new Schema.FieldSet[]{};
        Schema.SObjectType objectType = null;
        Schema.DescribeSObjectResult objectDescribe;
        Map<String, Schema.FieldSet> fieldSetMap;

        if (recordId != null) {
            objectType = recordId.getSobjectType();
        } else if (String.isNotBlank(sObjectName)) {
            objectType = Schema.getGlobalDescribe().get(sObjectName);
        }

        objectDescribe = objectType.getDescribe();
        fieldSetMap = objectDescribe.fieldSets.getMap();

        for( String fieldSetName : fieldSetNames){
            if( fieldSetMap.containsKey(fieldSetName)){
                results.add(fieldSetMap.get(fieldSetName));
            }
        }

        return(results);
    }
    
    /**
     * Determines the fields for a given FieldSet off a given SObject
     * @param fieldSetDescribe (Schema.FieldSet)
     * @return FieldInfo[] - collection of FieldInfo values
     **/
    public static FieldInfo[] getFields(Schema.FieldSet fieldSetDescribe){
        Schema.FieldSetMember[] fieldSetMembers = fieldSetDescribe.getFields();
        FieldInfo[] results = new FieldInfo[]{};

        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            results.add(new FieldInfo(fsm));
        }

        return(results);
    }

    /**
     * Respresents the response from the request.
     * encapsulating whether the user can actually edit the record
     **/
    public class FormInfo {

        @AuraEnabled
        public Id RecordId {get;set;}

        @AuraEnabled
        public Boolean HasReadAccess {get;set;}

        @AuraEnabled
        public Boolean HasEditAccess {get;set;}

        @AuraEnabled
        public FieldSetInfo[] FieldSets {get;set;}

        public FormInfo(UserRecordAccess accessRights){
            this.RecordId = accessRights.recordId;
            this.HasReadAccess = accessRights.HasReadAccess;
            this.HasEditAccess = accessRights.HasEditAccess;
            this.FieldSets = new FieldSetInfo[]{};
        }
    }
    
    /**
     * Internal class to provide to the Lightning Component
     * encapsulating Schema.FieldSet
     **/
    public class FieldSetInfo {

        @AuraEnabled
        public String APIName {get;set;}

        @AuraEnabled
        public String Label {get;set;}

        @AuraEnabled
        public String Description {get;set;}

        @AuraEnabled
        public String SObjectName {get;set;}

        @AuraEnabled
        public FieldInfo[] Fields { get; set; }

        public FieldSetInfo(Schema.FieldSet fieldSetDescription){
            if( fieldSetDescription != null ){
                this.APIName = fieldSetDescription.getName();
                this.Label = fieldSetDescription.getLabel();
                this.Description = fieldSetDescription.getDescription();
                this.SObjectName = fieldSetDescription.getSObjectType().getDescribe().getName();
            }
            this.Fields = new List<FieldInfo>();
        }
    }
    
    /**
     * Internal class to provide to the lightning component
     * encapsulating info from Schema.FieldSetMember.
     **/
    public class FieldInfo {
    
        public FieldInfo(Schema.FieldSetMember fsm) {
            this.DBRequired = fsm.DBRequired;
            this.APIName = fsm.fieldPath;
            this.Label = fsm.label;
            this.FSRequired = fsm.required;
            this.Required = this.FSRequired || this.DBRequired;
            this.Type = String.valueOf(fsm.getType());
        }
        
        @AuraEnabled
        public Boolean DBRequired { get;set; }
        
        @AuraEnabled
        public String APIName { get;set; }
        
        @AuraEnabled
        public String Label { get;set; }
        
        @AuraEnabled
        public Boolean Required { get;set; }

        @AuraEnabled
        public Boolean FSRequired { get;set; }
        
        @AuraEnabled
        public String Type { get; set; }
    }
}