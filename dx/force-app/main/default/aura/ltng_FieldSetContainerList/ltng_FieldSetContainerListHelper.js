({
	setup : function(component, helper){
        //-- initialize any values - N/A at this time.

        var layoutStyle = component.get('v.layoutStyle');
        if (layoutStyle === 'horizontal') {
            layoutStyle = 'slds-form_horizontal';
        } else {
            layoutStyle = 'slds-form_stacked';
        }
        component.set('v.formStyles', '' + layoutStyle);

		var useTwoColumns = component.get('v.useTwoColumns');
		if( useTwoColumns ){
			component.set('v.gridStyles', 'slds-grid slds-wrap slds-gutters');
			component.set('v.columnStyles', 'slds-col slds-size_1-of-2');
		} else {
			component.set('v.gridStyles', 'slds-grid slds-grid_vertical slds-gutters');
			component.set('v.columnStyles', 'slds-col slds-size_1-of-1');
		}
    },
    
    /**
     * Sets the component edit mode
     */
    setEditMode : function(component, helper, inEditMode){
        component.set('v.inEditMode', inEditMode);
    },

    /**
     * Actually performs the saves process.
     * @invariant - the validation has been attempted and completed prior to the save
     * @see initiateFieldListSave
     */
    activateFieldListSave : function(component, helper){
        var editForm = component.find('edit');
        //-- validation
        editForm.submit();
    },

    /**
     * Dispatch the ContainerAction for a given actionType and whether it was successful.
     * @see initiateFieldListSave
     * @see handlers for save and error from the form submission.
     * @param actionType (String) - the NAME of the actionType (checked for in the handler for the Container)
     * @param success (Boolean)
     */
    submitContainerAction : function(component, helper, actionType, success){
        var containerAction = component.getEvent('ltng_FieldSetContainerAction');
        containerAction.setParams({
            "actionType" : actionType,
            "success" : success
        });
        containerAction.fire();
    },

    /**
     * Initiates the save process, by going through all validation
     * to see if the save should continue.
     * @INVARIANT - must send the containerAction 'VALIDATE' with status of true or false.
     */
    initiateFieldListSave : function(component, helper){
        
        //-- @TODO: add in validation
        // https://trailhead.salesforce.com/en/modules/lex_dev_lc_basics/units/lex_dev_lc_basics_forms

        //-- finally send the VALIDATE action (with success of TRUE if validation succeeds, or FALSE if any validation fails)
        helper.submitContainerAction(component, helper, 'VALIDATE', true); //-- VALIDATE_FAILED
    },

    /**
     *  Contained action from the Save / Error handlers to notify the Container the save has completed.
     */
    notifySaveSuccess : function(component, helper, success){
        helper.submitContainerAction(component, helper, 'SAVE', success);
    }
})