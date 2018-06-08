/**
 * Controller for the Demo Setup page.
 **/
/*
 * //-- CHANGE
 * //-- ensure the class name matches the name of the Setup page + CTRL
 * //-- ex: ltng_FieldSetListDemoSetupCtrl
 **/
global with sharing class ltng_FieldSetListDemoSetupCtrl {

    //-- static
    
    /** URL patterm for navigating to a permissionSet **/
    global static final String DEFAULT_MISSING_PERMISSION_URL = '/one/one.app#/setup/PermSets/home';
    
    //--    -   -   -   -   -   -   -   -   -   -   -
    //-- START OF LINES TO UPDATE
    //--    -   -   -   -   -   -   -   -   -   -   -
    
    //-- set the values that specific to your project
    
    /** Developer Name for the Permission Set **/
    global static final String PERMISSION_SET_NAME = 'FieldSetListDemoParticipant';
    
    /**
     * API Name of the Object to create.
     *  (Although not required, it is fairly common to create objects in setup)
     **/
    global static final String CHILD_SOBJECT_NAME  = 'ltng_FieldSetListDemoBase';
    
    /** Developer Name of the record types to use when creating records
        (Leave blank if no record types are used)
    **/
    global static final String RT_NAME = 'Standard';

    

    /**
     * Method called from the Lightning Component to either:
     *      Determine the steps that will be run,
     *      Or to run the steps and learn the results from running them.
     * 
     * @return SetupStep[] - list of setup steps ran and the status for each.
     **/
    @AuraEnabled
    global static SetupStep[] runSetup(boolean getInfoOnly){
        
        //-- Each method that is called returns a SetupStep instance.
        
        //-- if getInfoOnly is `TRUE`, then nothing is executed,
        //-- and we only get info about the step to be run.
        
        //-- if getInfoOnly is `FALSE`, then the step is executed
        //-- and info about what was run, including results/errors/etc., are returned.
        
        SetupStep[] results = new SetupStep[]{
            removeAllBaseRecords(getInfoOnly),
            createBaseRecords(getInfoOnly),
            addUserToPermissionSet(getInfoOnly)
            //-- @CHANGE: add in additional steps as desired
        };
        return results;
    }

    //-- actual steps to run

    /**
     * Remove any of the base records that are currently there.
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    global static SetupStep removeAllBaseRecords( boolean getInfoOnly){
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Remove any existing base objects'
        });

        if(getInfoOnly){
            return step;
        }
        
        SObject[] recordsToDelete = null;
        try {
            recordsToDelete = [
                SELECT Id
                FROM ltng_FieldSetListDemoBase__c
            ];
            
            delete recordsToDelete;
        } catch(Exception err){
            step.errMsg = 'Error occurred while attempting to delete all base records';
            step.devErrMsg = err.getMessage();
            //-- do nothing for now.
            System.debug(step.errMsg);
        }
        
        step.markCompleted();
        return(step);
    }

    /**
     * Create the base records.
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    global static SetupStep createBaseRecords( boolean getInfoOnly ){
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Create Base Objects',
            'descr' => 'Create the objects that the demos start from'
        });

        if(getInfoOnly){
            return step;
        }
        
        //-- determine the record type Names => Salesforce ID translation map
        Set<String> RECORD_TYPE_NAMES = new Set<String>{RT_NAME};
        
        Map<String,Id> recordTypeMap = new Map<String,Id>();
        try {
            if( !String.isEmpty(RT_NAME)){
                for( RecordType rt : [
                    SELECT Id, DeveloperName, Name, SObjectType
                    FROM RecordType
                    WHERE DeveloperName in :RECORD_TYPE_NAMES
                ]){
                    recordTypeMap.put(rt.DeveloperName, rt.Id);
                }
            }
        } catch(Exception err){
            //-- for now, consume the error, as we handle it separately
        }
        
        ltng_FieldSetListDemoBase__c[] baseRecords = new ltng_FieldSetListDemoBase__c[]{};
        ltng_FieldSetListDemoBase__c baseRecord;
        
        baseRecords.add( new ltng_FieldSetListDemoBase__c(
            Name = 'Example Record',
            BillingCity__c = 'Oak Park',
            BillingPostalCode__c = '60302',
            BillingState__c = 'IL',
            BillingStreet__c = '951 Chicago Ave',
            Description__c = '<p>Base Example for FieldSets within Lightning Experience.</p>',
            ExampleCheckbox__c = true,
            ExampleDate__c = Date.valueOf('2018-06-07'),
            ExampleLongText__c = 'I know the kings of England, and I quote the fights historical\r\nFrom Marathon to Waterloo, in order categorical;\r\nI\'m very well acquainted, too, with matters mathematical,\r\nI understand equations, both the simple and quadratical,\r\nAbout binomial theorem I\'m teeming with a lot o\' news,\r\nWith many cheerful facts about the square of the hypotenuse.',
            ExampleNumber__c = 41,
            ExamplePicklist__c = 'PR',
            ExampleRichText__c = '<p>With many cheerful facts about the square of the <b>hypotenuse</b></p><p><b>WITH MANY CHEERFUL FACTS ABOUT THE SQUARE OF THE HYPOTENUSE.</b></p><p>Just how the devil do you correctly spell HY-PO-TEN-USE?</p><p>I do not know, I cannot know, and will not consider it any further.</p>',
            ExampleTextArea__c = 'I am the very model of a modern major general\r\nI\'ve information vegetable, animal and mineral',
            ExampleText__c = 'Example Text',
            Firstname__c = 'Johnny',
            LastName__c = 'Doe',
            RequiredFieldByLayout__c = 'Absolutely!',
            RequiredFieldByObject__c = 'Well, of course!',
            ShippingCity__c = 'Chicago',
            ShippingPostalCode__c = '60637',
            ShippingState__c = 'IL',
            ShippingStreet__c = '5757 S Woodlawn Ave',
            SubType__c = 'Type A - Variant',
            Type__c = 'Type A',
            RecordTypeId = recordTypeMap.get(RT_NAME)
        ));
        
        try {
            insert baseRecords;

            //step.seeMore = baseRecords[0].Id;
        } catch( Exception err){
            step.errMsg = 'error occurred while creating base records';
            step.devErrMsg = err.getMessage();
            System.debug(step.errMsg);
        }

        step.markCompleted();
        return(step);
    }
    
    //-- @CHANGE: add in any additional steps
    /**
     * Example step
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    /*
    global static SetupStep doSomethingElse( boolean getInfoOnly ){
        //-- @SEE SetupStep below - displayed in lightning component DemoSetupItem.cmp
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Assign current user PermissionSet to see the Demo',
            'descr' => 'PermissionSet: ' + PERMISSION_SET_NAME + '. May take a second to take effect.',
            'reasoning' => 'All access is granted by PermissionSet. Only those with this PermissionSet can see the demo'
        });
    
        if( getInfoOnly ){
            return(step);
        }
        
        //-- do stuff
        try {
            //-- do stuff
        } catch(Exception err){
            step.errMsg = 'Could not do stuff';
            step.devErrMsg = err.getMessage();
        }
        
        step.markCompleted();
        return(step);
    }
    */
    
    
    //--    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    //--    END OF LINES TO UPDATE
    //--    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    

    
    //--    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    
    
    /**
     * Assign the user to the custom permission.
     * <p>Note: actual work must be a future to avoid a MixedDML issue</p>
     **/
    global static SetupStep addUserToPermissionSet( boolean getInfoOnly ){
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Assign current user PermissionSet to see the Demo',
            'descr' => 'PermissionSet: ' + PERMISSION_SET_NAME + '. May take a second to take effect.',
            'reasoning' => 'All access is granted by PermissionSet. Only those with this PermissionSet can see the demo'
        });

        if( getInfoOnly ){
            return(step);
        }

        addUserToPermissionSetImpl();

        step.markCompleted();
        return(step);
    }

    
    /**
     * Implementation that actually adds the user to the permission set.
     **/
    @future
    global static void addUserToPermissionSetImpl(){    
        Id userId = UserInfo.getUserId();
        PermissionSetAssignment[] results = null;
        
        try {
            PermissionSet ps = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name = :PERMISSION_SET_NAME
                LIMIT 1
            ];

            results = [
                SELECT Id, PermissionSetId, AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId
                    AND PermissionSetId = :ps.Id 
                LIMIT 1
            ];
            
            if(results.size() > 0){
                System.debug('User is already assigned to the PermissionSet');
            } else {
                results = new PermissionSetAssignment[]{
                    new PermissionSetAssignment( PermissionSetId = ps.Id, AssigneeId = UserInfo.getUserId() )
                };

                insert results;
            }
        } catch(Exception err){
            //-- do nothing
            System.debug('ERROR - could not assign user to permission set');
            System.debug(err.getMessage());
        }
    }
    
    
    /**
     * Determine the URL to send people to so they can assign the PermissionSet
     * the recordTypes needed.
     * 
     * <p>Only needed if objects are created and there are Record Types.
     *  (As there is a bug where PermissionSet assignments to RecordTypes
     *  currently do not deploy correctly in Unlocked Packages
     *  - but work fine with Salesforce CLI: force:source:push)
     * </p>
    **/
    @AuraEnabled
    global static String getMissingPermissionSetRedirection(){
        String results = null;
        String tempStr = null;
        String newResult = null;
        
        try {
            PermissionSet targetPS = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name = :PERMISSION_SET_NAME
                LIMIT 1
            ];

            EntityDefinition targetObject = [
                SELECT DeveloperName, DurableId
                FROM EntityDefinition 
                WHERE DeveloperName = :CHILD_SOBJECT_NAME
            ];

            tempStr = '/' + targetPS.Id + '?s=EntityPermissions&o=' + targetObject.DurableId;
            newResult = '/one/one.app#/setup/PermSets/page?address=' + EncodingUtil.urlEncode(tempStr,'UTF-8');
            
            results = newResult;
        } catch(Exception err){
            results = DEFAULT_MISSING_PERMISSION_URL;
        }

        return results;
    }
    
    
    //--    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    
    
    /**
     * Internal class that represents an item to be completed.
     **/
    global class SetupStep {
        
        /** Title of the Step being run. (Should be short) **/
        @AuraEnabled
        global String title;
        
        /** Longer form description of what will be run.
            (Hidden if not provided)
        **/
        @AuraEnabled
        global String descr;
        
        /** Reasoning of why the step is needed.
            (Hidden if not provided)
        **/
        @AuraEnabled
        global String reasoning;
        
        /** Additional detail to show the end user after the step.
            (ex: Link to the object created, etc.)
        **/
        @AuraEnabled
        global String seeMore;
        
        /** Short label to provide back to the user after completing the step. **/
        @AuraEnabled
        global String seeMoreLabel;
        
        //-- properties set after attempt
        
        /** Whether the step is complete
            (typically only set through markComplete())
        **/
        @AuraEnabled
        global boolean isComplete;
        
        /** End user readible error found when running the step
            (typically not initialized, only set afterwards)
        **/
        @AuraEnabled
        global String errMsg;
        
        /** Developer level error found when running the step
            (typically not initialized, only set afterwards)
        **/
        @AuraEnabled
        global String devErrMsg;
        
        /** DateTime when the step completed.
            (typically only set through markComplete())
        **/
        @AuraEnabled
        global String completionDate;

        SetupStep( Map<String,Object> props){
            //-- make similar to sObject inline definition
            if( props.containsKey('title')){
                this.title = (String)props.get('title');
            }
            if( props.containsKey('descr')){
                this.descr = (String)props.get('descr');
            }
            if( props.containsKey('reasoning')){
                this.reasoning = (String)props.get('reasoning');
            }
            if( props.containsKey('seeMore')){
                this.seeMore = (String)props.get('seeMore');
            }
            if( props.containsKey('seeMoreLabel')){
                this.seeMoreLabel = (String)props.get('seeMoreLabel');
            }
            
            //-- not likely, but available if desired
            if( props.containsKey('isComplete')){
                this.isComplete = (boolean)props.get('isComplete');
            }
            if( props.containsKey('errMsg')){
                this.errMsg = (String)props.get('errMsg');
            }
            if( props.containsKey('devErrMsg')){
                this.devErrMsg = (String)props.get('devErrMsg');
            }
            if( props.containsKey('completionDate')){
                this.completionDate = (String)props.get('completionDate');
            }
        }
        
        /**
         * Mark the step as completed.
         * @invariant - marked completed with a current completion date.
         **/
        void markCompleted(){
            this.isComplete = true;
            this.completionDate = System.now().format();
        }
    }
}