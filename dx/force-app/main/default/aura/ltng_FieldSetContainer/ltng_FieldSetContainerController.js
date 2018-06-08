({
	init : function(component, event, helper) {
		console.info('FieldSetContainer initialized');
		helper.setup(component, helper);
	},

	/**
	 *  Handler if the edit button is clicked
	 */
	handleEditToggleClicked : function(component, event, helper){
		//console.info('edit toggle is clicked');
		helper.toggleEdit(component, helper);
	},

	handleSaveClicked : function(component, event, helper){
		//console.info('save was clicked');
		helper.initiateSave(component, helper);
	},

	handleFieldSetContainerAction : function(component, event, helper){
		//console.info('parent captured a container action from the child');
		var actionType = event.getParam('actionType');
		var success = event.getParam('success');

		if( success === false ){
			//-- fail the batch, but wait until we get everybody.
			helper.setSaveStatus(component, event, false);
		}

		if( actionType === 'VALIDATE' ){
			helper.handleValidateAction(component, event, helper);
		} else if( actionType === 'SAVE' ){
			helper.handleSaveAction(component, event, helper);
		}
	},

	handleFieldSearchChanged : function(component, event, helper){
		//console.info('fieldSearch has changed');
		component.set('v.fieldSearchStr', event.getParam('value'));
	}
})