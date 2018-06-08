/**
 *  Controller for ltng_FieldSetForm Lightning Component.
 *  @see https://metillium.com/2018/02/lightning-field-set-form-component-v2/
 **/
public with sharing class ltng_FieldSetFormCtrl {
    
    @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName, String fieldSetName) {
        FieldSetForm form = new FieldSetForm();        
        form.Fields = getFields(recordId, objectName, fieldSetName);
        
        return form;
    }
    
    private static List<Field> getFields(Id recordId, String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;
        
        if (recordId != null) {
            objectType = recordId.getSobjectType();
        }
        else if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }
        
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();

        List<Field> fields = new List<Field>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            Field f = new Field(fsm);

            fields.add(f);
        }

        return fields;
    }
    
    public class FieldSetForm {
        @AuraEnabled
        public List<Field> Fields { get; set; }

        public FieldSetForm() {
            Fields = new List<Field>();
        }
    }
    
    //-- internal class
    public class Field {
    
        public Field(Schema.FieldSetMember f) {
            this.DBRequired = f.DBRequired;
            this.APIName = f.fieldPath;
            this.Label = f.label;
            this.Required = f.required;
            this.Type = String.valueOf(f.getType());
        }
        
        public Field(Boolean DBRequired) {
            this.DBRequired = DBRequired;
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
        public String Type { get; set; }
    }
}