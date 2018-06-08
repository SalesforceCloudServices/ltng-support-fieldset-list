/**
 * Controller for the ltng_FieldSetHelper component.
 **/
public with sharing class ltng_FieldSetHelperCtrl {

    /** PermissionSet URL Template **/
    public static final String URL_PERMISSION_SET = '/_ui/common/config/entity/FieldSetListUI/d?setupid=CustomObjects&tableEnumOrId=';

    /** object edit URL Template **/
    public static final String URL_SOBJECT_DETAIL = '/lightning/setup/ObjectManager/{0}/Details/view';

    /**
     * Determines different URLs to help edit the object (if the user is a system administrator)
     * @param recordId (Id) - Id of the type of SObject to work with
     * @return SObjectInfo - custom object with urls of how to work with this sObject.
     **/
    @AuraEnabled
    public static SObjectInfo getSObjectInfo(Id exampleRecordId){
        SObjectInfo result = new SObjectInfo();

        Boolean doesUserHaveAccess = doesUserHaveModifyAllDataPermission(UserInfo.getUserId());

        DescribeSObjectResult sObjectDescribe;
        String sObjectDurableId;
        
        try {
            if( doesUserHaveAccess ){
                sObjectDescribe = exampleRecordId.getSObjectType().getDescribe();
                sObjectDurableId = getSObjectDurableId(sObjectDescribe);
                
                result.sObjectName = sObjectDescribe.getLabel();
                result.fieldSetURL = URL_PERMISSION_SET + sObjectDurableId;
                result.sObjectURL = string.format( URL_SOBJECT_DETAIL, new String[]{ sObjectDurableId });
            }
        } catch( Exception err ){
            throw new AuraHandledException('Exception occurred while determining the object information:' + err.getMessage());
        }
        
        return( result );
    }

    /**
     * Internal class for returning SObject information
     */
    public class SObjectInfo {

        /** SObject Name **/
        @AuraEnabled
        public String sObjectName;

        /** URL to work with fieldsets for this SObject **/
        @AuraEnabled
        public String fieldSetURL;

        /** URL to work with the fields for the SObject **/
        @AuraEnabled
        public String sObjectURL;
    }



    /**
     * Determines the URL to navigate the user to, if they wanted to update the FieldSets
     * for this object.
     * @param recordId (Id) - id of the type of SObject to work with.
     * @return String - address to redirect them to or null - if no access.
     **/
    @AuraEnabled
    public static String getFieldSetEditURL(Id exampleRecordId){
        String result = null;

        Boolean doesUserHaveAccess = doesUserHaveModifyAllDataPermission(UserInfo.getUserId());
        DescribeSObjectResult sObjectDescribe;
        String sObjectName;
        String sObjectDurableId;

        try {
            if( doesUserHaveAccess ){
                sObjectDescribe = exampleRecordId.getSObjectType().getDescribe();
                sObjectName = sObjectDescribe.getName();
                sObjectDurableId = getSObjectDurableId(sObjectName);
                
                result = URL_PERMISSION_SET + sObjectDurableId;
            }
        } catch( Exception err ){
            throw new AuraHandledException('Exception occurred while determining the object information:' + err.getMessage());
        }

        return( result );
    }

    /**
     * Determines if the current user can modify permission sets for a given SObject.
     * (In this case the SObject is identified by an example recordId of that SObject)
     * @param recordId (Id) - id of the type of record that we want to work with.
     * @return Boolean - true (they can) - false (they cannot)
     * @see canUserModifyPermissionSetsForSObject(String)
     **/
    @AuraEnabled
    public static Boolean canUserModifyPermissionSetsForRecord(Id exampleRecordId){
        Boolean result = false;

        //-- @TODO: evaluate if this can be removed.
        /*
        String SObjectName = null;
        try {
            //-- for more information: https://help.salesforce.com/articleView?id=How-to-find-Object-Type-from-Record-ID-Prefix&language=en_US&type=1
            SObjectName = exampleRecordId.getSobjectType().getDescribe().getName();
        } catch( Exception err ){
            System.debug('Exception occurred while finding the sObject type for:' + exampleRecordId);
        }
        */

        result = doesUserHaveModifyAllDataPermission(UserInfo.getUserId());

        return( result );
    }

    /**
     * Determines if the current user has modifyAllData permission
     * @return Boolean - true or false
     **/
    public static Boolean doesUserHaveModifyAllDataPermission(Id userId){
        Boolean result = false;

        try {
            PermissionSetAssignment[] modifyAllDataAssignments = [
                SELECT Id, AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId AND PermissionSet.PermissionsModifyAllData = true
            ];
            result = modifyAllDataAssignments.size() > 0;
        } catch( Exception err ){
            System.debug('Exception occurred while determining if user has modifyAllDataPermission. ' + err.getMessage());
        }

        return( result );
    }

    /**
     * Determines the DurableId for an sObject
     * @param sObjectDescribe (DescribeSObjectResult)
     * @return (String) - the durable id for that sObject
     **/
    public static String getSObjectDurableId( DescribeSObjectResult sObjectDescribe ){
        return getSObjectDurableId(sObjectDescribe.getName());
    }

    /**
     * Determines the DurableId for an sObject
     * @param sObjectName (String)
     * @return (String) - the durable id for that sObject
     **/
    public static String getSObjectDurableId( String sObjectName ){
        String result = null;

        EntityDefinition sObjectDefinition = [
            SELECT Id, QualifiedApiName, DurableId
            FROM EntityDefinition
            WHERE QualifiedApiName = :sObjectName
            LIMIT 1
        ];
        result = sobjectDefinition.DurableId;

        return(result);
    }
}