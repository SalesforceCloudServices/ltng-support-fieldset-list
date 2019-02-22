({
	setup : function(component, helper){
		var inEditMode = component.get('v.inEditMode');
		helper.setEditMode(component, helper, inEditMode);

		var fieldSetNames = component.get('v.fieldSetApiNames');
		var fieldSetList = helper.splitFieldSetNames(component, helper, fieldSetNames);
		component.set('v.fieldSetList', fieldSetList);

		var sObjectName = component.get('v.sObjectName');
		var recordId = component.get('v.recordId');
        
        helper.setSpinnerShown(component, helper, false);

		helper.determineFields(component, helper, fieldSetList, sObjectName, recordId);
	},
    
    /**
     * Whether to show the spinner (true) or not (false)
     * @param shouldShow (boolean)
     **/
    setSpinnerShown : function(component, helper, shouldShow) {
        component.set('v.showSpinner', shouldShow);
    },

	/**
	 * Splits a comma separated list of fieldset names by commas
	 * @param fieldSetNames (String)
	 * @return String[] - collection of fieldSetNames
	 */
	splitFieldSetNames : function(component, helper, fieldSetNames){
		var results = [];

		if( !$A.util.isEmpty(fieldSetNames) ){
			results = fieldSetNames.split(",");
		}

		return(results);
	},

	/**
	 * Determines the info of all the fieldsets in one request
	 * (instead of each component performing their own separate request)
	 */
	determineFields : function(component, helper, fieldSetNames, sObjectName, recordId){
		if (!fieldSetNames) {
        	console.log('The field set is required.');
        	return;
        }
        
        var getFormAction = component.get('c.getForms');

        getFormAction.setParams({
            fieldSetNames: fieldSetNames,
            recordId: recordId,
            sObjectName: sObjectName
        });

		//-- @TODO: investigate whether these can be cached / performance
		//-- as we are getting each individually
		//-- or could they be passed down from the Container?
        getFormAction.setCallback(this,
            function(response) {
                //console.info('getFormAction.callback');
            	var state = response.getState();
            	if (component.isValid() && state === "SUCCESS") {
	                var formInfo = response.getReturnValue();
	                component.set('v.formInfo', formInfo);
	                component.set('v.isReadOnly', !formInfo.HasEditAccess);
                }
            }
        );
        $A.enqueueAction(getFormAction);
    },

	/**
	 * Sets the Edit Mode (whether the form is currently editing or not)
	 * @param inEditMode (Boolean)
	 * @invariant sets v.editToggleLabel to indicate what clicking the button will now do.
	 * @invariant sets v.inEditMode
	 * @invariant sets v.isReadOnly
	 */
	setEditMode : function(component, helper, inEditMode){
		var editToggleLabel;

		//-- stop if the record is read only
		var isReadOnly = component.get('v.isReadOnly');
		if( isReadOnly ){
			return;
		}
		
		//-- remember the label is backwards
		//-- as the button is to transition to the other state
		if(inEditMode){
			editToggleLabel = 'Cancel';
		} else {
			editToggleLabel = 'Edit';
		}
		component.set('v.editToggleLabel', editToggleLabel);
		component.set('v.inEditMode', inEditMode);
	},

	/**
	 * Toggles the edit (flips it from True to False or vice versa.)
	 */
	toggleEdit : function(component, helper){
		//console.info('toggling edit mode');
		
		//-- abort attempting to start the save if currently saving.
		var activeSaveCounter = component.get('v.saveCountdown');
		if( activeSaveCounter > 0 ){
			console.error('currently saving, so we cannot escape the save');
			return;
		}

		var inEditMode = component.get('v.inEditMode');
		var newEditMode = !inEditMode;
		helper.setEditMode(component, helper, newEditMode);
	},

	/**
	 * Starts the save process by asking all forms to validate first.
	 * @invariant sets a counter for the forms that have been asked to validate.
	 * @invariant each form will submit a 'containerAction' of VALIDATE - as true or successful, captured under the action event handler. 
	 */
	initiateSave : function(component, helper){

		//-- abort attempting to start the save if currently saving.
		var activeSaveCounter = component.get('v.saveCountdown');
		if( activeSaveCounter > 0 ){
			console.error('currently saving, so we cannot escape the save');
			return;
		}

		var fieldSetContainers = component.find('fieldSetContainerList');
		helper.resetCounter(component, helper, fieldSetContainers.length);
        helper.safeForEach(fieldSetContainers, function(fieldSetContainer){
			fieldSetContainer.initiateSave(component, helper);
			//-- assume we will get a VALIDATE (success or fail)
		});
	},

	/**
	 * Continues the Save process by asking all forms to now finally save.
	 * @invariant sets a counter for the forms that have been asked to save.
	 * @invariant each form will submit a 'containerAction' of SAVE - as true or successful, captured under the action event handler. 
	 */
	activateSave : function(component, helper){
		//-- @invariant - all forms should be validated by this point.
		var fieldSetContainers = component.find('fieldSetContainerList');
		helper.resetCounter(component, helper, fieldSetContainers.length);
        helper.safeForEach(fieldSetContainers, function(fieldSetContainer){
			fieldSetContainer.activateSave(component, helper);
			//-- assume we will get a SAVE (success or fail)
		});
        
        //-- turn on the spinner
        helper.setSpinnerShown(component, helper, true);
	},

	/**
	 * Handles the behavior when it receives a 'VALIDATE' action
	 * <p>In response to the initiateSave request made earlier</p>
	 */
	handleValidateAction : function(component, event, helper){
		if( helper.decrementCounter(component, helper) ){
			//console.info('all components have submitted validation (successful or not) - so we are doe waiting');
			var wasSaveSuccessful = component.get('v.wasSaveSuccessful');
			if( wasSaveSuccessful ){
				//-- lets try to actually save
				helper.activateSave(component, helper);
			} else {
				console.error('one of the forms failed validation, but i am done waiting');
			}
		}
	},

	/**
	 *  Handles the behavior when the component receives the 'SAVE' action.
	 *  <p>In response to the activateSave request made to those components earlier</p>
	 */
    handleSaveAction : function(component, event, helper){
        // helper.decrementCounter(component, helper);
        //-- @UPDATE: we will only receive one save success response
        //-- not multiple (because of boxcar-ing the requests)
        //-- so mark the save as completed.
        component.set('v.saveCountdown', 0);
				
        //-- turn off the spinner
        helper.setSpinnerShown(component, helper, false);
		
        // if (allSaveResponsesCaptured) {
        // console.info('all components have submitted save (successful or not) - so we are doe waiting');
        var wasSaveSuccessful = component.get('v.wasSaveSuccessful');
        if( wasSaveSuccessful ){
        	// console.info('all forms validated and saved successfully, so we will convert back to read only mode.');
        	helper.setEditMode(component, helper, false);
        } else {
        	console.error('one of the forms failed validation, but i am done waiting');
        }
    },

	/**
	 * Defines the save status (either for validating or saving)
	 * for the current round of saves / etc.
	 * @param status (Boolean) - whether we are tracking as successful (true) or have encountered a failure(false)
	 */
	setSaveStatus : function(component, helper, status){
		component.set('v.wasSaveSuccessful', status);
	},

	/**
	 * Resets the Save Counter (a countdown latch) so we know how many components we are still waiting for.
	 * @param counterAmount (Integer) - the current count down latch.
	 */
	resetCounter : function(component, helper, counterAmount){
		if( !counterAmount ){
			counterAmount = 0;
		}
		helper.setSaveStatus(component, helper, true);
		component.set('v.saveCountdown', counterAmount);
	},

	/**
	 * Adds a number to the Save Counter (a count down latch) - to indicate another component to wait for
	 */
	incrementCounter : function(component, helper){
		var saveCountdown = component.get('v.saveCountdown') + 1;
		component.set('v.saveCountdown', saveCountdown);
	},

	/**
	 * Removes a number from the Save Counter (a count down latch) - to indicte a component has responded.
	 */
	decrementCounter : function(component, helper){
		var saveCountdown = component.get('v.saveCountdown') - 1;
		component.set('v.saveCountdown', saveCountdown);

		return( saveCountdown <= 0);
	},
    
    /**
     * Safe For-Each method. (Note that component.find() now returns
     * a single component or a list of components, making forEach no longer safe
     * because there is no forEach on a single component.
     * 
     * This is meant to be a direct replacement from
     * component.find('formItem').forEach(function(targetInput){ ... })
     * to
     * helper.safeForEach(component.find('formItem'), function(targetInput){ ... });
     * 
     * @param collection (component|component[]) - single component or multiple components
     * @param iterationFunction (function) - the function to call
     **/
    safeForEach : function(componentCollection, iterationFunction) {
        if (!componentCollection) {
            //-- no items
            return;
        } else if ((typeof componentCollection.forEach) != 'undefined') {
            //-- we have a list of components
            componentCollection.forEach(iterationFunction);
        } else {
            //-- single component
            var singleComponent = componentCollection;
            iterationFunction.call(this, singleComponent);
        }
    }
})